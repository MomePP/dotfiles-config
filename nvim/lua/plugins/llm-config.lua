local sidekick      = {
    'folke/sidekick.nvim',
    event = 'VeryLazy',
}

-- INFO: numbered clones (claude_1, claude_2, ...) for multi-session per cwd.
-- Workaround from https://github.com/folke/sidekick.nvim/discussions/208 — sidekick
-- keys tmux sessions by `cmd[1]` + `is_proc`, so distinct clone names produce distinct
-- sessions even when cwd matches. Clones are registered lazily on first toggle.

-- INFO: toggleterm-style state, mirrors snacks-config.lua's `target_term_id` pattern
local target_base   = nil
local target_cli_id = 1

-- INFO: register a `<base>_<i>` clone on-demand. Symlink lives next to the real binary
-- (already on $PATH); tool entry is injected into sidekick's live config registry.
local function ensure_clone(base, i)
    local clone = base .. '_' .. i
    local tools = require('sidekick.config').cli.tools
    if tools[clone] then return clone end

    local exe = vim.fn.exepath(base)
    if exe == '' then return nil end

    local link = vim.fs.joinpath(vim.fs.dirname(exe), clone)
    if not vim.uv.fs_stat(link) then
        vim.uv.fs_symlink(exe, link)
    end

    local cfg    = vim.deepcopy(tools[base] or {})
    cfg.cmd      = { clone }
    cfg.is_proc  = '\\<' .. clone .. '\\>'
    tools[clone] = cfg
    return clone
end

-- Set of attached clone slot ids for `base` in the current cwd.
local function live_slots(base)
    local State = require('sidekick.cli.state')
    local slots = {}
    for _, s in ipairs(State.get({ attached = true, cwd = true })) do
        local b, i = s.tool.name:match('^(.-)_(%d+)$')
        if b == base then slots[tonumber(i)] = true end
    end
    return slots
end

local function has_live_slot(base) return next(live_slots(base)) ~= nil end

-- INFO: pick a slot for `base`. No live clones → reset to 1 (don't resurrect
-- the last-used slot when everything was killed). Otherwise prefer target,
-- then highest live below it (keeps counted-up workflows stable), else lowest
-- live above it (handles target 1 dying with only higher slots alive).
local function resolve_slot(base, target)
    local live = live_slots(base)
    if not next(live) then return 1 end
    if live[target] then return target end
    local below, above
    for i in pairs(live) do
        if i < target and (not below or i > below) then below = i end
        if i > target and (not above or i < above) then above = i end
    end
    return below or above
end

-- INFO: resolve a picker pick — `name` can be a clone (`claude_2`) or a base
-- (`claude`). For clones the slot is in the name; for bases, `count > 0` forces
-- the slot, otherwise resolve_slot decides. Returns nil clone if `base` has no
-- executable on PATH.
local function resolve_pick(name, count)
    local b, i = name:match('^(.-)_(%d+)$')
    local base = b or name
    local slot
    if b then
        slot = tonumber(i) --[[@as integer]]
    elseif count and count > 0 then
        slot = count
    else
        slot = resolve_slot(base, target_cli_id)
    end
    return base, slot, ensure_clone(base, slot)
end

-- INFO: ensure a cwd-local session exists for `name`. Sidekick's cli.toggle/show/send
-- use State.with(attach=true) which falls through to a disambiguation picker when
-- multiple sessions share the same tool name across cwds. filter.cwd=true scopes it
-- but rejects synthetic states (a fresh slot gives "No tools match"). State.attach
-- with our tool config creates the cwd-local session AND opens the float window
-- (terminal:start always calls open_win) — so we return `true` and the caller skips
-- the subsequent cli.toggle/show, which would otherwise close the just-opened float.
local function ensure_cwd_session(name)
    local State = require('sidekick.cli.state')
    local cwd   = vim.fn.getcwd()
    for _, s in ipairs(State.get({ name = name })) do
        if s.session and s.session.cwd == cwd then return false end
    end
    State.attach({ tool = require('sidekick.config').get_tool(name) }, { show = true, focus = true })
    return true
end

-- INFO: scoped CLI picker — bypasses sidekick.cli.select so we can:
--   1. Drop dead clones from the registry (killed CLI leaves a ghost otherwise).
--   2. Hide bases whose cwd-local clones already exist (picking them would route
--      back through resolve_slot to the same live clone).
--   3. Filter the picker list to current-cwd sessions plus non-clone bases.
--   4. Trim the 40-col cwd-column padding from sidekick's row formatter, since
--      every visible item is now in the current cwd and the column overflows the
--      picker viewport.
local function open_picker(cb)
    local tools           = require('sidekick.config').cli.tools
    local State           = require('sidekick.cli.state')
    local UI              = require('sidekick.cli.ui.select')
    local cwd             = vim.fn.getcwd()

    -- live (any cwd) drives the prune; has_clone (cwd-local) drives the base hide.
    local live, has_clone = {}, {}
    for _, s in ipairs(State.get({ attached = true })) do
        live[s.tool.name] = true
        if s.session and s.session.cwd == cwd then
            local base = s.tool.name:match('^(.-)_%d+$')
            if base then has_clone[base] = true end
        end
    end

    local hidden = {}
    for name, cfg in pairs(tools) do
        local is_clone = name:match('_%d+$') ~= nil
        if is_clone and not live[name] then
            tools[name] = nil
        elseif not is_clone and has_clone[name] then
            hidden[name], tools[name] = cfg, nil
        end
    end

    -- Real sessions in this cwd, plus base entries (synthetic states without a
    -- session). Drop clone synthetics from other cwds and clone entries pointing
    -- at sessions running elsewhere.
    local items = vim.tbl_filter(function(t)
        if t.session then return t.session.cwd == cwd end
        return t.tool.name:match('_%d+$') == nil
    end, State.get({ installed = true }))

    local function restore()
        for name, cfg in pairs(hidden) do tools[name] = cfg end
    end

    if #items == 0 then
        restore()
        return cb(nil)
    end

    -- Reuse sidekick's per-row formatter but collapse the 40-col cwd pad to a
    -- single double-space separator so the cwd column still renders without
    -- pushing past the picker viewport.
    local function format_compact(item, picker)
        local parts, result = UI.format(item, picker), {}
        for _, p in ipairs(parts) do
            local text = p[1] or ''
            if text:match('^ +$') and #text > 10 then
                result[#result + 1] = { '  ' }
            else
                result[#result + 1] = p
            end
        end
        return result
    end

    vim.ui.select(items, {
        prompt      = 'Select CLI tool:',
        kind        = 'sidekick_cli',
        format_item = function(item)
            return table.concat(vim.tbl_map(function(p) return p[1] end, format_compact(item)))
        end,
        snacks      = { format = format_compact },
    }, function(state)
        restore()
        if state and not state.installed then
            UI.on_missing(state.tool)
            state = nil
        end
        cb(state)
    end)
end

sidekick.opts = {
    cli = {
        win = {
            layout = 'float',
            float = {
                height = 1,
                width  = 1,
                -- INFO: bottom-only "invisible border" reserves a row for the footer.
                -- 8-elem order: top-left, top, top-right, right, bottom-right, bottom,
                -- bottom-left, left. Only the bottom row carries spaces.
                border = { '', '', '', '', ' ', ' ', ' ', '' },
            },
            -- INFO: per-terminal init hook; sidekick deep-copies cli.win into self.opts
            -- before calling this. Footer renders the slot as a 5-segment sentence:
            -- "Sidekick ID: <id> with <cli> on <cwd>" — each variable part carries its
            -- own bold hl (id, cli name, cwd path) and the " with "/" on " connectors
            -- use Normal. bold() resolves the base group's attrs and re-sets with
            -- bold; idempotent + theme-aware (re-runs on each float open).
            config = function(self)
                local function bold(name, base)
                    local hl = vim.api.nvim_get_hl(0, { name = base, link = false }) or {}
                    hl.bold = true
                    vim.api.nvim_set_hl(0, name, hl)
                end
                bold('SidekickFooterAccent', 'SnacksTerminalFooter')
                bold('SidekickFooterCli', 'MarkSignNumHL')
                bold('SidekickFooterPath', 'WarningMsg')

                local base, id             = self.tool.name:match('^(.-)_(%d+)$')
                local cwd                  = vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
                self.opts.float.footer     = {
                    { 'Sidekick ID: ' .. id, 'SidekickFooterAccent' },
                    { ' with ',              'Normal' },
                    { base,                  'SidekickFooterCli' },
                    { ' on ',                'Normal' },
                    { cwd,                   'SidekickFooterPath' },
                }
                self.opts.float.footer_pos = 'left'
            end,
            -- INFO: buffer-local terminal-mode keymap registered on each sidekick float
            -- so <leader>s from inside the CLI hides the float (snacks-terminal pattern).
            -- The rhs 'toggle' resolves to the terminal's M:toggle method.
            keys = {
                shift_enter = { '<S-CR>', function(self)
                    vim.api.nvim_chan_send(self.job, '\x1b[13;2u')
                end },
                toggle = { '<leader>s', 'toggle' },
            },
            -- INFO: mirror snacks-terminal styling. winblend = 0 overrides the global
            -- default (options.lua sets 5 for slightly-transparent floats), same opt-out
            -- pattern as noice-config.lua's chat sub-views.
            wo = {
                winblend     = 0,
                winhighlight =
                'Normal:SnacksTerminalNormal,NormalNC:SnacksTerminalNormal,FloatBorder:SnacksTerminalBorder,FloatFooter:SnacksTerminalFooter',
            },
            -- split = { width = 0.45 },
        },
        tools = {
            claude = {
                -- INFO: `/tui fullscreen` puts Claude Code on the alternate screen with
                -- its own mouse-tracking TUI. Sidekick's default scrollback interception
                -- (scrollback.lua) swallows <ScrollWheel*> to open ITS scrollback buffer,
                -- so the wheel never reaches Claude's fullscreen scroller. native_scroll
                -- disables that interception and forwards the wheel to the CLI app.
                native_scroll = true,
                env = (function()
                    local env = {}

                    if vim.fn.getcwd():find('gogoboard') then
                        env.PATH = vim.fn.expand('~/Developer/toolchains/esp-clangd/bin')
                            .. ':' .. vim.uv.os_environ().PATH
                    end

                    return env
                end)(),
            },
            opencode = {
                env = {
                    OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS = 'true',
                    OPENCODE_EXPERIMENTAL_LSP_TOOL = 'true',
                },
                keys = {
                    prompt = { '<a-p>', 'prompt' },
                },
                native_scroll = true,
                continue = { '--continue' },
            },
            omp = {
                cmd = { 'omp' },
                native_scroll = false,
                is_proc = '\\<omp\\>',
                continue = { '--continue' },

            },
        },
        mux = {
            enabled = true,
            backend = 'tmux',
        },
    }
}

sidekick.keys = function()
    local sidekick_keymap = require('config.keymaps').sidekick

    return {
        {
            sidekick_keymap.apply_nes,
            function()
                if not require('sidekick').nes_jump_or_apply() then
                    return sidekick_keymap.apply_nes
                end
            end,
            expr = true,
            desc = 'Goto/Apply Next Edit Suggestion',
        },
        {
            sidekick_keymap.select,
            function()
                open_picker(function(state)
                    if not state then return end
                    local base, slot, clone = resolve_pick(state.tool.name)
                    if not clone then return end
                    target_base, target_cli_id = base, slot
                    if ensure_cwd_session(clone) then return end
                    require('sidekick.cli').show({ name = clone, filter = { cwd = true }, focus = true })
                end)
            end,
            desc = 'Sidekick Select CLI',
        },
        {
            sidekick_keymap.toggle,
            function()
                local count = vim.v.count

                local function spawn(name)
                    local base, slot, clone = resolve_pick(name, count)
                    if not clone then return end
                    target_base, target_cli_id = base, slot
                    if ensure_cwd_session(clone) then return end
                    require('sidekick.cli').toggle({ name = clone, filter = { cwd = true } })
                end

                -- INFO: target_base sticks only while it has a live cwd-local session.
                -- Once the last is killed (Ctrl-C) we fall through to the picker so the
                -- user re-selects. Count override bypasses the check so `2<leader>s`
                -- still spawns explicitly.
                if target_base and (count > 0 or has_live_slot(target_base)) then
                    return spawn(target_base)
                end

                open_picker(function(state)
                    if state then spawn(state.tool.name) end
                end)
            end,
            desc = 'Sidekick Toggle (count = slot)',
        },
        {
            sidekick_keymap.toggle,
            function()
                local name = target_base and target_base .. '_' .. target_cli_id
                if name then ensure_cwd_session(name) end
                require('sidekick.cli').send({
                    msg    = '{selection}',
                    name   = name,
                    filter = { cwd = true },
                })
            end,
            mode = { 'x' },
            desc = 'Sidekick Send Visual Selection',
        },
    }
end

-- INFO: sidekick resolves a float's fractional size to absolute rows/columns once,
-- in Terminal:open_win (`opts.width = opts.width <= 1 and floor(vim.o.columns * w)`),
-- and registers no VimResized handler. An `editor`-relative float keeps whatever
-- geometry it was opened with, so a float opened while the editor was narrow stays
-- narrow after it widens — nvim clamps floats down to fit but never grows them back.
--
-- Reproduce: open the tmux agent-switcher dock (narrows the nvim pane), toggle the
-- sidekick float, close the dock. The pane returns to full width; the float does not.
--
-- Re-apply the same arithmetic on VimResized. Geometry is written over the window's
-- *current* config rather than rebuilt, so the border, footer and title set up by
-- `cli.win.config` survive untouched.
vim.api.nvim_create_autocmd('VimResized', {
    group = vim.api.nvim_create_augroup('sidekick_float_resize', { clear = true }),
    desc = 'Re-fit sidekick CLI floats to the editor',
    callback = function()
        local ok, Terminal = pcall(require, 'sidekick.cli.terminal')
        if not ok then return end

        for _, term in ipairs(Terminal.sessions()) do
            local float = term.opts and term.opts.layout == 'float' and term.opts.float
            if float and term.win and vim.api.nvim_win_is_valid(term.win) then
                local width  = float.width or 0
                local height = float.height or 0
                width  = width <= 1 and math.floor(vim.o.columns * width) or width
                height = height <= 1 and math.floor(vim.o.lines * height) or height
                width, height = math.max(width, 80), math.max(height, 10)

                local row, col = float.row or 0.5, float.col or 0.5
                row = row <= 1 and math.floor((vim.o.lines - height) * row) or row
                col = col <= 1 and math.floor((vim.o.columns - width) * col) or col

                local cfg = vim.api.nvim_win_get_config(term.win)
                cfg.row, cfg.col, cfg.width, cfg.height = row, col, width, height
                pcall(vim.api.nvim_win_set_config, term.win, cfg)
            end
        end
    end,
})

return {
    sidekick
}

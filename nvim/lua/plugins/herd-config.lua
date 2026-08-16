-- herd.nvim — nvim is the host, herdr is the backend daemon. CLI agents run in
-- nvim floating terminals via `herdr agent attach`. https://github.com/MomePP/herd.nvim
--
-- INFO: gated on the `herdr` binary being installed (NOT on HERDR_PANE_ID). In the
-- nvim-host model nvim no longer needs to live inside a herdr pane — herdr just needs
-- its server/daemon running. The plugin's own ensure_server() warns if it isn't.
--
-- Keys come from config/keymaps.lua (<leader>s toggle/send/hide, <leader>S
-- picker, <leader><tab> dashboard); the fullscreen float and the 'herd.nvim'
-- workspace label are plugin DEFAULTS — only the personal bits (keys,
-- transparency winhighlight + tools) remain here.
--
-- Context-bridge features (all plugin defaults): visual <leader>s wraps the
-- selection with its path:line-range (send.context); FocusGained/float-leave run
-- checktime so agent edits refresh (reload). Commands (no default keymap):
-- :Herd diagnostics (send buffer LSP diagnostics), :Herd jump (quickfix the
-- path:line refs in the agent's output).
local M = {
    'MomePP/herd.nvim',
    -- dev = true, -- use local ~/Developer/nvim-plugins/herd.nvim
    cond = function() return vim.fn.executable('herdr') == 1 end,
    event = 'VeryLazy',
}

M.opts = {
    -- float mode: this is the sidekick.nvim workflow with herdr as the backend.
    -- Open nvim in the working dir, <leader>s spawns/toggles this cwd's agent — the
    -- process is a persistent herdr agent parked in the dedicated 'herd.nvim'
    -- workspace (never tiled next to nvim), and the float is just `herdr agent
    -- attach` wiring its PTY into an nvim terminal. Hiding the float or quitting
    -- nvim detaches, it does not kill; the agent is back on the next <leader>s.
    -- The whole round trip stays inside nvim, so no herdr-side return key is needed
    -- (config.toml's prefix+tab herd-return only matters in native mode).
    --
    -- native mode (mode = 'native') instead spawns each agent as a sibling herdr
    -- tab for native Ghostty scroll/drag-select, and needs nvim to run inside a
    -- herdr pane. win.* below is float-only.
    keys = require('config.keymaps').herd,
    mode = 'float',
    win = {
        -- transparency: map the float to the terminal highlight groups (Snacks) so
        -- Ghostty's transparent background shows through the fullscreen float.
        winhighlight =
        'Normal:SnacksTerminalNormal,NormalNC:SnacksTerminalNormal,FloatBorder:SnacksTerminalBorder,FloatFooter:SnacksTerminalFooter',
    },
    tools = {
        claude   = { cmd = { 'claude' } },
        opencode = {
            cmd = { 'opencode', '--continue' },
            env = {
                OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS = 'true',
                OPENCODE_EXPERIMENTAL_LSP_TOOL = 'true',
            },
        },
        omp      = { cmd = { 'omp', '--continue' } },
    },
}

return M

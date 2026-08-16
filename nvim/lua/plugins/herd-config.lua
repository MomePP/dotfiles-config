-- herd.nvim — nvim drives, herdr owns the agent processes and shows them.
-- https://github.com/MomePP/herd.nvim
--
-- INFO: the spec gate is the `herdr` binary; native mode additionally needs nvim
-- to be running inside a herdr pane, which the plugin checks itself (falling back
-- to float mode with a warning when it isn't).
--
-- Keys come from config/keymaps.lua (<leader>s toggle/send, <leader>S picker,
-- <leader><tab> dashboard); the 'herd.nvim' workspace label is a plugin DEFAULT —
-- only the personal bits (keys, placement, transparency winhighlight + tools)
-- remain here.
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
    -- native + placement='workspace': <leader>s spawns the agent as a real herdr
    -- tab in the dedicated 'herd.nvim' space and focuses it there — no nvim float,
    -- no PTY attach, so scroll and drag-select are native Ghostty/herdr. Project
    -- spaces keep their tab bars to editors only.
    --
    -- The trip back is herdr-side by necessity: once herdr shows the agent, nvim
    -- receives no keys, so <leader>s can only ever mean "go to the agent".
    -- config.toml binds prefix+s (Ctrl-a s) to herd-return, which reads the agent
    -- tab's '<project>:<agent>' label and focuses the editor tab it names — across
    -- spaces, since the agent no longer sits beside nvim.
    --
    -- Requires nvim to run inside a herdr pane (reads $HERDR_TAB_ID); otherwise
    -- setup() warns and falls back to float mode. win.* below is float-only.
    keys = require('config.keymaps').herd,
    mode = 'native',
    placement = 'workspace',
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

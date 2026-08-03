-- herd.nvim — nvim is the host, herdr is the backend daemon. CLI agents run in
-- nvim floating terminals via `herdr agent attach`. https://github.com/MomePP/herd.nvim
--
-- INFO: gated on the `herdr` binary being installed (NOT on HERDR_PANE_ID). In the
-- nvim-host model nvim no longer needs to live inside a herdr pane — herdr just needs
-- its server/daemon running. The plugin's own ensure_server() warns if it isn't.
--
-- Keys come from config/keymaps.lua (<leader><tab> toggle/send/hide, <leader>s
-- picker, <leader>S dashboard); the fullscreen float and the 'herd.nvim' workspace
-- label are plugin DEFAULTS — only the personal bits (keys, transparency
-- winhighlight + tools) remain here.
--
-- Context-bridge features (all plugin defaults): visual <leader><tab> wraps the
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
    -- native mode: spawn each agent as a sibling herdr tab (no nvim float) so
    -- scroll/drag-select are native Ghostty/herdr. Requires nvim to run inside a
    -- herdr pane (else it warns + falls back to float). Round trip: <leader><tab> goes
    -- to the agent, Ctrl-a <tab> (herd-return) comes back — and with --resurrect in
    -- config.toml, relaunches nvim if it was quit to a shell. win.* below is float-only.
    keys = require('config.keymaps').herd,
    mode = 'native',
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

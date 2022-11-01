local status_ok, gitsigns = pcall(require, 'gitsigns')
if not status_ok then return end

gitsigns.setup {
    -- opts in `preview_config` passed to `nvim_open_win`
    preview_config = {
        border = 'none',
        style = 'minimal',
        relative = 'cursor',
        row = 1,
        col = 0,
        focusable = false,
    },
}

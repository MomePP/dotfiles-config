local status_ok, gitsigns = pcall(require, "gitsigns")
if not status_ok then
    return
end

gitsigns.setup {
    current_line_blame_formatter_opts = {
        relative_time = false
    },
    preview_config = {
        -- Options passed to nvim_open_win
        border = 'rounded',
        style = 'minimal',
        relative = 'cursor',
        row = -1,
        col = 2,
        focusable = false,
    },
}


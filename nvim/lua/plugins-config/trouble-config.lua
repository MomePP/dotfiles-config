local status_ok, trouble = pcall(require, 'trouble')
if not status_ok then return end

trouble.setup {
    height = 18,
    use_diagnostic_signs = true,
    action_keys = {
        close = {},
        cancel = {},
        close_to_parent = { 'q', '<esc>' }
    }
}

-- INFO: extends action to close and focus back on active split
trouble.close_to_parent = function()
    trouble.action('cancel')
    trouble.close()
end

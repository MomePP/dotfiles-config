local status_ok, navic = pcall(require, 'nvim-navic')
if not status_ok then return end

navic.setup({
    separator = '  ',
    depth_limit = 6
})

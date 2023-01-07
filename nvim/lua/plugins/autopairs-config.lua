local M = {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
}

M.config = function()
    require('nvim-autopairs').setup {}

    local cmp_status, cmp = pcall(require, 'cmp')
    if cmp_status then
        cmp.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done())
    end
end

return M

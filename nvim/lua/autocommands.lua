vim.api.nvim_create_autocmd('InsertLeave', {
    desc = 'turn off paste mode when leaving insert',
    pattern = '*',
    command = 'set nopaste'
})

vim.api.nvim_create_autocmd('FileType', {
    desc = 'open help docs in vertical split',
    pattern = 'help',
    command = ':wincmd L | :vert'
})

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'highlight text on yank',
    pattern = '*',
    callback = function() vim.highlight.on_yank({ on_visual = false }) end
})

-- check if we need to reload file when it changed
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
    command = 'checktime'
})

-- disable search highlight when enter terminal mode and re-enable when leave
vim.api.nvim_create_augroup('TermHLSearch', { clear = true })
vim.api.nvim_create_autocmd('TermEnter', {
    desc = 'disable hlsearch when enter terminal mode',
    group = 'TermHLSearch',
    command = ':setlocal nohlsearch'
})
vim.api.nvim_create_autocmd('TermLeave', {
    desc = 'enable hlsearch when leave terminal mode',
    group = 'TermHLSearch',
    command = ':setlocal hlsearch'
})

-- INFO: global lua func for lazygit remoted to open file
function _OpenFile(filePath)
    local exec_cmd = "edit " .. filePath
    vim.defer_fn(function() vim.cmd(exec_cmd) end, 100)
end

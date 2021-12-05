if !exists('g:loaded_telescope') | finish | endif

nnoremap <silent> <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <silent> <leader>fs <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <silent> <leader>fb <cmd>lua require('telescope').extensions.file_browser.file_browser()<cr>
nnoremap <silent> <leader>gf <cmd>lua require('telescope.builtin').git_files()<cr>
nnoremap <silent> <leader>gb <cmd>lua require('telescope.builtin').git_branches()<cr>
nnoremap <silent> <leader>gs <cmd>lua require('telescope.builtin').git_status()<cr>
nnoremap <silent> <leader>gS <cmd>lua require('telescope.builtin').git_stash()<cr>
nnoremap <silent> <leader>\ <cmd>Telescope buffers<cr>
nnoremap <silent> <leader>; <cmd>Telescope help_tags<cr>


if !exists('g:loaded_telescope') | finish | endif

nnoremap <silent> <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <silent> <leader>fs <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <silent> <leader>fb <cmd>lua require('telescope.builtin').file_browser( { hidden = true } )<cr>
nnoremap <silent> <leader>gf <cmd>lua require('telescope.builtin').git_files()<cr>
nnoremap <silent> <leader>gb <cmd>lua require('telescope.builtin').git_branches()<cr>
nnoremap <silent> <leader>gs <cmd>lua require('telescope.builtin').git_status()<cr>
nnoremap <silent> <leader>gS <cmd>lua require('telescope.builtin').git_stash()<cr>
nnoremap <silent> <leader>\ <cmd>Telescope buffers<cr>
nnoremap <silent> <leader>; <cmd>Telescope help_tags<cr>

lua << EOF
function telescope_buffer_dir()
  return vim.fn.expand('%:p:h')
end

local telescope = require('telescope')
local actions = require('telescope.actions')

telescope.setup{
  defaults = {
    file_sorter = require("telescope.sorters").get_fzy_sorter,
    prompt_prefix = " > ",
    color_devicons = true,

    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
    qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,

    mappings = {
      n = {
        ["q"] = actions.close
      },
    },
  },
  extensions = {
    fzy_native = {
      override_generic_sorter = false,
      override_file_sorter = true,
    },
  }
}

telescope.load_extension("fzy_native")

_G.open_telescope = function()
    local first_arg = vim.v.argv[2]
    -- print("path: ", first_arg)
    if first_arg then
      if vim.fn.isdirectory(first_arg) == 1 then
        if first_arg == "." then
          first_arg = vim.fn.expand('%')
        end
        vim.api.nvim_set_current_dir(first_arg)
        require("telescope.builtin").file_browser({cwd = first_arg, hidden = true})
      end
    end
end

vim.api.nvim_exec([[
augroup TelescopeOnEnter
    autocmd!
    autocmd VimEnter * lua open_telescope()
augroup END
]], false)

EOF

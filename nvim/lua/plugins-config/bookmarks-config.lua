-- INFO: config vim-bookmarks
vim.g.bookmark_sign = ''
-- vim.g.bookmark_auto_save_file = vim.fn.stdpath('data') .. '/vim-bookmarks'
vim.g.bookmark_save_per_working_dir = 1 -- NOTE: this need to add `.vim-bookmarks` to global gitignore
vim.g.bookmark_center = 1
vim.g.bookmark_show_warning = 0
vim.g.bookmark_show_toggle_warning = 0

-- INFO: override `BookmarkShowAll` function to use `trouble.nvim`
vim.api.nvim_exec([[
function! s:refresh_line_numbers_mod()
  let file = expand("%:p")
  if file ==# "" || !bm#has_bookmarks_in_file(file)
    return
  endif
  let bufnr = bufnr(file)
  let sign_line_map = bm_sign#lines_for_signs(file)
  for sign_idx in keys(sign_line_map)
    let line_nr = sign_line_map[sign_idx]
    let line_content = getbufline(bufnr, line_nr)
    let content = len(line_content) > 0 ? line_content[0] : ' '
    call bm#update_bookmark_for_sign(file, sign_idx, line_nr, content)
  endfor
endfunction

function! BookmarkList()
  call s:refresh_line_numbers_mod()
  let oldformat = &errorformat    " backup original format
  let &errorformat = "%f:%l:%m"   " custom format for bookmarks
  cgetexpr bm#location_list()
  if len(getqflist()) > 0
    TroubleToggle quickfix
  else
    echo 'There is no bookmarks -  '
  endif
  let &errorformat = oldformat    " re-apply original format
endfunction

command! BookmarkList call BookmarkList()
]], false)

-- INFO: set bookmarks keymapping
vim.g.bookmark_no_default_key_mappings = 1

local bookmarks_keymap = require('keymappings').bookmarks

vim.keymap.set('n', bookmarks_keymap.toggle, '<Cmd>BookmarkToggle<CR>', bookmarks_keymap.opts)
vim.keymap.set('n', bookmarks_keymap.annotate, '<Cmd>BookmarkAnnotate<CR>', bookmarks_keymap.opts)
vim.keymap.set('n', bookmarks_keymap.list, '<Cmd>BookmarkList<CR>', bookmarks_keymap.opts)
vim.keymap.set('n', bookmarks_keymap.next, '<Cmd>BookmarkNext<CR>', bookmarks_keymap.opts)
vim.keymap.set('n', bookmarks_keymap.prev, '<Cmd>BookmarkPrev<CR>', bookmarks_keymap.opts)
vim.keymap.set('n', bookmarks_keymap.clear, '<Cmd>BookmarkClearAll<CR>', bookmarks_keymap.opts)

-- INFO: set bookmarks highlight
local colors = require('colorscheme').colorset
vim.api.nvim_set_hl(0, 'BookmarkSign', { fg = colors.bright_blue })

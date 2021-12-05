" --- keymaps binding ---
"

" Delete a word backwards
nnoremap dw vb"_d

" Delete without yank
nnoremap <leader>d "_d
nnoremap x "_x

" replace-paste with yank
vnoremap <leader>p "_dP

" de-tab while in insert mode
inoremap <S-Tab> <C-d>

" select all
nmap <C-a> gg<S-v>G

" Save with root permission
command! W w !sudo tee > /dev/null %

" Search for selected text, forwards or backwards.
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>

" --- Tabs
" Open current directory
nmap te :tabedit 
nmap <S-Tab> :tabprev<Return>
nmap <Tab> :tabnext<Return>

" --- Windows
" Split window
nmap ss :split<Return><C-w>w
nmap sv :vsplit<Return><C-w>w
" Move window
nmap sq <C-w>q
nmap <Space> <C-w>w
map s<left> <C-w>h
map s<up> <C-w>k
map s<down> <C-w>j
map s<right> <C-w>l
map sh <C-w>h
map sk <C-w>k
map sj <C-w>j
map sl <C-w>l
" Resize window
nmap <C-w><left> <C-w><
nmap <C-w><right> <C-w>>
nmap <C-w><up> <C-w>+
nmap <C-w><down> <C-w>-

" move line or visually selected block - opt+j/k - must set iterm to esc+
inoremap <m-j> <Esc>:m .+1<CR>==gi
inoremap <m-k> <Esc>:m .-2<CR>==gi
inoremap <m-down> <Esc>:m .+1<CR>==gi
inoremap <m-up> <Esc>:m .-2<CR>==gi

vnoremap <m-j> :m '>+1<CR>gv=gv
vnoremap <m-k> :m '<-2<CR>gv=gv
vnoremap <m-down> :m '>+1<CR>gv=gv
vnoremap <m-up> :m '<-2<CR>gv=gv

nnoremap <m-j> :m+<CR>
nnoremap <m-k> :m-2<CR>
nnoremap <m-down> :m+<CR>
nnoremap <m-up> :m-2<CR>

" --- Terminal
"  exit terminal to normal mode
:tnoremap <Esc> <C-\><C-n>


" Status line
" if !exists('*fugitive#statusline')
"   function! fugitive#statusline()
"     return ''
"   endfunction
" endif
"
" augroup fugitive_status
"   autocmd!
"   autocmd user Fugitive set statusline=%F\ %m%r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).':'.&ff.']'}[L%l/%L,C%03v]
"   autocmd user Fugitive set statusline+=%=
"   autocmd user Fugitive set statusline+=%{fugitive#statusline()}
" augroup END

cnoreabbrev g Git
cnoreabbrev gopen GBrowse


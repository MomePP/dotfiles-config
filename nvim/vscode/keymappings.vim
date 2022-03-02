" INFO: default remap keys
nnoremap <C-l> <Cmd>nohl<CR>
nnoremap dw vb"_d
nnoremap x "_x
nnoremap Y y$
nmap P <Cmd>pu<CR>
inoremap <S-Tab> <C-d>
vnoremap p "_dP
nnoremap <C-k> <Cmd>call VSCodeNotify("workbench.action.navigateBack")<CR>
nnoremap <C-j> <Cmd>call VSCodeNotify("workbench.action.navigateForward")<CR>

" INFO: Tab management keymap
nnoremap <S-Tab> <Cmd>Tabprevious<CR>
xnoremap <S-Tab> <Cmd>Tabprevious<CR>
nnoremap <Tab> <Cmd>Tabnext<CR>
xnoremap <Tab> <Cmd>Tabnext<CR>
nnoremap tq <Cmd>Tabclose<CR>

" INFO: Pane management keymap
nnoremap <Space> <Cmd>call VSCodeNotify('workbench.action.focusNextGroup')<CR>
nnoremap sj <Cmd>Split<CR>
nnoremap sk <Cmd>Split<CR>
nnoremap sh <Cmd>Vsplit<CR>
nnoremap sl <Cmd>Vsplit<CR>
nnoremap sq <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>

" INFO: Navigate keymap
nnoremap gw <Cmd>call VSCodeNotify('actions.find')<CR>
nnoremap gt <Cmd>call VSCodeNotify('editor.action.goToTypeDefinition')<CR>
nnoremap gr <Cmd>call VSCodeNotify('editor.action.goToReferences')<CR>
nnoremap gp <Cmd>call VSCodeNotify('editor.action.peekDefinition')<CR>
nnoremap gx <Cmd>call VSCodeNotify('editor.action.quickFix')<CR>
nnoremap gs <Cmd>call VSCodeNotify('editor.action.triggerParameterHints')<CR>

" INFO: File management keymap
nnoremap <leader>fb <Cmd>call VSCodeNotify('workbench.view.explorer')<CR>
nnoremap <leader>fs <Cmd>call VSCodeNotify('workbench.action.findInFiles')<CR>
nnoremap <leader>ff <Cmd>call VSCodeNotify('editor.action.formatDocument')<CR>

" INFO: LSP keymap
nnoremap ]d <Cmd>call VSCodeNotify('editor.action.marker.next')<CR>
nnoremap [d <Cmd>call VSCodeNotify('editor.action.marker.prev')<CR>
nnoremap <leader>ld <Cmd>call VSCodeNotify('workbench.actions.view.problems')<CR>
nnoremap <leader>ls <Cmd>call VSCodeNotify('workbench.action.gotoSymbol')<CR>
nnoremap <leader>lr <Cmd>call VSCodeNotify('editor.action.rename')<CR>

" INFO: Gitfile keymap
nnoremap ]c <Cmd>call VSCodeNotify('workbench.action.editor.nextChange')<CR>
nnoremap [c <Cmd>call VSCodeNotify('workbench.action.editor.prevChange')<CR>
nnoremap <leader>hs <Cmd>call VSCodeNotify('git.stageSelectedRanges')<CR>
nnoremap <leader>hu <Cmd>call VSCodeNotify('git.unstageSelectedRanges')<CR>
nnoremap <leader>hp <Cmd>call VSCodeNotify('editor.action.dirtydiff.next')<CR>
nnoremap <leader>hr <Cmd>call VSCodeNotify('git.revertSelectedRanges')<CR>
nnoremap <leader>g <Cmd>call VSCodeNotify('workbench.view.scm')<CR>

" INFO: Markdown preview
nnoremap <Leader>p <Cmd>call VSCodeNotify('markdown.showPreview')<CR>

" INFO: Bookmarks plugin
nnoremap m; <Cmd>call VSCodeNotify('bookmarks.toggle')<CR>
nnoremap md <Cmd>call VSCodeNotify('bookmarks.clear')<CR>
nnoremap ]m <Cmd>call VSCodeNotify('bookmarks.jumpToNext')<CR>
nnoremap [m <Cmd>call VSCodeNotify('bookmarks.jumpToPrevious')<CR>
nnoremap <leader>m <Cmd>call VSCodeNotify('bookmarks.listFromAllFiles')<CR>

" INFO: terminal keymap
nnoremap <leader>t <Cmd>call VSCodeNotify('workbench.action.terminal.toggleTerminal')<CR>

" INFO: zenmode keymap
nnoremap <leader>z <Cmd>call VSCodeNotify('workbench.action.toggleZenMode')<CR>

" INFO: comment keymap
xmap gc  <Cmd>call VSCodeNotifyVisual('editor.action.commentLine', 1)<CR>
nmap gcc <Cmd>call VSCodeNotify('editor.action.commentLine')<CR>


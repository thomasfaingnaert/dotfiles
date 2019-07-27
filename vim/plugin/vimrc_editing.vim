if exists('g:loaded_vimrc_editing')
    finish
endif
let g:loaded_vimrc_editing = 1

let s:dotfiles = has('win32') ? '~/dotfiles' : '~/.dotfiles'

nnoremap <silent> <Plug>edit_vimrc :call vimrc_editing#edit_vimrc()<CR>

augroup vimrc_editing
    execute 'autocmd BufReadPre   ' . s:dotfiles . '/vim/vimrc setlocal foldmethod=expr foldexpr=vimrc_editing#foldexpr() foldtext=vimrc_editing#foldtext()'
    execute 'autocmd BufWritePost ' . s:dotfiles . '/vim/vimrc source $MYVIMRC'
augroup end

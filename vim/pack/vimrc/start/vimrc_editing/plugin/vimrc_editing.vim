if exists('g:loaded_vimrc_editing')
    finish
endif
let g:loaded_vimrc_editing = 1

let s:dotfiles = has('win32') ? '~/dotfiles' : '~/.dotfiles'
let s:myvimrc = s:dotfiles . '/vim/vimrc'

nnoremap <silent> <Plug>edit_vimrc :call vimrc_editing#edit_vimrc()<CR>

augroup vimrc_editing
    execute 'autocmd BufReadPre   ' . s:myvimrc . ' setlocal foldmethod=expr foldexpr=vimrc_editing#foldexpr() foldtext=vimrc_editing#foldtext()'
    execute 'autocmd BufWritePost ' . s:myvimrc . ' source $MYVIMRC'
augroup end

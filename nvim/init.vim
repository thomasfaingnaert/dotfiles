call plug#begin()

Plug 'lifepillar/vim-solarized8'

call plug#end()

" Show the line number the cursor is on
set number

" Show the line number relative to the line the cursor is on
set relativenumber

" Use 4 spaces for each step of indent (used for >>, <<, etc.)
set shiftwidth=4

" Use spaces instead of tabs
set expandtab

" Change symbols used for invisible characters
set listchars=eol:¬,tab:▸\ ,trail:·,precedes:←,extends:→

" Set leader to space
let mapleader=" "

" Leader mappings
nnoremap <leader>w :write<CR>
nnoremap <leader>v :edit $MYVIMRC<CR>
nnoremap <leader>r :source $MYVIMRC<CR>
nnoremap <leader>l :set list!<CR>
nnoremap <leader>h :set hlsearch!<CR>
nnoremap <leader>= :call <SID>Preserve("normal gg=G")<CR>
nnoremap <leader>b :ls<CR>:b<SPACE>
nnoremap <leader>d :ls<CR>:bd<SPACE>
nnoremap <leader>c :lcd %:h<CR>

" Function to preserve "state" and execute command
" (Source: http://vimcasts.org/episodes/tidying-whitespace/)
function! <SID>Preserve(command)
    " Preparation: save last search, and cursor position.
    let l:win_view = winsaveview()
    let l:last_search = getreg('/')
    " Execute the command without adding to the
    " changelist/jumplist:
    execute 'keepjumps ' . a:command
    " Clean up: restore previous search history, and
    " cursor position
    call winrestview(l:win_view)
    call setreg('/', l:last_search)
endfunction

augroup strip_whitespace
    autocmd!

    " Automatically strip whitespace when saving file
    autocmd BufWritePre * :call<SID>Preserve("%s/\\s\\+$//e")
augroup end

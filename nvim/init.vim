call plug#begin()

Plug 'lifepillar/vim-solarized8'

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'

Plug 'machakann/vim-sandwich'

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
nnoremap <leader>v :edit ~/dotfiles/nvim/init.vim<CR>
nnoremap <leader>r :source $MYVIMRC<CR>
nnoremap <leader>l :set list!<CR>
nnoremap <leader>h :set hlsearch!<CR>
nnoremap <leader>= :call <SID>Preserve("normal gg=G")<CR>
nnoremap <leader>b :ls<CR>:b<SPACE>
nnoremap <leader>d :ls<CR>:bd<SPACE>
nnoremap <leader>c :lcd %:h<CR>

" Fugitive mappings
nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>ge :Gedit<CR>
nnoremap <leader>gw :Gwrite<CR>
nnoremap <leader>gr :Gread<CR>
nnoremap <leader>gp :Gpush<CR>
nnoremap <leader>gc :Glcd<CR>

" Make mapping
nnoremap <F7> :make<CR>

" Function to set make mappings correctly
function! SetMakeMappings()
    " Check if a file named "Makefile" exists in the current directory
    if filereadable("./Makefile")
        set makeprg=make
        nnoremap <F5> :make debug<CR>
        nnoremap <F6> :make run<CR>
    else
        if has('win32')
            set makeprg=build-system\build
            nnoremap <F5> :make<CR>:silent !build-system\debug<CR>
            nnoremap <F6> :make<CR>:silent !build-system\run<CR>
        else
            set makeprg=./build-system/build.sh
            nnoremap <F5> :make<CR>:silent !./build-system/debug.sh<CR>
            nnoremap <F6> :make<CR>:silent !./build-system/run.sh<CR>
        end
    endif
endfunction

" Update make mappings autocmd
augroup update_make_mappings
    autocmd!
    autocmd BufWinEnter * call SetMakeMappings()
augroup end

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

" Automatically strip whitespace when saving file
augroup strip_whitespace
    autocmd!
    autocmd BufWritePre * :call<SID>Preserve("%s/\\s\\+$//e")
augroup end

" Always display statusline
augroup display_statusline
    autocmd!
    autocmd BufWinEnter * :set laststatus=2
augroup end

" Configure statusline
set statusline=                             " clear statusline for when vimrc is reloaded
set statusline+=%f                          " path to file in the buffer
set statusline+=%(\ %h%)                    " help flag: [Help] or empty
set statusline+=%(\ %m%)                    " modified flag: [+] or [-] or empty
set statusline+=%(\ %r%)                    " readonly flag: [RO] or empty
set statusline+=%(\ (%{fugitive#head()})%)  " current branch
set statusline+=%=                          " right align
set statusline+=\ Line:\ %l/%L              " current line and total number of lines
set statusline+=\ Col:\ %c                  " column number

" Always show at least 5 lines above and below the cursor
set scrolloff=5

" Always show at least 5 columns left and right of the cursor
set sidescrolloff=5

" Don't automatically continue comment when pressing enter
augroup no_continue_comment
    autocmd!
    autocmd FileType * setlocal formatoptions-=r
augroup end

" Allow hiding buffers with unsaved changes
set hidden

" Ignore case when searching, except when the pattern contains uppercase
" letters
set ignorecase
set smartcase

" Set location of new window when splitting
augroup split_location
    autocmd!
    autocmd BufWinEnter * set nosplitbelow
    autocmd BufWinEnter * set splitright
augroup end

" UltiSnips configuration
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:UltiSnipsEditSplit="vertical"

" I prefer vim-surround keymappings instead of the default vim-sandwich mappings
runtime macros/sandwich/keymap/surround.vim

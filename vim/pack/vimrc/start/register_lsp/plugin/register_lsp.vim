if exists('g:loaded_register_lsp')
    finish
endif
let g:loaded_register_lsp = 1

let s:servers = {}

" Helper function to register server
function! s:register_server(executable, options)
    if executable(a:executable)
        let s:servers[a:executable] = a:options
    endif
endfunction

function! s:do_register() abort
    for l:server in values(s:servers)
        call lsp#register_server(l:server)
    endfor
endfunction

augroup register_lsp_server
    autocmd!
    autocmd User lsp_setup call s:do_register()
augroup end


" Windows: http://releases.llvm.org/download.html
" Ubuntu:  sudo apt install clang-tools-7
"          sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-7 100
call s:register_server('clangd', {
            \ 'name': 'clangd',
            \ 'cmd': {server_info->['clangd']},
            \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
            \ })

" sudo pip install python-language-server
call s:register_server('pyls', {
            \ 'name': 'pyls',
            \ 'cmd': {server_info->['pyls']},
            \ 'whitelist': ['python'],
            \ })

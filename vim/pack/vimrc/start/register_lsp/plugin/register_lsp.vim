if exists('g:loaded_register_lsp')
    finish
endif
let g:loaded_register_lsp = 1

let s:servers = {}

" Augroup for ftplugin
augroup register_lsp_ftplugin
    autocmd!
augroup end

" Helper function to register server
function! s:register_server(executable, options)
    if executable(a:executable)
        let s:servers[a:executable] = a:options

        let l:ft = join(a:options['whitelist'], ',')
        execute 'autocmd register_lsp_ftplugin FileType ' . l:ft  ' call register_lsp#do_ftplugin()'
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

" sudo apt install python3-pip
" sudo pip3 install python-language-server[all]
call s:register_server('pyls', {
            \ 'name': 'pyls',
            \ 'cmd': {server_info->['pyls']},
            \ 'whitelist': ['python'],
            \ })

" sudo apt install npm
" sudo npm install -g typescript-language-server
" sudo npm install -g typescript
call s:register_server('typescript-language-server', {
            \ 'name': 'typescript',
            \ 'cmd': {server_info->['typescript-language-server', '--stdio']},
            \ 'whitelist': ['javascript', 'typescript'],
            \ 'config': { 'filter': { 'name': 'prefix' } }
            \ })

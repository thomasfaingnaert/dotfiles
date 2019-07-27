if exists('g:loaded_register_lsp')
    finish
endif
let g:loaded_register_lsp = 1

augroup register_lsp_server
    autocmd!

    " Windows: http://releases.llvm.org/download.html
    " Ubuntu:
    " sudo apt install clang-tools-7
    " sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-7 100
    if executable('clangd')
        autocmd User lsp_setup call lsp#register_server({
                    \ 'name': 'clangd',
                    \ 'cmd': {server_info->['clangd']},
                    \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
                    \ })
    endif

    " sudo pip install python-language-server
    if executable('pyls')
        autocmd User lsp_setup call lsp#register_server({
                    \ 'name': 'pyls',
                    \ 'cmd': {server_info->['pyls']},
                    \ 'whitelist': ['python'],
                    \ })
    endif
augroup end

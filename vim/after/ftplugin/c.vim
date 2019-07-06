" Language server
" Windows: http://releases.llvm.org/download.html
" Ubuntu:
" sudo apt install clang-tools-7
" sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-7 100
if executable('clangd')
    call lsp#register_server({
                \ 'name': 'clangd',
                \ 'cmd': {server_info->['clangd']},
                \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
                \ })
    setlocal omnifunc=lsp#complete
    setlocal keywordprg=:LspHover
    nnoremap <buffer> <C-]> :LspDefinition<CR>
    nnoremap <buffer> <F2> :LspRename<CR>

    let b:undo_ftplugin .= '|' .
                \ 'setlocal omnifunc< keywordprg< |' .
                \ 'nunmap <buffer> <C-]> |' .
                \ 'nunmap <buffer> <F2>'
endif

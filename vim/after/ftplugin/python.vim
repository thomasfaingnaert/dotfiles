" Language server
" pip install python-language-server
if executable('pyls')
    call lsp#register_server({
                \ 'name': 'pyls',
                \ 'cmd': {server_info->['pyls']},
                \ 'whitelist': ['python'],
                \ })
    setlocal omnifunc=lsp#complete
    setlocal keywordprg=:LspHover
    nnoremap <buffer> <C-]> :LspDefinition<CR>

    let b:undo_ftplugin .=
                \ '| setlocal omnifunc< keywordprg<' .
                \ '| nunmap <buffer> <C-]>'
endif

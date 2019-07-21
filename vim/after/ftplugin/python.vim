" Language server
if executable('pyls')
    setlocal omnifunc=lsp#complete
    setlocal keywordprg=:LspHover
    nnoremap <buffer> <C-]> :LspDefinition<CR>

    let b:undo_ftplugin .=
                \ '| setlocal omnifunc< keywordprg<' .
                \ '| nunmap <buffer> <C-]>'
endif

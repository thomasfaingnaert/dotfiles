if !exists('b:undo_ftplugin')
    let b:undo_ftplugin = 'if 0|endif'
endif

" Language server
if executable('pyls')
    setlocal omnifunc=lsp#complete
    setlocal keywordprg=:LspHover
    nnoremap <buffer> <C-]> :LspDefinition<CR>

    let b:undo_ftplugin .=
                \ '| setlocal omnifunc< keywordprg<' .
                \ '| nunmap <buffer> <C-]>'
endif

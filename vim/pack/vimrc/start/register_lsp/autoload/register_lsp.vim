function! register_lsp#do_ftplugin() abort
    setlocal omnifunc=lsp#complete
    setlocal keywordprg=:LspHover
    nnoremap <buffer> <C-]> :LspDefinition<CR>
    nnoremap <buffer> <F2> :LspRename<CR>

    let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
                \ . '| setlocal omnifunc< keywordprg<'
                \ . '| nunmap <buffer> <C-]>'
                \ . '| nunmap <buffer> <F2>'
endfunction
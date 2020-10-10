if executable('clang-format')
    let &l:equalprg = "clang-format"

    augroup cpp_auto_format
        autocmd!
        autocmd BufWritePre <buffer> call preserve_state#execute("silent normal gg=G") | redraw!
    augroup end

    setlocal shiftwidth=2 softtabstop=2 smartindent

    let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
                \ . '| setlocal equalprg<'
                \ . '| execute ''autocmd! cpp_auto_format'''
                \ . '| setlocal shiftwidth< softtabstop< smartindent<'
endif

if has('nvim')
    nnoremap <buffer> <silent> \ll :silent TexlabBuild<CR>
    nnoremap <buffer> <silent> \lv :silent TexlabForward<CR>

    let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
                \ . '| nunmap <buffer> \ll'
                \ . '| nunmap <buffer> \lv'
endif

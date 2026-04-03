if has('nvim')
    nnoremap <buffer> <silent> \ll :silent LspTexlabBuild<CR>
    nnoremap <buffer> <silent> \lv :silent LspTexlabForward<CR>

    let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
                \ . '| nunmap <buffer> \ll'
                \ . '| nunmap <buffer> \lv'
endif

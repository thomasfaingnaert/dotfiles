let b:quick_run_command = ['dot', '-Tpdf', '%', '-o', '%:r.pdf']

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
            \ . '| unlet b:quick_run_command'

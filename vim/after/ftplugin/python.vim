let b:quick_run_command = ['python3', '%']

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
            \ . '| unlet b:quick_run_command'

setlocal commentstring=//\ %s
let b:quick_run_command = ['asciidoctor-pdf', '%']

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
            \ . '| setlocal commentstring<'
            \ . '| unlet b:quick_run_command'

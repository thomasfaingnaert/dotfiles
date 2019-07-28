setlocal shiftwidth=2 softtabstop=2

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
            \ . '| setlocal shiftwidth< softtabstop<'

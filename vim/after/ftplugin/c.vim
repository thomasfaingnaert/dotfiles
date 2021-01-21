setlocal formatoptions-=o
setlocal formatoptions-=r

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
            \ . '| setlocal formatoptions<'

setlocal shiftwidth=2 softtabstop=2

if !exists('b:undo_ftplugin')
    let b:undo_ftplugin = 'if 0|endif'
endif
let b:undo_ftplugin .= '| setlocal shiftwidth< softtabstop<'

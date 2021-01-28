if executable('clang-format')
    let &l:equalprg = 'clang-format'
endif

setlocal formatoptions-=o
setlocal formatoptions-=r

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
            \ . '| setlocal equalprg<'
            \ . '| setlocal formatoptions<'

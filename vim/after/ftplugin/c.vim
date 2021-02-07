if executable('clang-format')
    let &l:equalprg = 'clang-format'
endif

setlocal formatoptions-=o
setlocal formatoptions-=r
compiler ninja

function! s:ListNinjaTargets(A, L, P)
    return system("ninja -C build -t targets depth 1 | cut -d: -f1")
endfunction

command -complete=custom,<SID>ListNinjaTargets -nargs=? Target let g:ninja_target=<q-args> | compiler ninja

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
            \ . '| setlocal equalprg<'
            \ . '| setlocal formatoptions<'

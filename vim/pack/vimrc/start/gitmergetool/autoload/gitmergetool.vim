" Turn off diff in all windows.
function! gitmergetool#diff_off_all()
    let l:win_count = winnr('$')
    let l:current = winnr()

    for i in range(1, l:win_count)
        execute i . 'wincmd w'
        diffoff
    endfor

    execute l:current . 'wincmd w'
endfunction

" Enable diff for specific windows (1-indexed).
function! gitmergetool#diff_windows(windows)
    call gitmergetool#diff_off_all()

    let l:current = winnr()

    for win in a:windows
        if win <= winnr('$')
            execute win . 'wincmd w'
            diffthis
        endif
    endfor

    execute l:current . 'wincmd w'
    diffupdate
endfunction

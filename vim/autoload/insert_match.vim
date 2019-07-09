function! insert_match#insert_match()
    " Position of last unmatched pair
    let l:line_last = 0
    let l:col_last = 0
    let l:end_last = ''

    for [l:start, l:end] in [['(', ')'], ['{', '}'], ['[', ']']]
        let [l:line, l:col] = searchpairpos(l:start, '', l:end, 'bWn')

        " Did we find a match?
        if (l:line != 0) || (l:col != 0)
            " Check if it is later in file than previous match
            let l:is_later = (l:line > l:line_last) || (l:line == l:line_last && l:col > l:col_last)

            if l:is_later
                let [l:line_last, l:col_last, l:end_last] = [l:line, l:col, l:end]
            endif
        endif
    endfor

    if (l:line_last == 0) && (l:col_last == 0)
        echohl ErrorMsg
        echo 'No unclosed pair found.'
        echohl None
    endif

    return l:end_last
endfunction

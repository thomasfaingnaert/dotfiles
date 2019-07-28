function! operator_grep#operator_grep(type) abort
    " Save unnamed register
    let l:old_unnamed_reg = @"

    " Yank the text we want to grep for into the unnamed register
    if a:type ==# 'v'
        normal! `<yv`>
    elseif a:type ==# 'char'
        normal! `[yv`]
    else
        " Grep'ing doesn't make sense for non-characterwise motions
        echohl Error
        echom 'Grep operator works with characterwise motions only.'
        echohl None
        return
    endif

    " Perform grep
    let l:search_term = escape(@", '#%')
    silent execute 'grep! -r ' . shellescape(l:search_term) . ' *'

    " Restore unnamed register
    let @" = l:old_unnamed_reg
endfunction

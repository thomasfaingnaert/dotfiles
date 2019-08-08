function! gitrebase#squash_all() abort
    " Store view of current window
    let l:view = winsaveview()

    " Squash commits
    for l:i in range(1, line('$'))
        silent execute l:i . "normal! :Fixup\<CR>"
    endfor

    " Reword first commit
    silent execute "1normal! :Reword\<CR>"

    " Restore view
    call winrestview(l:view)
endfunction

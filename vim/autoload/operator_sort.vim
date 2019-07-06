function! operator_sort#operator_sort(type, ...)
    if a:0 " Visual mode?
        '<,'> sort
    else
        '[,'] sort
    endif
endfunction

function! textobj_document#select_i()
    " Go to the end of the file, and search backwards for a non-empty line
    normal! G
    call search('^.', 'bcW')

    " Enter linewise visual mode
    normal! V

    " Go the the beginning of the file, and search forwards for a non-empty
    " line
    normal! gg
    call search('^.', 'cW')
endfunction

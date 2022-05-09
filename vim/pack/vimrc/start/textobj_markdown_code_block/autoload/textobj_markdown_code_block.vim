function! textobj_markdown_code_block#select_a() abort
    " Search backwards for a ``` at the beginning of a line
    call search('^```', 'bcW')

    " Enter linewise visual mode
    normal! V

    " Go down a line, otherwise we will match the same ```
    normal! j

    " Search forwards for a ``` at the beginning of a line
    call search('^```', 'cW')

    " Go to the top of the selection
    normal! o
endfunction

function! textobj_markdown_code_block#select_i() abort
    " Search backwards for a ``` at the beginning of a line
    call search('^```', 'bcW')

    " Go down a line, since we only want to match inside of the ```
    normal! j

    " Enter linewise visual mode
    normal! V

    " Search forwards for a ``` at the beginning of a line
    call search('^```', 'cW')

    " Go up a line, since we only want to match inside of the ```
    normal! k

    " Go to the top of the selection
    normal! o
endfunction

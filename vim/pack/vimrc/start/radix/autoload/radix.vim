function! radix#dec2hex(line1, line2, arg)
    if empty(a:arg)
        " Case 1: called without an argument, e.g. :Dec2hex

        " Check if the command was executed using a visual selection.
        " If so, we add '\%V' to the regex.
        let l:vis = (histget(':', -1) =~# "^'<,'>") ? '\%V' : ''
        let l:cmd = 's/' . l:vis . '\<\d*' . l:vis . '\d\>/\=printf("0x%x", str2nr(submatch(0), 10))/g'

        try
            execute a:line1 . ',' . a:line2 . l:cmd
        catch
            echohl ErrorMsg
            echo 'Error: No decimal numbers found.'
            echohl None
        endtry
    else
        " Case 2: called with an argument, e.g. :Dec2hex 10
        echo printf('0x%x', str2nr(a:arg, 10))
    endif
endfunction

function! radix#hex2dec(line1, line2, arg)
    if empty(a:arg)
        " Case 1: called without an argument, e.g. :Hex2dec

        " Check if the command was executed using a visual selection.
        " If so, we add '\%V' to the regex.
        let l:vis = (histget(':', -1) =~# "^'<,'>") ? '\%V' : ''
        let l:cmd = 's/' . l:vis . '\<0x\x*' . l:vis . '\x\>/\=printf("%d", str2nr(submatch(0), 16))/g'

        try
            execute a:line1 . ',' . a:line2 . l:cmd
        catch
            echohl ErrorMsg
            echo 'Error: No hexadecimal numbers found.'
            echohl None
        endtry
    else
        " Case 2: called with an argument, e.g. :Hex2dec 0xa or :Hex2dec a
        echo printf('%d', str2nr(a:arg, 16))
    endif
endfunction

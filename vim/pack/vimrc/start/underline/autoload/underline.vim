"" Transform the text to an underline
function! underline#get_underlined_text(text, char) abort
    " Replace all characters in text by char, ignoring leading and trailing
    " whitespace.
    return substitute(a:text, '^\s*\zs.\{-}\ze\s*$', '\=repeat(''' . a:char . ''', len(submatch(0)))', '')
endfunction

"" Underline current line
function! underline#underline(above) abort
    " Save cursor position
    let l:pos = getcurpos()

    " Prompt for character to underline with
    let l:char = getchar()

    " Use <Esc> to cancel
    if l:char != 27
        if a:above
            " Duplicate current line above
            t-1

            " Because of the extra line, we want the cursor one down
            let l:pos[1] += 1
        else
            " Duplicate current line below
            t.
        endif

        " Get the comment strings for the current filetype
        let l:comment_strings = get(b:, 'underline_patterns', [&commentstring])

        " Transform comment strings into regular expressions
        let l:regular_expressions = []

        for l:comment_string in l:comment_strings
            call add(l:regular_expressions, '\V' . substitute(l:comment_string, '%s', '\\zs\\.\\*\\ze', ''))
        endfor

        " Add default regex that for non-comment lines. Note that this regex
        " ignores leading whitespace in a line.
        call add(l:regular_expressions, '\V\^\s\*\zs\.\*\$')

        " Find the first regex that matches the current line
        for l:regex in l:regular_expressions
            " We need to escape /
            let l:escaped_regex = escape(l:regex, '/')
            let l:line = getline('.')

            if l:line =~# l:regex
                " Perform underline
                execute 's/' . l:escaped_regex . '/\=underline#get_underlined_text(submatch(0), ''' . nr2char(l:char) . ''')/e'

                " Stop looking for match
                break
            endif
        endfor
    endif

    " Restore cursor position
    call setpos('.', l:pos)
endfunction

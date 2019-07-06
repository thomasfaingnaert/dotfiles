"" Underline current line
function! underline#underline(above) abort
    " Save cursor position
    let l:pos = getcurpos()

    " Prompt for character to underline with
    let l:char = getchar()

    " Use <Esc> to cancel
    if l:char != 27
        " Underline current line with chosen character
        if a:above
            execute "t-1 \| snomagic/\\./" . nr2char(l:char) . "/ge"

            " Because of the extra line, we want the cursor one down
            let l:pos[1] += 1
        else
            execute "t. \| snomagic/\\./" . nr2char(l:char) . "/ge"
        endif
    endif

    " Restore cursor position
    call setpos('.', l:pos)
endfunction

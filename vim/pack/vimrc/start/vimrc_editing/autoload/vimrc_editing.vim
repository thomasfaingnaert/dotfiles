let s:dotfiles = has('win32') ? '~/dotfiles' : '~/.dotfiles'
let s:myvimrc = s:dotfiles . '/vim/vimrc'

function! vimrc_editing#edit_vimrc() abort
    if expand('%:p') !=# expand(s:myvimrc)
        execute 'edit ' . s:myvimrc

        " Set working directory to directory of vimrc
        lcd %:h
    else
        " Restore old working directory, but only if it hasn't changed
        if getcwd() ==# expand('%:p:h')
            lcd -
        endif

        write
        bdelete
    endif
endfunction

function! vimrc_editing#foldexpr() abort
    let l:thisline = getline(v:lnum)

    " Level 2 and level 3 folds
    if match(l:thisline, '^"""') >= 0
        return '>3'
    elseif match(l:thisline, '^""') >= 0
        return '>2'
    endif

    " Level 1 fold
    if line(v:lnum) + 2 <= line('$')
        let l:nextline = getline(v:lnum + 1)
        let l:nextnextline = getline(v:lnum + 2)

        if match(thisline, '^"\s*-') >= 0 && match(nextline, '^"') >= 0 && match(nextnextline, '^"\s*-') >= 0
            return '>1'
        endif
    endif

    " No fold
    return '='
endfunction

function! vimrc_editing#foldtext() abort
    let l:level = v:foldlevel
    let l:foldsize = v:foldend - v:foldstart
    let l:linecount = '(' . l:foldsize . (foldsize == 1 ? ' line' : ' lines') . ')'

    if l:level == 1
        let l:marker = '●'
    elseif l:level == 2
        let l:marker = '    ○'
    else
        let l:marker = '        -'
    end

    if l:level == 1
        let l:title = substitute(getline(v:foldstart + 1), '^"\s*', '', '')
    else
        let l:title = substitute(getline(v:foldstart), '^"\+\s*', '', '')
    endif

    return l:marker . ' ' . l:title . ' ' . l:linecount
endfunction

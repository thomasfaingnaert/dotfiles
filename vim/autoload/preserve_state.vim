" Preserve "state" and execute command
" (Source: http://vimcasts.org/episodes/tidying-whitespace/)
function! preserve_state#execute(command)
    let l:win_view = winsaveview()
    let l:last_search = getreg('/')
    execute 'keepjumps ' . a:command
    call winrestview(l:win_view)
    call setreg('/', l:last_search)
endfunction

"" Move/create window
" Source:
" http://www.agillo.net/simple-vim-window-management/
" https://aonemd.github.io/blog/handy-keymaps-in-vim

function! window_move#window_move(key) abort
    " Save old window
    let l:current_window = winnr()

    " Execute movement
    execute 'wincmd ' . a:key

    " Check if we have changed window
    if (l:current_window == winnr())
        " If not, create a new split
        if (a:key =~# '[hl]')
            wincmd v
        else
            wincmd s
        endif

        " Move to that new split
        execute 'wincmd ' . a:key
    endif
endfunction

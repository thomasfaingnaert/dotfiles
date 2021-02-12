let s:bufnr = -1
let s:lastcmd = []

function! quick_run#run(is_bang, ...)
    if a:is_bang
        let s:lastcmd = []
        echo 'Reset default :Run command.'
        return
    endif

    if len(a:000) > 0
        let l:cmd = a:000
    else
        let l:cmd = s:lastcmd
    endif

    if len(l:cmd) == 0
        if exists('b:quick_run_command')
            let l:cmd = b:quick_run_command
        else
            let l:cmd = ['make']
        endif
    endif

    let s:lastcmd = l:cmd

    " Close previous buffer
    if s:bufnr != -1
        silent! execute 'bdelete' s:bufnr
    endif

    " Map % to current buffer name etc
    let l:expanded_cmd = deepcopy(l:cmd)
    call map(l:expanded_cmd, {_, val -> expand(val)})

    let s:bufnr = term_start(l:expanded_cmd)

    " Switch back to previous window
    wincmd w
endfunction

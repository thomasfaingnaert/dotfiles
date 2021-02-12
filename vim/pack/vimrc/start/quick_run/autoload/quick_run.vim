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

    " Map % to current buffer name etc
    let l:expanded_cmd = deepcopy(l:cmd)

    " Regex of expandable strings
    " Inspired by:
    " https://github.com/tpope/vim-dispatch/blob/fe6a34322829e466a7e8ce710a6ac5eabddff9fd/autoload/dispatch.vim#L93-L109
    let l:expandable = '[%#]\%(:[p8~.htreS]\)*'
    call map(l:expanded_cmd, {_, val -> substitute(val, l:expandable, '\=expand(submatch(0))', 'g')})

    " Reuse previous window, if possible
    let l:winnrs = win_findbuf(s:bufnr)
    if !empty(l:winnrs)
        let l:winnr = l:winnrs[0]

        call win_execute(l:winnr, 'let s:bufnr = term_start(l:expanded_cmd, {"curwin": 1})')
    else
        let s:bufnr = term_start(l:expanded_cmd, {'vertical': 1})

        " Switch back to previous window
        wincmd w
    endif
endfunction

let s:bufnr = -1
let s:lastcmd = []
let s:title = ''

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

    " Set title
    let s:title = join(l:expanded_cmd)

    " Run using the shell, so we can do '&&' etc.
    let l:expanded_cmd = [&shell, &shellcmdflag, join(l:expanded_cmd)]

    " Reuse previous window, if possible
    let l:winnrs = win_findbuf(s:bufnr)
    if !empty(l:winnrs)
        let l:winnr = l:winnrs[0]

        call win_execute(l:winnr, 'let s:bufnr = term_start(l:expanded_cmd, {"curwin": 1, "exit_cb" : function("s:on_exit"), "term_name" : s:title})')
    else
        let s:bufnr = term_start(l:expanded_cmd, {'vertical': 1, 'exit_cb' : function('s:on_exit'), 'term_name' : s:title})

        " Switch back to previous window
        wincmd w
    endif
endfunction

function! s:on_exit(job, status)
    let l:winids = win_findbuf(s:bufnr)

    if empty(l:winids)
        return
    endif

    let l:winid = l:winids[0]

    " Wait for buffer content to be up to date
    call term_wait(s:bufnr, 1000)

    " Populate quickfix window
    call win_execute(l:winid, 'cgetbuffer')

    " Set quickfix title
    call setqflist([], 'a', {'title': s:title})
endfunction

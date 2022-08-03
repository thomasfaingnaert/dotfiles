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

    " Store current window ID
    let l:curwin = win_getid()

    " Reuse previous window, if possible.
    " Otherwise, just open a new split
    let l:winids = win_findbuf(s:bufnr)
    if !empty(l:winids)
        call win_gotoid(l:winids[0])
    else
        vsplit
    endif

    " Edit new file, so that we can open a terminal in this buffer.
    enew!

    " Start terminal
    if !has('nvim')
        let s:bufnr = term_start(l:expanded_cmd, {'exit_cb' : function('s:on_exit'), 'term_name' : s:title, 'curwin' : 1})
    else
        call termopen(l:expanded_cmd, {'on_exit' : function('s:on_exit')})
        let s:bufnr = bufnr()
    endif

    " Restore previous window
    call win_gotoid(l:curwin)
endfunction

function! s:on_exit(...)
    if !has('nvim')
        " Wait for buffer content to be up to date
        call term_wait(s:bufnr, 1000)
    endif

    " Populate quickfix window
    execute 'cgetbuffer' s:bufnr

    " Set quickfix title
    call setqflist([], 'a', {'title': s:title})
endfunction

function! quick_run#autorun(is_bang, ...)
    if a:is_bang
        augroup quick_run
            autocmd!
        augroup END

        echo 'Disabled autorunning.'
        return
    endif

    if a:0 > 0
        let l:pattern = a:1
    else
        let l:pattern = '*'
    endif

    augroup quick_run
        autocmd!
    augroup END

    execute 'autocmd quick_run BufWritePost ' . l:pattern . ' Run'

    echo 'Executing :Run automatically when files of pattern "' . l:pattern . '" are saved'
endfunction

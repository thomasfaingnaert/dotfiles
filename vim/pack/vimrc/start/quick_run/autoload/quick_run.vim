let s:compilers = {}
let s:bufnr = -1
let s:lastcmd = []
let s:compiler = ''

function! quick_run#run(is_bang, ...)
    " Initialise compilers, if not done already
    call s:init_compilers()

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

    " Get correct compiler for executable
    let s:compiler = get(s:compilers, l:cmd[0], '')

    let s:bufnr = term_start(l:expanded_cmd, {'exit_cb': function('s:exit_callback')})

    " Switch back to previous window
    wincmd w
endfunction

function s:init_compilers() abort
    if !empty(s:compilers)
        return
    endif

    " Inspired by
    " https://github.com/tpope/vim-dispatch/blob/fe6a34322829e466a7e8ce710a6ac5eabddff9fd/autoload/dispatch.vim#L610
    let l:compiler_files = map(split(globpath(&rtp, 'compiler/*.vim'), '\n'), {_, val -> [fnamemodify(val, ':t:r'), readfile(val)]})

    for [l:compiler_name, l:lines] in l:compiler_files
        for l:line in l:lines
            let l:match = matchstr(l:line, '\<CompilerSet\s\+makeprg=\zs[a-zA-Z0-9_.-]\+\ze')

            if !empty(l:match)
                let s:compilers[l:match] = l:compiler_name
            endif
        endfor
    endfor
endfunction

function! s:exit_callback(job, status) abort
    " NOTE: We cannot directly fill the quickfix here.
    "       We have to do it via a timer...
    call timer_start(0, function('s:fill_quickfix'))
endfunction

function! s:fill_quickfix(timer) abort
    let l:winids = win_findbuf(s:bufnr)

    if empty(l:winids)
        return
    endif

    let l:winid = l:winids[0]

    " Set correct errorformat
    if !empty(s:compiler)
        call win_execute(l:winid, 'compiler ' . s:compiler)
    endif

    " Populate quickfix window
    call win_execute(l:winid, 'cgetbuffer')
endfunction

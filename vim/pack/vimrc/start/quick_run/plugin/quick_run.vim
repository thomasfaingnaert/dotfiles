if exists('g:loaded_quick_run')
    finish
endif
let g:loaded_quick_run = 1

" Run command in terminal, and populate the quickfix
" The command is the first entry that applies in this list:
" - The command specified as argument
" - The last run command using :Run <cmd>
" - A buffer specific command (eg to run a bash file)
" - The value of the 'makeprg' variable
" The buffer specific command can be specified by setting
" the b:quick_run_command variable.
" If ! is specified, resets the last executed command back to default.
command -bang -nargs=* -complete=shellcmd Run call quick_run#run(<bang>0, <f-args>)

nnoremap <silent> <Plug>quick_run :Run<CR>

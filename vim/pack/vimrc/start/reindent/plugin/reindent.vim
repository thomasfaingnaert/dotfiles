if exists('g:loaded_reindent')
    finish
endif
let g:loaded_reindent = 1

command -nargs=* Reindent call reindent#reindent(<f-args>)

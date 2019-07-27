if exists('g:loaded_insert_match')
    finish
endif
let g:loaded_insert_match = 1

inoremap <expr> <Plug>insert_match insert_match#insert_match()

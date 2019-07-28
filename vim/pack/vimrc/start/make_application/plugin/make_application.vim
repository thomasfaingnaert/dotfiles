if exists('g:loaded_make_application')
    finish
endif
let g:loaded_make_application = 1

nnoremap <silent> <Plug>make_application :call make_application#make_application()<CR>

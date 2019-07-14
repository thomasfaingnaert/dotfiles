if exists('g:loaded_operator_grep')
    finish
endif
let g:loaded_operator_grep = 1

nnoremap <silent> <Plug>operator_grep :set operatorfunc=operator_grep#operator_grep<CR>g@
xnoremap <silent> <Plug>operator_grep :<C-u>call operator_grep#operator_grep(visualmode())<CR>

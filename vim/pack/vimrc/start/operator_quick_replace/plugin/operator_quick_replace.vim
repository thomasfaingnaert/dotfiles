if exists('g:loaded_operator_quick_replace')
    finish
endif
let g:loaded_operator_quick_replace = 1

nnoremap <silent> <Plug>operator_quick_replace :call operator_quick_replace#save_word()<CR>:set operatorfunc=operator_quick_replace#replace<CR>g@
xnoremap <silent> <Plug>operator_quick_replace :<C-u>call operator_quick_replace#save_selection()<CR>:set operatorfunc=operator_quick_replace#replace<CR>g@

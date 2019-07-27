if exists('g:loaded_operator_sort')
    finish
endif
let g:loaded_operator_sort = 1

nnoremap <silent> <Plug>operator_sort :set operatorfunc=operator_sort#operator_sort<CR>g@
xnoremap <silent> <Plug>operator_sort :<C-u>call operator_sort#operator_sort(visualmode(), 1)<CR>

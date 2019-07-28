if exists('g:loaded_operator_format_paragraph')
    finish
endif
let g:loaded_operator_format_paragraph = 1

nnoremap <Plug>operator_format_paragraph :set operatorfunc=operator_format_paragraph#format<CR>g@
xnoremap <Plug>operator_format_paragraph :<C-u>call operator_format_paragraph#format(visualmode(), 1)<CR>

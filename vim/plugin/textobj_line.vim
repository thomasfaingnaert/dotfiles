if exists('g:loaded_textobj_line')
    finish
endif
let g:loaded_textobj_line = 1

xnoremap <Plug>textobj_line_a g_o0
onoremap <Plug>textobj_line_a :<C-u>normal! vg_o0<CR>

xnoremap <Plug>textobj_line_i g_o^
onoremap <Plug>textobj_line_i :<C-u>normal! vg_o^<CR>

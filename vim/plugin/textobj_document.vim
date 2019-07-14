if exists('g:loaded_textobj_document')
    finish
endif
let g:loaded_textobj_document = 1

xnoremap <silent> <Plug>textobj_document_a GoggV
onoremap <silent> <Plug>textobj_document_a :<C-u>normal! VGogg<CR>

xnoremap <silent> <Plug>textobj_document_i :<C-u>call textobj_document#select_i()<CR>
onoremap <silent> <Plug>textobj_document_i :<C-u>call textobj_document#select_i()<CR>

if exists('g:loaded_textobj_markdown_code_block')
    finish
endif
let g:loaded_textobj_markdown_code_block = 1

xnoremap <silent> <Plug>textobj_markdown_code_block_a :<C-u>call textobj_markdown_code_block#select_a()<CR>
onoremap <silent> <Plug>textobj_markdown_code_block_a :<C-u>call textobj_markdown_code_block#select_a()<CR>

xnoremap <silent> <Plug>textobj_markdown_code_block_i :<C-u>call textobj_markdown_code_block#select_i()<CR>
onoremap <silent> <Plug>textobj_markdown_code_block_i :<C-u>call textobj_markdown_code_block#select_i()<CR>

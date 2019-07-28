if exists('g:loaded_font_size')
    finish
endif
let g:loaded_font_size = 1

nnoremap <silent> <Plug>font_size_increase :call font_size#increment(+1)<CR>
nnoremap <silent> <Plug>font_size_decrease :call font_size#increment(-1)<CR>
nnoremap <silent> <Plug>font_size_reset :call font_size#reset()<CR>

if exists('g:loaded_quick_replace')
    finish
endif
let g:loaded_quick_replace = 1

" Save the word under the cursor when entering visual mode
nnoremap v :call quick_replace#save_word()<CR>v
nnoremap V :call quick_replace#save_word()<CR>V
nnoremap <C-v> :call quick_replace#save_word()<CR><C-v>

nnoremap <silent> <Plug>quick_replace :call quick_replace#save_word()<CR>:set operatorfunc=quick_replace#quick_replace<CR>g@
xnoremap <silent> <Plug>quick_replace :<C-u>call quick_replace#quick_replace(visualmode(), 1)<CR>

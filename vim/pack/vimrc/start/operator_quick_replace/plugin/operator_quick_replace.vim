if exists('g:loaded_operator_quick_replace')
    finish
endif
let g:loaded_operator_quick_replace = 1

" Save the word under the cursor when entering visual mode
nnoremap v :call operator_quick_replace#save_word()<CR>v
nnoremap V :call operator_quick_replace#save_word()<CR>V
nnoremap <C-v> :call operator_quick_replace#save_word()<CR><C-v>

nnoremap <silent> <Plug>operator_quick_replace :call operator_quick_replace#save_word()<CR>:set operatorfunc=operator_quick_replace#quick_replace<CR>g@
xnoremap <silent> <Plug>operator_quick_replace :<C-u>call operator_quick_replace#quick_replace(visualmode(), 1)<CR>

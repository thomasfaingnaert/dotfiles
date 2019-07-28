if exists('g:loaded_uderline')
    finish
endif
let g:loaded_uderline = 1

nnoremap <silent> <Plug>underline_above :call underline#underline(0)<CR>
nnoremap <silent> <Plug>underline_below :call underline#underline(1)<CR>

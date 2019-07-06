" Save word under cursor
function! quick_replace#save_word()
    let s:word = expand('<cword>')
endfunction

" Pre-fill the Ex command to replace
function! quick_replace#quick_replace(type, ...)
    if a:0
        call feedkeys(":'<,'>s/\\<" . s:word . "\\>//g\<Left>\<Left>")
    else
        call feedkeys(":'[,']s/\\<" . s:word . "\\>//g\<Left>\<Left>")
    endif
endfunction

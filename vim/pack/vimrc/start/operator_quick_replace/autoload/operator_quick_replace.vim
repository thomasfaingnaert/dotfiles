" Save word under cursor
function! operator_quick_replace#save_word() abort
    let s:word = expand('<cword>')
endfunction

" Pre-fill the Ex command to replace
function! operator_quick_replace#quick_replace(type, ...) abort
    if a:0
        call feedkeys(":'<,'>s/\\<" . s:word . "\\>//g\<Left>\<Left>")
    else
        call feedkeys(":'[,']s/\\<" . s:word . "\\>//g\<Left>\<Left>")
    endif
endfunction

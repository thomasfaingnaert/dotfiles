" Pre-fill the Ex command to replace
function! operator_quick_replace#replace(type) abort
    call feedkeys(":'[,']s/" . s:term . "//g\<Left>\<Left>")
endfunction

function! operator_quick_replace#save_word() abort
    let s:term = '\<' . expand('<cword>') . '\>'
endfunction

function! operator_quick_replace#save_selection() abort
    let l:old_unnamed_reg = @"
    normal! `<yv`>
    let s:term = '\V' . @"
    let @" = l:old_unnamed_reg
endfunction

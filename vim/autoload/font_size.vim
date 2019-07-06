" Save the default font
if !exists('s:default_font')
    let s:default_font = &guifont
endif

" Increment/decrement fontsize
function! font_size#increment(amount) abort
    let l:min_font_size = 8
    let l:max_font_size = 60

    if has('win32')
        let l:pattern = '^\(.*:h\)\([1-9][0-9]*\)$'
    else
        let l:pattern = '^\(.* \)\([1-9][0-9]*\)$'
    endif

    let l:font = substitute(&guifont, l:pattern, '\1', '')
    let l:size = substitute(&guifont, l:pattern, '\2', '')
    let l:new_size = l:size + a:amount

    if (l:new_size >= l:min_font_size) && (l:new_size <= l:max_font_size)
        let &guifont = l:font . l:new_size
    endif

    set lines=999 columns=999
endfunction

" Reset default fontsize
function! font_size#reset() abort
    let &guifont = s:default_font
    set lines=999 columns=999
endfunction

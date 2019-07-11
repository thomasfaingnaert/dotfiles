"" Make and run current application
function! make_application#make_application() abort
    " Clear screen
    if has('win32')
        silent !cls
    else
        silent !clear
    endif

    " Build and run the project (filetype dependent)
    if &filetype ==# 'python'
        !python3 %
    elseif &filetype ==# 'sh'
        !bash %
    elseif &filetype ==# 'vim'
        source %
    elseif &filetype ==# 'asciidoc'
        !asciidoctor %
    else
        make
    endif
endfunction

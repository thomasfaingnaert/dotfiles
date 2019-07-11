function! insert_skip#insert_skip(char) abort
    return strpart(getline('.'), col('.') - 1, 1) !=# a:char ? a:char : "\<Right>"
endfunction

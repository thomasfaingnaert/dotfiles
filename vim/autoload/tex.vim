function! tex#sort_packages() abort
    let l:options = ''
                \ . '/'
                \ .     '\('
                \ .         '^\\usepackage'
                \ .         '\('
                \ .             '\['
                \ .             '[^\]]*'
                \ .             '\]'
                \ .         '\)\?'
                \ .         '{'
                \ .     '\)\?'
                \ . '/'

    call preserve_state#execute('g/\n\n^\\usepackage/ +2;''}- sort ' . l:options)
endfunction

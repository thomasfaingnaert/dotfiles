"" Format paragraph: all sentences on new line
function! format_paragraph#format_paragraph(type, ...) abort
    " Join all lines, taking care to not remove paragraph breaks.
    " This is accomplished by only joining lines with at least one non-space
    " character.
    silent '[,']smagic/\(\S\s*\)\n\(\s*\S\)/\1 \2/ge

    " Add a linebreak after all punctuation (.?!) followed by at least one
    " space and a capital letter, and remove that whitespace.
    silent '[,']smagic/\([.?!]\)\s\+\ze[A-Z]/\1\r/ge
endfunction

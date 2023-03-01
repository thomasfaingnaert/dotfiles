highlight clear
if exists("syntax_on")
    syntax reset
endif

" Load the base 'codedark' colorscheme.
runtime colors/codedark.vim

" Override the name of the base colorscheme.
let g:colors_name = "mycodedark"

" Allow syntax highlighting in diff chunks.
highlight DiffAdd guifg=NONE
highlight DiffChange guifg=NONE
highlight DiffDelete guifg=NONE
highlight DiffText guifg=NONE

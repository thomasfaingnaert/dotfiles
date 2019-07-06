highlight clear
if exists('syntax_on')
    syntax reset
endif

" Load NeoSolarized
runtime colors/NeoSolarized.vim

" Override the name of the base color scheme
let g:colors_name = 'NeoSolarizedCustom'

highlight PopupWindow guibg=#fdf6e3
highlight PopupWindowDark guibg=#f9e7b6

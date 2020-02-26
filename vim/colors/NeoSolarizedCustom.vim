highlight clear
if exists('syntax_on')
    syntax reset
endif

" Load NeoSolarized
runtime colors/NeoSolarized.vim

" Override the name of the base color scheme
let g:colors_name = 'NeoSolarizedCustom'

" Popup window colours
highlight PopupWindow guibg=#fdf6e3
highlight PopupWindowDark guibg=#f9e7b6

" Diff colours
highlight clear DiffAdd
highlight clear DiffChange
highlight clear DiffText
highlight clear DiffDelete

highlight DiffAdd    ctermbg=85  guibg=#e6ffed
highlight DiffChange ctermbg=230 guibg=#fffbdd
highlight DiffText   ctermbg=222 guibg=#f2e496
highlight DiffDelete ctermbg=167 guibg=#ffeef0

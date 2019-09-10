" Conceal ends of markdown `inline code`.
if has('conceal')
    syntax region CursorLine matchgroup=markdownCodeDelimiter start="`\ze[^`]" end="`" keepend contains=markdownLineStart concealends
endif

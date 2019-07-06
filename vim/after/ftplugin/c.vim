" Language server
" Windows: http://releases.llvm.org/download.html
" Ubuntu:
" sudo apt install clang-tools-7
" sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-7 100
if executable('clangd')
    call lsp#register_server({
                \ 'name': 'clangd',
                \ 'cmd': {server_info->['clangd']},
                \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
                \ })
    setlocal omnifunc=lsp#complete
    setlocal keywordprg=:LspHover
    nnoremap <buffer> <C-]> :LspDefinition<CR>
    nnoremap <buffer> <F2> :LspRename<CR>

    let b:undo_ftplugin .= '|' .
                \ 'setlocal omnifunc< keywordprg< |' .
                \ 'nunmap <buffer> <C-]> |' .
                \ 'nunmap <buffer> <F2>'
endif

if executable('clang-format')
    let s:clang_format_settings = {
                \       "BasedOnStyle": "LLVM",
                \       "AccessModifierOffset": -4,
                \       "AllowShortFunctionsOnASingleLine": "Inline",
                \       "BreakBeforeBraces": "Allman",
                \       "IncludeBlocks": "Regroup",
                \       "IndentWidth": 4
                \   }

    let &l:equalprg = "clang-format -style='" . json_encode(s:clang_format_settings) . "'"

    augroup cpp_auto_format
        autocmd!
        autocmd BufWritePre <buffer> call preserve_state#execute("silent normal gg=G")
    augroup end

    let b:undo_ftplugin .= '|' .
                \ 'setlocal equalprg< |' .
                \ 'autocmd! cpp_auto_format'
endif

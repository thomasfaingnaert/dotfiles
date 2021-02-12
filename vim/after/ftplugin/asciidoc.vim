setlocal commentstring=//\ %s
let b:quick_run_command = ['asciidoctor-pdf', '%']

nnoremap <buffer> <silent> \lv :silent call system('xdg-open ' . expand('%:r') . '.pdf')<CR>

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
            \ . '| setlocal commentstring<'
            \ . '| unlet b:quick_run_command'
            \ . '| nunmap <buffer> \lv'

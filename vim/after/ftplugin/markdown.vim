let b:quick_run_command = ['pandoc', '%', '-o', '%:r.pdf']

nnoremap <buffer> <silent> \lv :silent call system('xdg-open ' . expand('%:r') . '.pdf')<CR>

setlocal commentstring=<!--%s-->

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
            \ . '| unlet b:quick_run_command'
            \ . '| nunmap <buffer> \lv'
            \ . '| setlocal commentstring<'

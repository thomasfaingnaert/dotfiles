let b:quick_run_command = ['pandoc', '%', '-o', '%:r.pdf']

nnoremap <buffer> <silent> \lv :silent call system('xdg-open ' . expand('%:r') . '.pdf')<CR>

xmap <buffer> ac <Plug>textobj_markdown_code_block_a
omap <buffer> ac <Plug>textobj_markdown_code_block_a

xmap <buffer> ic <Plug>textobj_markdown_code_block_i
omap <buffer> ic <Plug>textobj_markdown_code_block_i

setlocal commentstring=<!--%s-->

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
            \ . '| unlet b:quick_run_command'
            \ . '| nunmap <buffer> \lv'
            \ . '| xunmap <buffer> ac'
            \ . '| ounmap <buffer> ac'
            \ . '| xunmap <buffer> ic'
            \ . '| ounmap <buffer> ic'
            \ . '| setlocal commentstring<'

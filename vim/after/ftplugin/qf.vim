nnoremap <buffer> dd :call setqflist(filter(getqflist(), {idx -> idx != line('.') - 1}), 'r') <Bar> :cc<CR>

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
            \ . '| nunmap <buffer> dd'

command -buffer SquashAll call gitrebase#squash_all()
nnoremap <buffer> S :SquashAll<CR>

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
            \ . '| delcommand SquashAll'
            \ . '| nunmap <buffer> S'

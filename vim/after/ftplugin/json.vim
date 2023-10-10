if executable('python3')
    let &l:equalprg = 'python3 -m json.tool'
end

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
            \ . '| setlocal equalprg<'

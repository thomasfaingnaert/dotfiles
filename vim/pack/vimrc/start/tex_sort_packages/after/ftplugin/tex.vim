" Command to sort packages
command -buffer SortPackages call tex#sort_packages()

" Automatically sort \usepackage on save
augroup tex_autosort_usepackage
    autocmd!
    autocmd BufWritePre <buffer> :SortPackages
augroup end

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
            \ . '| delcommand SortPackages'
            \ . '| execute ''autocmd! tex_autosort_usepackage'''

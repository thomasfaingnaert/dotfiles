" Autowrite LaTeX files
function! s:autowrite_latex()
    if filereadable(expand('%')) && exists('*b:vimtex.compiler.is_running')
                \ && b:vimtex.compiler.is_running()
        execute 'silent update'
    endif
endfunction

augroup tex_autowrite
    autocmd!
    autocmd CursorHold,CursorHoldI <buffer> call <SID>autowrite_latex()
augroup end

" Command to sort packages
command -buffer SortPackages call tex#sort_packages()

" Automatically sort \usepackage
augroup tex_autosort_usepackage
    autocmd!
    autocmd BufWritePre <buffer> :SortPackages
augroup end

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
            \ . '| execute ''autocmd! tex_autowrite'''
            \ . '| delcommand SortPackages'
            \ . '| execute ''autocmd! tex_autosort_usepackage'''

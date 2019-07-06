" Autowrite LaTeX files
function! s:autowrite_latex()
    if filereadable(expand('%')) && b:vimtex.compiler.is_running()
        execute "silent update"
    endif
endfunction

augroup tex_autowrite
    autocmd!
    autocmd CursorHold,CursorHoldI <buffer> call <SID>autowrite_latex()
augroup end

" Automatically sort \usepackage
augroup tex_autosort_usepackage
    autocmd!
    autocmd BufWritePre <buffer> call preserve_state#execute('g/\n\n^\\usepackage/+2 normal gsip')
augroup end

let b:undo_ftplugin .= '|' .
            \ 'autocmd! tex_autowrite |' .
            \ 'autocmd! tex_autosort_usepackage'

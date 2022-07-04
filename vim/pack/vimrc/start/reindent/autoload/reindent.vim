function! reindent#reindent(old_tabstop, new_tabstop)
    " Save the old values of 'tabstop' and 'expandtab'
    let l:old_tabstop = &l:tabstop
    let l:old_expandtab = &l:expandtab

    " Convert all spaces to tabs
    execute 'set noexpandtab tabstop=' . a:old_tabstop
    %retab!

    " Convert tabs back to spaces
    execute 'set expandtab tabstop=' . a:new_tabstop
    %retab!

    " Restore the old values of 'tabstop' and 'expandtab'
    let &l:tabstop = l:old_tabstop
    let &l:expandtab = l:old_expandtab
endfunction

if exists('g:loaded_gitmergetool')
    finish
endif
let g:loaded_gitmergetool = 1


command DiffLocalMerged  call gitmergetool#diff_windows([1, 4]) | echo "Diffing: LOCAL ↔ MERGED"
command DiffRemoteMerged call gitmergetool#diff_windows([3, 4]) | echo "Diffing: REMOTE ↔ MERGED"
command DiffBaseMerged   call gitmergetool#diff_windows([2, 4]) | echo "Diffing: BASE ↔ MERGED"
command DiffLocalRemote  call gitmergetool#diff_windows([1, 3]) | echo "Diffing: LOCAL ↔ REMOTE"
command DiffLocalBase    call gitmergetool#diff_windows([1, 2]) | echo "Diffing: LOCAL ↔ BASE"
command DiffRemoteBase   call gitmergetool#diff_windows([2, 3]) | echo "Diffing: REMOTE ↔ BASE"
command DiffAll          call gitmergetool#diff_windows([1, 2, 3, 4]) | echo "Diffing: ALL"
command DiffTop          call gitmergetool#diff_windows([1, 2, 3]) | echo "Diffing: LOCAL ↔ BASE ↔ REMOTE"
command DiffOff          call gitmergetool#diff_off_all() | echo "Diff OFF"

nnoremap <silent> <Plug>gitmergetool_diff_local_merged  :DiffLocalMerged<CR>
nnoremap <silent> <Plug>gitmergetool_diff_base_merged   :DiffBaseMerged<CR>
nnoremap <silent> <Plug>gitmergetool_diff_remote_merged :DiffRemoteMerged<CR>
nnoremap <silent> <Plug>gitmergetool_diff_local_remote  :DiffLocalRemote<CR>
nnoremap <silent> <Plug>gitmergetool_diff_all           :DiffAll<CR>
nnoremap <silent> <Plug>gitmergetool_diff_top           :DiffTop<CR>
nnoremap <silent> <Plug>gitmergetool_diff_off           :DiffOff<CR>

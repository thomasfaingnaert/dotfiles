if exists('g:loaded_operator_tmux_send')
    finish
endif
let g:loaded_operator_tmux_send = 1

nnoremap <silent> <Plug>operator_tmux_send :set operatorfunc=operator_tmux_send#send<CR>g@
xnoremap <silent> <Plug>operator_tmux_send :<C-u>call operator_tmux_send#send(visualmode(), 1)<CR>
nnoremap <silent> <Plug>operator_tmux_send_paragraph :<C-u>call operator_tmux_send#send_paragraph()<CR>
nnoremap <silent> <Plug>operator_tmux_select_pane :call operator_tmux_send#select_pane()<CR>

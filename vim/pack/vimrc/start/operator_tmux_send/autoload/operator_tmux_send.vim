" Inspired by vim-slime.

"" Set default tmux send target.
if !exists('g:tmux_send_target')
    " By default, use the last active pane.
    let g:tmux_send_target = '{last}'
endif

function! s:SendToTmux(text) abort
    " Use bracketed paste to avoid triggering autoindent issues
    call system('tmux set-buffer -- ' . shellescape(a:text))
    call system('tmux paste-buffer -d -t ' . shellescape(g:tmux_send_target))
endfunction

function! operator_tmux_send#send(type, ...) abort
    " Save registers and selection
    let l:sel_save = &selection
    let l:reg_save = @@
    let &selection = 'inclusive'

    if a:type ==# 'v' || a:type ==# 'V' || a:type ==# "\<C-V>"
        " Invoked from visual mode
        silent exe 'normal! gvy'
    elseif a:type ==# 'line'
        silent exe "normal! '[V']y"
    elseif a:type ==# 'char'
        silent exe "normal! `[v`]y"
    else
        " Block mode
        silent exe "normal! `[\<C-V>`]y"
    endif

    call s:SendToTmux(@@)

    " Restore registers and selection
    let &selection = l:sel_save
    let @@ = l:reg_save
endfunction

function! operator_tmux_send#send_paragraph() abort
    let l:reg_save = @@
    let l:win_view = winsaveview()

    silent exe "normal! vapy"
    call s:SendToTmux(@@)

    call winrestview(l:win_view)
    let @@ = l:reg_save
endfunction

" Set target pane using Telescope
function! operator_tmux_send#select_pane() abort
    lua << EOF
    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local conf = require('telescope.config').values
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    local handle = io.popen('tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index} #{pane_current_command} #{pane_title}"')
    local result = handle:read("*a")
    handle:close()

    local panes = {}
    for line in result:gmatch("[^\n]+") do
        table.insert(panes, line)
    end

    pickers.new({}, {
        prompt_title = "Select tmux pane",
        finder = finders.new_table { results = panes },
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    local target = selection[1]:match("^(%S+)")
                    vim.g.tmux_target = target
                    vim.notify("tmux target: " .. target)
                end
            end)

            return true
        end,
    }):find()
EOF
endfunction

--------------------------------------------------------------------------------
--- COLOURS
--------------------------------------------------------------------------------

-- Colorscheme
vim.cmd.colorscheme('catppuccin')

--------------------------------------------------------------------------------
--- OPTIONS
--------------------------------------------------------------------------------

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Cursor
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 10

-- Indentation
vim.opt.shiftwidth = 4
vim.opt.softtabstop = -1
vim.opt.expandtab = true
vim.opt.shiftround = true
vim.opt.smartindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Persistent undo
vim.opt.undofile = true

-- Splits
vim.opt.splitright = true

-- Spelling
vim.opt.spelllang = 'en_gb'

-- Wildcharm (for use in mappings)
vim.opt.wildcharm = vim.fn.char2nr('')

-- Listchars
vim.opt.listchars = { eol = '¬', tab = '▸ ', trail = '·', precedes = '←', extends = '→' }

-- Diagnostics
vim.diagnostic.config({virtual_text = {current_line = false}, virtual_lines = {current_line = true}})

-- Statusline
function get_statusline_diagnostics()
    local current = vim.diagnostic.count(0) -- counts in local buffer
    local total = vim.diagnostic.count() -- counts for all buffers

    local severity = vim.diagnostic.severity

    local levels = {
        { s = severity.ERROR, hl = 'DiagnosticError', lbl = 'E' },
        { s = severity.WARN, hl = 'DiagnosticWarn', lbl = 'W' },
        { s = severity.INFO, hl = 'DiagnoticInfo', lbl = 'I' },
        { s = severity.HINT, hl = 'DiagnosticHint', lbl = 'H' },
    }

    local parts = {}

    for _, level in ipairs(levels) do
        local x = current[level.s] or 0
        local y = total[level.s] or 0

        if y > 0 then
            parts[#parts + 1] = string.format('%%#%s#%s: %d/%d%%*', level.hl, level.lbl, x, y)
        end
    end

    return table.concat(parts, ' ')
end

function get_statusline_lsp_servers()
    local names = {}

    for _, client in ipairs(vim.lsp.get_clients()) do
        names[#names + 1] = client.name
    end

    return table.concat(names, ', ')
end

local function get_statusline()
    return table.concat({
        '%f',                                                       -- Path to the file in the buffer
        '%<',                                                       -- Start truncating here, so filename is always visible
        '%( %h%)',                                                  -- Help flag: [Help] or empty
        '%( %w%)',                                                  -- Preview flag: [Preview] or empty
        '%( %m%)',                                                  -- Modified flag: [+] or [-] or empty
        '%( %r%)',                                                  -- Readonly flag: [RO] or empty
        "%( (%{exists('*FugitiveHead') ? FugitiveHead() : ''})%)",  -- Current branch
        '%=',                                                       -- Right align
        "%{% luaeval('get_statusline_diagnostics()') %}",           -- Diagnostics
        "%( [%{ luaeval('get_statusline_lsp_servers()') }]%)",      -- LSP servers
        ' Line: %l/%L',                                             -- Line number and total number of lines
        ' Col: %c',                                                 -- Column number
    })
end

vim.opt.statusline = get_statusline()

--------------------------------------------------------------------------------
--- KEYMAPPINGS
--------------------------------------------------------------------------------

-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Leader mappings
vim.keymap.set('n', '<Leader>c', ':lcd %:h<CR>', {silent = true, desc = 'Update working directory to directory of current file'})
vim.keymap.set('n', '<Leader>h', ':nohlsearch<CR>', {silent = true, desc = 'Switch off search highlighting'})
vim.keymap.set('n', '<Leader>l', ':set list!<CR>', {silent = true, desc = 'Switch the list setting'})
vim.keymap.set('n', '<Leader>v', ':edit $MYVIMRC<CR>', {silent = true, desc = 'Edit configuration'})
vim.keymap.set('n', '<Leader>w', ':silent! wall<CR>', {silent = true, desc = 'Save all open buffers'})
vim.keymap.set('n', '<Leader>=', function()
    local view = vim.fn.winsaveview()
    vim.cmd('normal! gg=G')
    vim.fn.winrestview(view)
end, {silent = true, desc = 'Format entire buffer'})

-- Toggle binary options quickly.
vim.keymap.set('n', 'yos', ':set spell!<CR>', {silent = true, desc = 'Toggle spell on/off'})
vim.keymap.set('n', 'yow', ':set wrap!<CR>', {silent = true, desc = 'Toggle wrap on/off'})

-- Move lines up and down
-- TODO: Replace this with mini.move?
vim.keymap.set('n', '<A-j>', ':move +1<CR>==', {silent = true, desc = 'Move line down'})
vim.keymap.set('n', '<A-k>', ':move -2<CR>==', {silent = true, desc = 'Move line up'})

vim.keymap.set('i', '<A-j>', '<Esc>:move +1<CR>==gi', {silent = true, desc = 'Move line down'})
vim.keymap.set('i', '<A-k>', '<Esc>:move -2<CR>==gi', {silent = true, desc = 'Move line up'})

vim.keymap.set('x', '<A-j>', ":move '>+1<CR>gv=gv", {silent = true, desc = 'Move line down'})
vim.keymap.set('x', '<A-k>', ":move '<-2<CR>gv=gv", {silent = true, desc = 'Move line up'})

-- Show matching line in centre of screen for 'n' and 'N'.
vim.keymap.set('n', 'n', 'nzz', {silent = true, desc = 'Go to the next match and centre the match on the screen'})
vim.keymap.set('n', 'N', 'Nzz', {silent = true, desc = 'Go to the previous match and centre the match on the screen'})

-- Alternate files
vim.keymap.set('n', '<BS>', '<C-^>', {silent = true, desc = 'Switch between alternate files'})

-- Easier window navigation.
local function move_or_split(move_cmd, split_cmd)
    return function()
        -- Save old window.
        local cur = vim.fn.winnr()

        -- Execute movement.
        vim.cmd('wincmd ' .. move_cmd)

        -- Check if we have changed window.
        if cur == vim.fn.winnr() then
            -- If not, create new split, and move to that new split.
            vim.cmd(split_cmd)
            vim.cmd('wincmd ' .. move_cmd)
        end
    end
end

vim.keymap.set('n', '<C-h>', move_or_split('h', 'vsplit'), {desc = 'Move one window left or split'})
vim.keymap.set('n', '<C-j>', move_or_split('j', 'split'), {desc = 'Move one window down or split'})
vim.keymap.set('n', '<C-k>', move_or_split('k', 'split'), {desc = 'Move one window up or split'})
vim.keymap.set('n', '<C-l>', move_or_split('l', 'vsplit'), {desc = 'Move one window right or split'})

-- Easier window movement.
vim.keymap.set('n', '<C-M-h>', '<C-w>H', {silent = true, desc = 'Move the current window left'})
vim.keymap.set('n', '<C-M-j>', '<C-w>J', {silent = true, desc = 'Move the current window down'})
vim.keymap.set('n', '<C-M-k>', '<C-w>K', {silent = true, desc = 'Move the current window up'})
vim.keymap.set('n', '<C-M-l>', '<C-w>L', {silent = true, desc = 'Move the current window right'})

-- Emacs-style commandline editing.
vim.keymap.set('c', '<C-a>', '<Home>', {desc = 'Go to the start of the line in command mode'})
vim.keymap.set('c', '<C-e>', '<End>', {desc = 'Go to the end of the line in command mode'})
vim.keymap.set('c', '<C-p>', '<Up>', {desc = 'Go to previous command in command mode'})
vim.keymap.set('c', '<C-n>', '<Down>', {desc = 'Go to next command in command mode'})

-- Go to next and previous match with <Tab> and <S-Tab> in command-line mode.
local function cmdline_tab(search_key, fallback)
    return function()
        local t = vim.fn.getcmdtype()
        return (t == '/' or t == '?') and search_key or fallback
    end
end

vim.keymap.set('c', '<Tab>', cmdline_tab('<C-g>', '<C-z>'), {expr = true})
vim.keymap.set('c', '<S-Tab>', cmdline_tab('<C-t>', '<S-Tab>'), {expr = true})

--------------------------------------------------------------------------------
--- COMMANDS
--------------------------------------------------------------------------------

-- Diagnostics
vim.api.nvim_create_user_command('DiagnosticsToQf', vim.diagnostic.setqflist, {desc = 'Open the quickfix window with all diagnostics in the current buffer'})

--------------------------------------------------------------------------------
--- AUTOCOMMANDS
--------------------------------------------------------------------------------

local augroup = vim.api.nvim_create_augroup('UserConfig', {clear = true})

-- Remove trailing whitespace on file save.
-- TODO: Replace with mini.trailspace?
vim.api.nvim_create_autocmd('BufWritePre', {
    group = augroup,
    pattern = '*',
    callback = function()
        if vim.tbl_contains({ 'diff' }, vim.bo.filetype) then
            return
        end

        local view = vim.fn.winsaveview()
        vim.cmd([[keeppatterns %s/\s\+$//e]])
        vim.fn.winrestview(view)
    end,
    desc = 'Strip trailing whitespace on save'
})

--------------------------------------------------------------------------------
--- PLUGINS
--------------------------------------------------------------------------------

vim.pack.add({
    'https://github.com/lervag/vimtex',
    'https://github.com/neovim/nvim-lspconfig',
    'https://github.com/nvim-mini/mini.nvim',
    'https://github.com/tpope/vim-eunuch',
    'https://github.com/tpope/vim-fugitive',
})

-- LSP
vim.lsp.enable('texlab')

-- vim-tex
vim.g.vimtex_view_method = 'zathura'

-- mini.pick and mini.extra
require('mini.pick').setup({})
require('mini.extra').setup({})

vim.keymap.set('n', '<C-p>', MiniPick.builtin.files)
vim.keymap.set('n', '<C-g>', MiniPick.builtin.grep_live)
vim.keymap.set('n', '<C-_>', MiniExtra.pickers.buf_lines) -- NOTE: actually maps C-/
vim.keymap.set('n', 'go', function() MiniExtra.pickers.lsp({scope = 'workspace_symbol_live'}) end)
vim.keymap.set('n', 'gO', function() MiniExtra.pickers.lsp({scope = 'document_symbol'}) end)
vim.keymap.set('n', '<Space>r', function() MiniExtra.pickers.lsp({scope = 'references'}) end)

-- mini.surround
require('mini.surround').setup({
    -- Use mappings of tpope's vim-surround.
    mappings = {
        add = 'ys',
        delete = 'ds',
        replace = 'cs',
    },
})

-- mini.align
require('mini.align').setup({})

-- mini.operators (for sort)
require('mini.operators').setup({})

-- mini.snippets
require('mini.snippets').setup({})

-- mini.completion
require('mini.completion').setup({
    delay = { completion = 1e7 },
})

-- mini.splitjoin
require('mini.splitjoin').setup({})

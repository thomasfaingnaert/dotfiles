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
require('mini.completion').setup({})

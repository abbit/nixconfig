-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Setting options (see `:help vim.opt`)

vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.signcolumn = "yes"
vim.opt.number = true -- show line numbers
vim.opt.wrap = false -- dont wrap lines

vim.opt.ignorecase = true -- make search case-insensitive
vim.opt.smartcase = true -- make search case-sensitive if it contains upper case letters

vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.tabstop = 4 -- 1 tab is 4 spaces
vim.opt.shiftwidth = 4 -- shift 4 spaces when tab

vim.opt.mouse = "a" -- enable mouse
vim.opt.clipboard = "unnamedplus" -- use system clipboard for copy/paste
vim.opt.autoread = true -- reload file when changed by another process

vim.opt.autoindent = true -- copy indent from current line when starting a new line
vim.opt.linebreak = true -- break long lines
vim.opt.wildmenu = true -- command completion

vim.opt.undofile = true -- save undo history to a file
vim.opt.undolevels = 1000 -- max number of undo

vim.opt.foldmethod = "expr" -- fold by treesitter
vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- fold by treesitter
vim.opt.foldenable = false -- dont fold by default

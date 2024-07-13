-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
--
-- See `:help mapleader`
-- Set <space> as the leader key and <,> as the local leader key
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Disable space in normal and visual mode
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
-- better up/down
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Buffers
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save buffer" })
-- alternative save bind to CMD + s
vim.keymap.set("n", "<D-s>", ":w<CR>", { desc = "Save buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>by", function()
  vim.cmd(":%y+")
  vim.notify("Copied buffer content to system clipboard")
end, { desc = "Yank buffer content" })
vim.keymap.set("n", "<leader>`", ":e #<CR>", { desc = "Switch to last buffer" })

-- Splits
-- stylua: ignore start
vim.keymap.set("n", "<leader>sv", "<C-W>s", { desc = "Open vertical split" })
vim.keymap.set("n", "<leader>sh", "<C-W>v", { desc = "Open horizontal split" })
vim.keymap.set("n", "<leader>sd", ":close<CR>", { desc = "Close split" })

-- Files
-- stylua: ignore start
vim.keymap.set("n", "<leader>fn", ":enew<CR>", { desc = "New file" })
vim.keymap.set("n", "<leader>fy", function() vim.cmd([[let @+ = expand('%:p')]]) end, { desc = "Yank file path" })
vim.keymap.set("n", "<leader>fd", ":%d<CR>", { desc = "Clear file content" })

-- Project
-- TODO: use something more sofisticated
vim.keymap.set("n", "<leader>pr", ":!make run<CR>", { desc = "Run project" })
vim.keymap.set("n", "<leader>pt", ":!make test<CR>", { desc = "Test project" })

-- LSP
vim.keymap.set("n", "<leader>lr", ":LspRestart<CR>", { desc = "Restart LSP" })
vim.keymap.set("n", "<leader>ld", ":LspStop<CR>", { desc = "Stop LSP" })
vim.keymap.set("n", "<leader>ln", ":LspStart<CR>", { desc = "Start LSP" })

 -- Diagnostics
vim.keymap.set("n", "gl", function() vim.diagnostic.open_float() end)
vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end)
vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end)


-- Nvim
vim.keymap.set("n", "<leader>nq", ":qa<CR>", { desc = "Quit nvim" })
vim.keymap.set("n", "<leader>nc", ":e $MYVIMRC<CR>", { desc = "Open nvim config" })
vim.keymap.set("n", "<leader>np", ":Lazy<CR>", { desc = "Open lazy.nvim" })
vim.keymap.set("n", "<leader>nm", ":Mason<CR>", { desc = "Open mason.nvim" })

-- Misc
vim.keymap.set("n", "<leader>nl",
    "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
    { desc = "Redraw / Clear hlsearch / Diff Update" })
vim.keymap.set("n", "<leader>=", "<C-a>", { desc = "Increment number" })
vim.keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

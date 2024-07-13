-- magit-like git UI
return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim", -- required
    "sindrets/diffview.nvim", -- optional - Diff integration
  },
  opts = {},
  keys = {
    { "<leader>gg", "<cmd>Neogit<cr>", desc = "Open Neogit" },
    { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Open Neogit commit popup" },
  },
}

-- show error messages in dedicated window
-- TODO: check new features (e.g. showing document symbols)
return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  opts = {
    use_diagnostic_signs = true,
  },
  keys = {
    { "<leader>td", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
  },
}

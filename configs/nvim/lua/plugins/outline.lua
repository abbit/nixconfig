-- show symbols in current file
return {
  "hedyhli/outline.nvim",
  lazy = true,
  cmd = { "Outline", "OutlineOpen" },
  keys = {
    { "<leader>to", "<cmd>Outline<CR>", desc = "Toggle Outline" },
  },
  opts = {},
}

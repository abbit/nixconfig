return {
  -- UI for notifications and LSP progress messages
  {
    "j-hui/fidget.nvim",
    opts = {},
  },
  -- better UI for `vim.input` and `vim.select`
  {
    "stevearc/dressing.nvim",
    opts = {},
  },
  -- automatically highlights other instances of the word under cursor
  -- TODO: use something that has persistent hight
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
    end,
  },
  -- indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { enabled = false },
      exclude = {
        filetypes = {
          "help",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
        },
      },
    },
  },
}

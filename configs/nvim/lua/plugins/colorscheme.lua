return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    enabled = false,
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("catppuccin").setup({
        integrations = {
          native_lsp = {
            enabled = true,
            underlines = {
              errors = { "undercurl" },
              hints = { "undercurl" },
              warnings = { "undercurl" },
              information = { "undercurl" },
            },
            symbols_outline = true,
            lsp_trouble = true,
            cmp = true,
            gitsigns = true,
            illuminate = true,
            indent_blankline = { enabled = true },
            mason = true,
            telescope = true,
            treesitter = true,
            neotree = true,
          },
        },
        -- custom_highlights = function(colors)
        --   return {
        --     Comment = { fg = "#00ab00" },
        --     ["@comment"] = { fg = "#00ab00" },
        --   }
        -- end,
      })

      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },
  {
    "savq/melange-nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      vim.cmd.colorscheme("melange")
    end,
  },
}

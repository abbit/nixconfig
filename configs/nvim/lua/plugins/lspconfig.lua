-- easily configure LSP
return {
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v3.x",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    config = function()
      local lsp_zero = require("lsp-zero")

      lsp_zero.set_sign_icons({
        error = "✘",
        warn = "",
        hint = "󰌵",
        info = "",
      })

      lsp_zero.setup()
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        desc = "LSP actions",
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end
          local opts = { buffer = event.buf }
          local telescope_builtin = require("telescope.builtin")

          -- LSP actions
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-T>.
          map("gd", telescope_builtin.lsp_definitions, "[G]oto [D]efinition")
          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map("gi", telescope_builtin.lsp_implementations, "[G]oto [I]mplementation")
          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map("go", telescope_builtin.lsp_type_definitions, "Type [D]efinition")
          -- Find references for the word under your cursor.
          map("gr", telescope_builtin.lsp_references, "[G]oto [R]eferences")

          vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<F4>", vim.lsp.buf.code_action, opts)
        end,
      })

      vim.diagnostic.config({
        -- inline diagnostic messages
        virtual_text = {
          prefix = "▎",
          spacing = 1,
        },
        severity_sort = true,
        float = {
          style = "minimal",
          border = "rounded",
          source = true,
          header = "",
          prefix = "",
        },
      })
    end,
  },
}

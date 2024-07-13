-- manage lsp servers, daps, linters and formatters
return {
  { "williamboman/mason.nvim", opts = {} },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      local lspconfig = require("lspconfig")
      local lsp_zero = require("lsp-zero")

      -- Configure LSP servers
      require("mason-lspconfig").setup({
        handlers = {
          lsp_zero.default_setup,
          lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            lspconfig.lua_ls.setup(lua_opts)
          end,
          rust_analyzer = function()
            lspconfig.rust_analyzer.setup({
              settings = {
                ["rust-analyzer"] = {
                  checkOnSave = { command = "clippy" },
                  files = {
                    excludeDirs = { ".direnv", ".git", "target" },
                    watcherExclude = { ".direnv", ".git", "target" },
                  },
                },
              },
            })
          end,
          clangd = function()
            lspconfig.clangd.setup({
              filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
            })
          end,
        },
      })
    end,
  },
}

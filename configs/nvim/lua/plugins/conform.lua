-- format code
return {
  "stevearc/conform.nvim",
  opts = {
    -- list of available formatters - ':help conform-formatters'
    formatters_by_ft = {
      yaml = { "yamlfmt" },
      nix = { "alejandra" },
      lua = { "stylua" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      go = { "goimports", "gofumpt" },
      python = function(bufnr)
        if require("conform").get_formatter_info("ruff_format", bufnr).available then
          return { "ruff_format" }
        else
          return { "isort", "black" }
        end
      end,
    },
    format_on_save = function(bufnr)
      -- Disable with a global or buffer-local variable
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      return { timeout_ms = 3000, lsp_format = "fallback" }
    end,
    log_level = vim.log.levels.ERROR,
    notify_on_error = true,
  },
}

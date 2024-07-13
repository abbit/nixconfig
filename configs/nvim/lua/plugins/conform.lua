-- format code
return {
  "stevearc/conform.nvim",
  opts = {
    -- list of available formatters - ':help conform-formatters'
    formatters_by_ft = {
      yaml = { "yamlfmt" },
      nix = { "alejandra" },
      lua = { "stylua" },
      javascript = { { "prettierd", "prettier" } },
      go = { "goimports", "gofumpt" },
      python = function(bufnr)
        if require("conform").get_formatter_info("ruff_format", bufnr).available then
          return { "ruff_format" }
        else
          return { "isort", "black" }
        end
      end,
    },
    format_on_save = {
      lsp_fallback = true,
      timeout_ms = 1000,
    },
    format_after_save = {
      lsp_fallback = true,
    },
    log_level = vim.log.levels.ERROR,
    notify_on_error = true,
  },
}

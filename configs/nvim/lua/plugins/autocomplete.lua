-- autocompletion
return {
  {
    "hrsh7th/nvim-cmp", -- core
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" }, -- source for built-in language server client
      { "hrsh7th/cmp-buffer" }, -- source for buffer words
      { "FelipeLema/cmp-async-path" }, -- source for filesystem paths
      { "hrsh7th/cmp-nvim-lua" }, -- source for nvim lua api
      { "saadparwaiz1/cmp_luasnip" }, -- cmp source for luasnip
      { "zbirenbaum/copilot-cmp" }, -- cmp source for copilot
    },
    config = function()
      local lsp_zero = require("lsp-zero")
      local cmp = require("cmp")
      local cmp_action = lsp_zero.cmp_action()
      local cmp_format = lsp_zero.cmp_format()

      vim.opt.completeopt = { "menu", "menuone", "noselect" } -- preselect first item in completion menu
      cmp.setup({
        -- general
        preselect = "item",
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        -- styles
        formatting = cmp_format,
        window = {
          documentation = cmp.config.window.bordered(),
        },
        -- completion sources
        sources = {
          { name = "async_path" },
          { name = "copilot" },
          { name = "nvim_lsp" },
          { name = "nvim_lua" },
          { name = "buffer", keyword_length = 3 },
          { name = "luasnip", keyword_length = 2 },
        },
        -- keymaps
        mapping = cmp.mapping.preset.insert({
          -- confirm completion item
          ["<CR>"] = cmp.mapping.confirm({ select = false }),

          -- toggle completion menu
          ["<C-e>"] = cmp_action.toggle_completion(),

          -- navigate between snippet placeholder
          ["<C-d>"] = cmp_action.luasnip_jump_forward(),
          ["<C-b>"] = cmp_action.luasnip_jump_backward(),

          -- scroll documentation window
          ["<C-f>"] = cmp.mapping.scroll_docs(-5),
          ["<C-u>"] = cmp.mapping.scroll_docs(5),
        }),
      })
    end,
  },
}

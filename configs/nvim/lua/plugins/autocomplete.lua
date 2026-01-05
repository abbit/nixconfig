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
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- preselect first item in completion menu
      vim.opt.completeopt = { "menu", "menuone", "noselect" }

      cmp.setup({
        -- general
        preselect = "item",
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        -- styles
        formatting = {
          -- order of fields in completion menu
          fields = { "abbr", "menu", "kind" },
          -- format completion menu item
          format = function(entry, item)
            local src_name = entry.source.name

            local label = ""
            if src_name == "nvim_lsp" then
              label = "[LSP]"
            elseif src_name == "nvim_lua" then
              label = "[nvim]"
            else
              label = string.format("[%s]", src_name)
            end
            item.menu = label

            return item
          end,
        },
        window = {
          documentation = cmp.config.window.bordered(),
        },
        -- completion sources in priority order
        sources = cmp.config.sources({
          { name = "async_path" },
          { name = "nvim_lua" },
          { name = "nvim_lsp" },
          { name = "luasnip", keyword_length = 2 },
          { name = "buffer", keyword_length = 3 },
        }),
        -- keymaps
        mapping = cmp.mapping.preset.insert({
          -- confirm completion item
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          -- toggle completion menu
          ["<C-e>"] = cmp.mapping(function()
            if cmp.visible() then
              cmp.abort()
            else
              cmp.complete()
            end
          end),
          -- jump to next snippet placeholder
          ["<C-d>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          -- jump to previous snippet placeholder
          ["<C-b>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          -- scroll documentation window
          ["<C-f>"] = cmp.mapping.scroll_docs(-5),
          ["<C-u>"] = cmp.mapping.scroll_docs(5),
        }),
        -- snippet support
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
      })
    end,
  },
}

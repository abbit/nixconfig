-- =======================================================
-- 			        Utility functions
-- =======================================================

local function lsp_get_clients(opts)
  local ret = {} ---@type lsp.Client[]
  if vim.lsp.get_clients then
    ret = vim.lsp.get_clients(opts)
  else
    ---@diagnostic disable-next-line: deprecated
    ret = vim.lsp.get_active_clients(opts)
    if opts and opts.method then
      ---@param client lsp.Client
      ret = vim.tbl_filter(function(client)
        return client.supports_method(opts.method, { bufnr = opts.bufnr })
      end, ret)
    end
  end
  return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
end

---@param on_attach fun(client, buffer)
local function lsp_on_attach(on_attach)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf ---@type number
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, buffer)
    end,
  })
end

-- =======================================================
-- 			Pre-plugins configs
-- =======================================================

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- See `:help mapleader`
-- NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
-- Set <space> as the leader key and <,> as the local leader key
vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.o.termguicolors = true

-- =======================================================
-- 			Install plugins
-- =======================================================

-- Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- init lazy.nvim with plugins
require("lazy").setup({
  -- utility plugin for other plugins
  { "nvim-lua/plenary.nvim" },

  -- ===================================================
  --                 quality of life
  -- ===================================================

  -- move between splits and tmux panes with CTRL-hjkl
  { "christoomey/vim-tmux-navigator" },

  -- maximize current split
  { "0x00-ketsu/maximizer.nvim" },

  -- comment lines with gcc
  { "numToStr/Comment.nvim", opts = {} },

  -- auto close brackets, quotes, etc
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- work with surrounding characters
  { "kylechui/nvim-surround", version = "*", event = "VeryLazy", opts = {} },

  -- buffer removing, which saves window layout
  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<leader>bd",
        function()
          local bd = require("mini.bufremove").delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
            if choice == 1 then -- Yes
              vim.cmd.write()
              bd(0)
            elseif choice == 2 then -- No
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = "Delete Buffer",
      },
      {
        "<leader>bD",
        function()
          require("mini.bufremove").delete(0, true)
        end,
        desc = "Delete Buffer (Force)",
      },
    },
  },

  -- ===================================================
  --                        UI
  -- ===================================================

  -- UI icons, used by a lot of other plugins
  { "nvim-tree/nvim-web-devicons" },

  -- better UI
  { "stevearc/dressing.nvim", opts = {} },

  -- UI for notifications and LSP progress messages
  { "j-hui/fidget.nvim", opts = {} },

  -- show which lines have been changed
  { "lewis6991/gitsigns.nvim", opts = {} },

  -- Colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
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
    },
  },

  -- adds indentation guides
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
          "lazyterm",
        },
      },
    },
  },

  -- automatically highlights other instances of the word under cursor
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

  -- tabline
  {
    "akinsho/bufferline.nvim",
    event = "BufEnter",
    dependencies = { "catppuccin" },
    config = function()
      require("bufferline").setup({
        options = {
          show_buffer_close_icons = false,
          show_close_icon = false,
          show_tab_indicators = true,
          always_show_bufferline = true,
          numbers = "none",
          separator_style = "thin",
          sort_by = "id",
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(count, _, _, _)
            return "(" .. count .. ")"
          end,
          highlights = require("catppuccin.groups.integrations.bufferline").get(),
          close_command = function(n)
            require("mini.bufremove").delete(n, false)
          end,
          right_mouse_command = function(n)
            require("mini.bufremove").delete(n, false)
          end,
          offsets = {
            {
              filetype = "neo-tree",
              text = "File Explorer",
              highlight = "Directory",
              text_align = "left",
            },
          },
        },
      })
    end,
  },

  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      -- DoomEmacs-like style for lualine
      local lualine = require("lualine")

      -- Color table for highlights
      local colors = {
        bg = "#202328",
        fg = "#bbc2cf",
        yellow = "#ECBE7B",
        cyan = "#008080",
        darkblue = "#081633",
        green = "#98be65",
        orange = "#FF8800",
        violet = "#a9a1e1",
        magenta = "#c678dd",
        purple = "#c5a7f2",
        blue = "#51afef",
        red = "#ec5f67",
        white = "#f3f3f3",
      }

      local conditions = {
        buffer_not_empty = function()
          return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
        end,
        hide_in_width = function()
          return vim.fn.winwidth(0) > 80
        end,
        check_git_workspace = function()
          local filepath = vim.fn.expand("%:p:h")
          local gitdir = vim.fn.finddir(".git", filepath .. ";")
          return gitdir and #gitdir > 0 and #gitdir < #filepath
        end,
      }

      local config = {
        options = {
          globalstatus = true,
          disabled_filetypes = { statusline = { "starter" } },
          -- Disable sections and component separators
          component_separators = "",
          section_separators = "",
          theme = {
            -- We are going to use lualine_c an lualine_x as left and
            -- right section. Both are highlighted by c theme .  So we
            -- are just setting default looks o statusline
            normal = { c = { fg = colors.fg, bg = colors.bg } },
            inactive = { c = { fg = colors.fg, bg = colors.bg } },
          },
        },
        sections = {
          -- these are to remove the defaults
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          -- These will be filled later
          lualine_c = {},
          lualine_x = {},
        },
        inactive_sections = {
          -- these are to remove the defaults
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          lualine_c = {},
          lualine_x = {},
        },
        extensions = { "neo-tree", "lazy", "mason", "symbols-outline", "trouble" },
      }

      -- Inserts a component in lualine_c at left section
      local function push_left(component)
        table.insert(config.sections.lualine_c, component)
      end

      -- Inserts a component in lualine_x at right section
      local function push_right(component)
        table.insert(config.sections.lualine_x, component)
      end

      push_left({
        function()
          return "▊"
        end,
        color = { fg = colors.blue }, -- Sets highlighting of component
        padding = { left = 0, right = 1 }, -- We don't need space before this
      })

      push_left({
        -- mode component
        function()
          return ""
        end,
        color = function()
          -- auto change color according to neovims mode
          local mode_color = {
            n = colors.green,
            i = colors.yellow,
            v = colors.blue,
            [""] = colors.blue,
            V = colors.blue,
            c = colors.magenta,
            no = colors.green,
            s = colors.orange,
            S = colors.orange,
            [""] = colors.orange,
            ic = colors.red,
            R = colors.violet,
            Rv = colors.violet,
            cv = colors.green,
            ce = colors.green,
            r = colors.cyan,
            rm = colors.cyan,
            ["r?"] = colors.cyan,
            ["!"] = colors.green,
            t = colors.green,
          }
          return { fg = mode_color[vim.fn.mode()] }
        end,
        padding = { right = 1 },
      })

      push_left({
        "filename",
        path = 1,
        file_status = false,
        cond = conditions.buffer_not_empty,
        color = { fg = colors.white, gui = "bold,italic" },
      })

      push_left({ "location" })

      push_left({
        -- buffer total lines count
        function()
          return vim.fn.line("$") .. " total"
        end,
      })

      push_left({
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = { error = " ", warn = " ", info = " " },
        diagnostics_color = {
          color_error = { fg = colors.red },
          color_warn = { fg = colors.yellow },
          color_info = { fg = colors.cyan },
        },
      })

      -- Add components to right sections

      push_right({
        "diff",
        -- Is it me or the symbol for modified us really weird
        symbols = { added = "+", modified = "~", removed = "-" },
        diff_color = {
          added = { fg = colors.green },
          modified = { fg = colors.yellow },
          removed = { fg = colors.red },
        },
        cond = conditions.hide_in_width,
      })

      push_right({
        "branch",
        icon = "",
        color = { fg = colors.violet, gui = "bold" },
      })

      push_right({
        "o:encoding", -- option component same as &encoding in viml
        fmt = string.upper, -- I'm not sure why it's upper case either ;)
        cond = conditions.hide_in_width,
        color = { fg = colors.green, gui = "bold" },
      })

      push_right({
        "fileformat",
        fmt = string.upper,
        icons_enabled = true,
        color = { fg = colors.green, gui = "bold" },
      })

      push_right({
        -- Lsp server name
        function()
          local msg = "No Lsp"
          local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
          local clients = vim.lsp.get_active_clients() -- for neovim <0.10
          -- local clients = vim.lsp.get_clients() -- for neovim >=0.10
          if next(clients) == nil then
            return msg
          end
          for _, client in ipairs(clients) do
            ---@diagnostic disable-next-line: undefined-field
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
              return client.name
            end
          end
          return msg
        end,
        color = { fg = colors.purple, gui = "bold" },
      })

      push_right({
        -- Copilot status
        function()
          local icon = " "
          local status = require("copilot.api").status.data
          return icon .. (status.message or "")
        end,
        cond = function()
          if not package.loaded["copilot"] then
            return
          end
          local ok, clients = pcall(lsp_get_clients, { name = "copilot", bufnr = 0 })
          if not ok then
            return false
          end
          return ok and #clients > 0
        end,
        color = function()
          if not package.loaded["copilot"] then
            return
          end
          local status = require("copilot.api").status.data
          local copilot_status_colors = {
            [""] = colors.green,
            ["Normal"] = colors.green,
            ["Warning"] = colors.red,
            ["InProgress"] = colors.blue,
          }
          return { fg = copilot_status_colors[status.status] or copilot_status_colors[""] }
        end,
      })

      push_right({
        function()
          return "▊"
        end,
        color = { fg = colors.blue },
        padding = { left = 1 },
      })

      -- Now don't forget to initialize lualine
      lualine.setup(config)
    end,
  },

  -- ===================================================
  --                        Files
  -- ===================================================

  -- file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>te", "<cmd>Neotree toggle<cr>", desc = "NeoTree" },
    },
    opts = {
      sources = { "filesystem", "buffers", "git_status", "document_symbols" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      window = {
        width = 35,
        mappings = {
          ["<space>"] = "none",
          ["<Tab>"] = "toggle_node",
        },
      },
    },
  },

  -- file explorer as buffer
  { "stevearc/oil.nvim", opts = {} },

  -- fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-telescope/telescope-live-grep-args.nvim",
    },
    config = function()
      require("telescope").load_extension("live_grep_args")
    end,
  },

  -- ===================================================
  --                     Languages
  -- ===================================================

  -- easily configure treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        -- A list of parser names, or 'all'
        ensure_installed = { "lua", "python", "javascript", "typescript", "go", "c" },
        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,
        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
        auto_install = true,
        highlight = {
          -- `false` will disable the whole extension
          enable = true,
        },
      })
    end,
  },

  -- easily configure LSP
  { "VonHeikemen/lsp-zero.nvim", branch = "v3.x" },
  { "neovim/nvim-lspconfig" },
  -- manage lsp servers, daps, linters and formatters
  { "williamboman/mason.nvim", opts = {} },
  { "williamboman/mason-lspconfig.nvim" },

  -- autocompletion
  { "hrsh7th/nvim-cmp" }, -- core
  { "hrsh7th/cmp-nvim-lsp" }, -- source for built-in language server client
  { "hrsh7th/cmp-buffer" }, -- source for buffer words
  { "FelipeLema/cmp-async-path" }, -- source for filesystem paths
  { "hrsh7th/cmp-nvim-lua" }, -- source for nvim lua api

  -- snippets
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    keys = {
      {
        "<tab>",
        function()
          return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
        end,
        expr = true,
        silent = true,
        mode = "i",
      },
      {
        "<tab>",
        function()
          require("luasnip").jump(1)
        end,
        mode = "s",
      },
      {
        "<s-tab>",
        function()
          require("luasnip").jump(-1)
        end,
        mode = { "i", "s" },
      },
    },
  },
  { "saadparwaiz1/cmp_luasnip" }, -- cmp source for luasnip

  -- show error messages in dedicated window
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>td", "<CMD>TroubleToggle<CR>", desc = "Toggle diagnostics" },
    },
  },

  -- show symbols in current file
  -- TODO: migrate to someting else
  {
    "simrat39/symbols-outline.nvim",
    cmd = { "SymbolsOutline", "SymbolsOutlineOpen" },
    keys = {
      { "<leader>to", "<CMD>SymbolsOutline<CR>", desc = "Toggle Outline" },
    },
    opts = {
      autofold_depth = 1,
    },
  },

  -- format code
  {
    "stevearc/conform.nvim",
    opts = {
      -- list of available formatters - ':help conform-formatters'
      formatters_by_ft = {
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
  },

  -- github copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = false,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = "<C-l>",
          accept_word = false,
          accept_line = false,
          next = "<C-j>",
          prev = "<C-k>",
          dismiss = "<C-]>",
        },
      },
      filetypes = {
        help = false,
        gitcommit = false,
        gitrebase = false,
        hgcommit = false,
        svn = false,
        cvs = false,
        ["."] = false,
      },
      copilot_node_command = "node",
      server_opts_overrides = {},
    },
    keys = {
      {
        "<leader>tc",
        function()
          local client = require("copilot.client")
          local command = require("copilot.command")
          if client.is_disabled() then
            command.enable()
            print("Copilot enabled")
          else
            command.disable()
            print("Copilot disabled")
          end
        end,
        desc = "Toggle copilot",
      },
    },
  },
  -- cmp source for github copilot
  {
    "zbirenbaum/copilot-cmp",
    opts = {},
    config = function(_, opts)
      local copilot_cmp = require("copilot_cmp")
      copilot_cmp.setup(opts)
      -- attach cmp source whenever copilot attaches
      -- fixes lazy-loading issues with the copilot cmp source
      lsp_on_attach(function(client)
        if client.name == "copilot" then
          copilot_cmp._on_insert_enter({})
        end
      end)
    end,
  },
})

-- =======================================================
-- 			Plugin configs
-- =======================================================

-- === Configure LSP ==

local lspconfig = require("lspconfig")
local lsp_zero = require("lsp-zero")

lsp_zero.on_attach(function(_, bufnr)
  local opts = { remap = false, buffer = bufnr }

  -- LSP actions
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "go", vim.lsp.buf.type_definition, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<F4>", vim.lsp.buf.code_action, opts)

  -- Diagnostics
  vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
end)

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
  },
})

-- Configure LSP diagnostics
lsp_zero.set_sign_icons({
  error = "✘",
  warn = "▲",
  hint = "⚑",
  info = "",
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
    source = "always",
    header = "",
    prefix = "",
  },
})

-- configure autocompletions
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

lsp_zero.setup() -- should be last

-- =======================================================
-- 			Colorscheme
-- =======================================================

vim.o.background = "dark"
vim.cmd.colorscheme("catppuccin-mocha")

-- =======================================================
-- 			Options
-- =======================================================

-- Setting options (see `:help vim.o`)
vim.o.number = true -- show line numbers
vim.o.ignorecase = true -- make search case-insensitive
vim.o.smartcase = true -- make search case-sensitive if it contains upper case letters
vim.o.expandtab = true -- use spaces instead of tabs
vim.o.tabstop = 4 -- 1 tab is 4 spaces
vim.o.shiftwidth = 4 -- shift 4 spaces when tab
vim.o.mouse = "a" -- enable mouse
vim.o.autoindent = true -- copy indent from current line when starting a new line
vim.o.linebreak = true -- break long lines
vim.o.wildmenu = true -- command completion
vim.o.autoread = true -- reload file when changed by another process
vim.o.undofile = true -- save undo history to a file
vim.o.undolevels = 1000 -- max number of undo
vim.o.wrap = false -- dont wrap lines
vim.o.clipboard = "unnamedplus" -- use system clipboard for copy/paste
vim.opt.foldmethod = "expr" -- fold by treesitter
vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- fold by treesitter
vim.opt.foldenable = false -- dont fold by default

-- =======================================================
-- 			Keymaps
-- =======================================================

local telescope = require("telescope")
local telescope_builtin = require("telescope.builtin")

-- Disable space in normal and visual mode
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
-- better up/down
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Buffers
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>by", function()
  vim.cmd(":%y+")
  vim.notify("Copied buffer content to system clipboard")
end, { desc = "Yank buffer content" })
vim.keymap.set("n", "<leader>bl", telescope_builtin.buffers, { desc = "List buffers" })
vim.keymap.set("n", "<leader>`", ":e #<CR>", { desc = "Switch to last buffer" })

-- Splits
vim.keymap.set("n", "<leader>sv", "<C-W>s", { desc = "Open vertical split" })
vim.keymap.set("n", "<leader>sh", "<C-W>v", { desc = "Open horizontal split" })
vim.keymap.set("n", "<leader>sd", ":close<CR>", { desc = "Close split" })
vim.keymap.set("n", "<leader>sm", function()
  require("maximizer").toggle()
end, { desc = "Maximize split" })

-- Files
vim.keymap.set("n", "<leader>.", telescope_builtin.find_files, { desc = "Find file" })
vim.keymap.set("n", "<leader>/", telescope.extensions.live_grep_args.live_grep_args, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fr", telescope_builtin.oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<leader>fn", ":enew<CR>", { desc = "New file" })
vim.keymap.set("n", "<leader>fy", function()
  vim.cmd([[let @+ = expand('%:p')]])
end, { desc = "Yank file path" })
vim.keymap.set("n", "<leader>fd", ":%d<CR>", { desc = "Clear file content" })

-- Project
-- TODO: use something more sofisticated
vim.keymap.set("n", "<leader>pr", ":!make run<CR>", { desc = "Run project" })
vim.keymap.set("n", "<leader>pt", ":!make test<CR>", { desc = "Test project" })

-- LSP
vim.keymap.set("n", "<leader>lr", ":LspRestart<CR>", { desc = "Restart LSP" })
vim.keymap.set("n", "<leader>ld", ":LspStop<CR>", { desc = "Stop LSP" })
vim.keymap.set("n", "<leader>ln", ":LspStart<CR>", { desc = "Start LSP" })

-- Nvim
vim.keymap.set("n", "<leader>nq", ":qa<CR>", { desc = "Quit nvim" })
vim.keymap.set("n", "<leader>nc", ":e $MYVIMRC<CR>", { desc = "Open nvim config" })
vim.keymap.set("n", "<leader>np", ":Lazy<CR>", { desc = "Open lazy.nvim" })
vim.keymap.set("n", "<leader>nm", ":Mason<CR>", { desc = "Open mason.nvim" })

-- Misc
vim.keymap.set("n", "<leader>nl", "<Esc>:nohlsearch<CR>", { desc = "Clear highlights" })
vim.keymap.set("n", "<leader>=", "<C-a>", { desc = "Increment number" })
vim.keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- =======================================================
-- 			Commands
-- =======================================================

-- commands for disabling and enabling completions
vim.api.nvim_create_user_command("CmpEnable", function()
  require("cmp").setup({ enabled = true })
end, {})
vim.api.nvim_create_user_command("CmpDisable", function()
  require("cmp").setup({ enabled = false })
end, {})

-- SimpleMode custom commands
-- SimpleMode disables LSP, autocompletion and syntax highlighting
function EnableSimpleMode()
  vim.cmd([[
        LspStop
        TSBufDisable highlight
        set syntax=off
    ]])
  require("cmp").setup({ enabled = false })
end

function DisableSimpleMode()
  vim.cmd([[
        LspStart
        TSBufEnable highlight
        set syntax=on
    ]])
  require("cmp").setup({ enabled = true })
end

vim.api.nvim_create_user_command("SimpleModeEnable", function()
  EnableSimpleMode()
  pcall(function()
    vim.api.nvim_del_augroup_by_name("simplemode")
  end)
  vim.api.nvim_create_autocmd("BufReadPost", {
    command = "lua EnableSimpleMode()",
    group = vim.api.nvim_create_augroup("simplemode", { clear = true }),
  })
end, {})

vim.api.nvim_create_user_command("SimpleModeDisable", function()
  DisableSimpleMode()
  pcall(function()
    vim.api.nvim_del_augroup_by_name("simplemode")
  end)
end, {})

-- disable copilot by default
require("copilot.command").disable()

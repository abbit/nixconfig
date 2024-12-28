-- easily configure LSP
-- code adapted from https://github.com/LazyVim/LazyVim/blob/d01a58ef904b9e11378e5c175f3389964c69169d/lua/lazyvim/plugins/lsp/init.lua
-- TODO: mb split setup for each lang into separate files

local function on_supports_method(method, fn)
  return vim.api.nvim_create_autocmd("User", {
    pattern = "LspSupportsMethod",
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local buffer = args.data.buffer ---@type number
      if client and method == args.data.method then
        return fn(client, buffer)
      end
    end,
  })
end

local function toggle_inlay_hints(buf, value)
  local ih = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint
  if type(ih) == "function" then
    ih(buf, value)
  elseif type(ih) == "table" and ih.enable then
    if value == nil then
      value = not ih.is_enabled({ bufnr = buf or 0 })
    end
    ih.enable(value, { bufnr = buf })
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- manage lsp servers, daps, linters and formatters
      { "williamboman/mason.nvim", opts = {} },
      { "williamboman/mason-lspconfig.nvim", config = function() end },
    },
    ---@class PluginLspOpts
    opts = function()
      local runtime_path = vim.split(package.path, ";")
      table.insert(runtime_path, "lua/?.lua")
      table.insert(runtime_path, "lua/?/init.lua")

      return {
        -- options for vim.diagnostic.config()
        ---@type vim.diagnostic.Opts
        diagnostics = {
          -- inline diagnostic messages
          virtual_text = {
            spacing = 1,
            prefix = "▎",
            -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
            -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
            -- prefix = "icons",
          },
          severity_sort = true,
          -- show diagnostics in the preview window
          float = {
            style = "minimal",
            border = "rounded",
            source = true,
            header = "",
            prefix = "",
          },
          -- icons for diagnostics in the sign column
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = "✘",
              [vim.diagnostic.severity.WARN] = "",
              [vim.diagnostic.severity.HINT] = "󰌵",
              [vim.diagnostic.severity.INFO] = "",
            },
          },
        },
        -- Enable the builtin LSP inlay hints
        -- Be aware that you also will need to properly configure your LSP server to provide the inlay hints.
        inlay_hints = {
          enabled = true,
          -- filetypes for which you don't want to enable inlay hints
          exclude = {},
        },
        -- Enable the builtin LSP code lenses
        -- Be aware that you also will need to properly configure your LSP server to provide the code lenses.
        codelens = {
          enabled = true,
        },
        -- add any global capabilities here
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
        -- options for vim.lsp.buf.format
        -- `bufnr` and `filter` is handled by the LazyVim formatter,
        -- but can be also overridden when specified
        format = {
          formatting_options = nil,
          timeout_ms = nil,
        },
        -- LSP Server Settings
        servers = {
          -- lua
          lua_ls = {
            settings = {
              Lua = {
                -- Disable telemetry
                telemetry = { enable = false },
                runtime = {
                  -- Tell the language server which version of Lua you're using
                  -- (most likely LuaJIT in the case of Neovim)
                  version = "LuaJIT",
                  path = runtime_path,
                },
                diagnostics = {
                  -- Get the language server to recognize the `vim` global
                  globals = { "vim" },
                },
                workspace = {
                  checkThirdParty = false,
                  library = {
                    -- Make the server aware of Neovim runtime files
                    vim.fn.expand("$VIMRUNTIME/lua"),
                    vim.fn.stdpath("config") .. "/lua",
                  },
                },
              },
            },
          },
          -- rust
          rust_analyzer = {
            settings = {
              ["rust-analyzer"] = {
                checkOnSave = { command = "clippy" },
                files = {
                  excludeDirs = { ".direnv", ".git", "target" },
                  watcherExclude = { ".direnv", ".git", "target" },
                },
              },
            },
          },
          -- c and cpp
          clangd = {
            filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
          },
          terraformls = {},
        },
        -- you can do any additional lsp server setup here
        -- return true if you don't want this server to be setup with lspconfig
        setup = {
          -- example to setup with typescript.nvim
          -- tsserver = function(_, opts)
          --   require("typescript").setup({ server = opts })
          --   return true
          -- end,
          -- Specify * to use this function as a fallback for any server
          -- ["*"] = function(server, opts) end,
        },
      }
    end,
    config = function(_, opts)
      vim.api.nvim_create_autocmd("LspAttach", {
        desc = "LSP actions",
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end
          local telescope_builtin = require("telescope.builtin")

          -- LSP actions
          map("K", vim.lsp.buf.hover, "")
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

          map("<F2>", vim.lsp.buf.rename, "")
          map("<F4>", vim.lsp.buf.code_action, "")
        end,
      })

      -- configure diagnostics

      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- style lsp windows

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

      vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

      -- configure inlay hints

      if opts.inlay_hints.enabled then
        on_supports_method("textDocument/inlayHint", function(client, buffer)
          if
            vim.api.nvim_buf_is_valid(buffer)
            and vim.bo[buffer].buftype == ""
            and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
          then
            toggle_inlay_hints(buffer, true)
          end
        end)
      end

      -- configure code lens

      if opts.codelens.enabled and vim.lsp.codelens then
        on_supports_method("textDocument/codeLens", function(client, buffer)
          vim.lsp.codelens.refresh()
          vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            buffer = buffer,
            callback = vim.lsp.codelens.refresh,
          })
        end)
      end

      -- setup LSP servers

      local servers = opts.servers
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities(),
        opts.capabilities or {}
      )

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then
            return
          end
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then
            return
          end
        end
        require("lspconfig")[server].setup(server_opts)
      end

      require("mason-lspconfig").setup({
        -- A list of servers to automatically install if they're not already installed.
        ensure_installed = {},
        -- See `:h mason-lspconfig.setup_handlers()`
        handlers = { setup },
      })
    end,
  },
  -- show function signature while typing
  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    opts = {
      hint_prefix = {
        above = "↙ ", -- when the hint is on the line above the current line
        current = "← ", -- when the hint is on the same line
        below = "↖ ", -- when the hint is on the line below the current line
      },
    },
  },
}

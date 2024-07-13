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

-- github copilot
return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",

    config = function()
      require("copilot").setup({
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
          yaml = true,
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
      })

      require("copilot.command").disable() -- disable copilot by default
    end,
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
}

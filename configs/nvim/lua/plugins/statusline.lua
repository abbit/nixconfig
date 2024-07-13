local function lsp_get_clients(opts)
  local ret = {}
  if vim.lsp.get_clients then
    ret = vim.lsp.get_clients(opts)
  else
    ---@diagnostic disable-next-line: deprecated
    ret = vim.lsp.get_active_clients(opts)
    if opts and opts.method then
      ret = vim.tbl_filter(function(client)
        return client.supports_method(opts.method, { bufnr = opts.bufnr })
      end, ret)
    end
  end
  return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
end

-- statusline
return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
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
        local clients = vim.lsp.get_clients()
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
}

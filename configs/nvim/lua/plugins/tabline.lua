-- tabline
return {
  "akinsho/bufferline.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  event = "BufEnter",
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
}

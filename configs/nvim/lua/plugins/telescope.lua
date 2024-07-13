-- fuzzy finder
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { -- If encountering errors, see telescope-fzf-native README for install instructions
      "nvim-telescope/telescope-fzf-native.nvim",
      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = "make",
      -- `cond` is a condition used to determine whether this plugin should be installed and loaded.
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
    "nvim-telescope/telescope-live-grep-args.nvim",
  },
  config = function()
    local telescope = require("telescope")

    pcall(telescope.load_extension, "fzf") -- enable if installed
    telescope.load_extension("live_grep_args")

    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>bl", builtin.buffers, { desc = "List buffers" })
    vim.keymap.set("n", "<leader>.", builtin.find_files, { desc = "Find file" })
    vim.keymap.set("n", "<leader>/", telescope.extensions.live_grep_args.live_grep_args, { desc = "Live grep" })
    vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
  end,
}

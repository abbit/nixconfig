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
    "nvim-telescope/telescope-file-browser.nvim",
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      extensions = {
        file_browser = {
          path = "%:p:h", -- open from within the folder of your current buffer
          display_stat = false, -- don't show file stat
          grouped = true, -- group initial sorting by directories and then files
          hidden = true, -- show hidden files
          hide_parent_dir = true, -- hide `../` in the file browser
          hijack_netrw = true, -- use telescope file browser when opening directory paths
          prompt_path = true, -- show the current relative path from cwd as the prompt prefix
          use_fd = true, -- use `fd` instead of plenary, make sure to install `fd`
        },
      },
    })

    pcall(telescope.load_extension, "fzf") -- enable if installed
    telescope.load_extension("live_grep_args")
    -- To get telescope-file-browser loaded and working with telescope,
    -- you need to call load_extension, somewhere after setup function:
    telescope.load_extension("file_browser")

    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>bl", builtin.buffers, { desc = "List buffers" })
    vim.keymap.set("n", "<leader>.", builtin.find_files, { desc = "Find file" })
    vim.keymap.set("n", "<leader>/", telescope.extensions.live_grep_args.live_grep_args, { desc = "Live grep" })
    vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
    vim.keymap.set("n", "<leader>fl", telescope.extensions.file_browser.file_browser, { desc = "File browser" })
  end,
}

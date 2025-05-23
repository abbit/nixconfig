-- show which lines have been changed
return {
  "lewis6991/gitsigns.nvim",
  opts = {
    on_attach = function(buffer)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
      end

        -- stylua: ignore start
        map("n", "<leader>g]", gs.next_hunk, "Next Hunk")
        map("n", "<leader>g[", gs.prev_hunk, "Prev Hunk")
        map("n", "<leader>gp", gs.preview_hunk, "Preview Hunk")
        map({ "n", "v" }, "<leader>gs", gs.stage_hunk, "Stage Hunk")
        map({ "n", "v" }, "<leader>gr", gs.reset_hunk, "Reset Hunk")
        map("n", "<leader>gu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>gS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>gU", gs.reset_buffer_index, "Undo Stage Buffer")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>gd", gs.diffthis, "Diff This")
    end,
  },
}

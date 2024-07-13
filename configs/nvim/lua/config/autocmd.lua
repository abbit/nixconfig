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

local dashgate = require("dashgate")

-- Set DashGate as the command to display the dashboard
vim.api.nvim_create_user_command("DashGate", function()
  dashgate.show()
end, { desc = "Display DashGate Dashboard" })

-- When a UI opens, display the dashboard if a file was not chosen
vim.api.nvim_create_autocmd("UIEnter", {
  callback = function()
    if vim.fn.argc() == 0 and vim.bo.filetype == "" then
      dashgate.show()
    end
  end,
})

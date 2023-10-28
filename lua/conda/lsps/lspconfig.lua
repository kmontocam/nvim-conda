local M = {}

---@return nil
M.restart_lsps = function()
  vim.api.nvim_command("LspRestart")
end

return M

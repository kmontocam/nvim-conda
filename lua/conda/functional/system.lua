local M = {}

---@return string
function M.get_running_shell()
  return vim.api.nvim_get_option("shell"):match("[^/\\]+$")
end

return M

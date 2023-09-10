local M = {}

---@return nil
M.restart_lsps = function()
	--TODO: prevent error messages in `create_menu()` buffer with Lspsaga
	vim.api.nvim_command("LspRestart")
end

return M

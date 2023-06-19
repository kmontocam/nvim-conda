local M = {}

---@return nil
M.restart_lsps = function()
	vim.api.nvim_command("LspStop")
	vim.defer_fn(function()
		vim.api.nvim_command("LspStart")
	end, 500)
end

return M

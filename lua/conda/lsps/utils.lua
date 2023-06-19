local M = {}

--TODO: add support for coc.nvim lsp client
---@return string? # lsp client name
M.get_active_lsp_client = function()
	local lspconfig_status, _ = pcall(require, "lspconfig")
	if lspconfig_status then
		return "lspconfig"
	else
		return nil
	end
end

--TODO: add support for coc.nvim lsp client
---@return nil
M.restart_lsps = function()
	local lsp_client = M.get_active_lsp_client()

	if lsp_client == "lspconfig" then
		require("conda.lsps.lspconfig"):restart_lsps()
	-- elseif lsp_client == "coc" then
	-- 	return nil
	else
		return nil
	end
end

return M

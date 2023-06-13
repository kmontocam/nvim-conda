local M = {}

---@param arg_lead string, current argument in vim command line
---@param tab table, list of available options
---@return table
function M.vim_subcommand(arg_lead, tab)
	local arg_matches = vim.tbl_filter(function(tab_lead)
		return tab_lead:sub(1, #arg_lead) == arg_lead
	end, tab)
	return arg_matches
end

return M

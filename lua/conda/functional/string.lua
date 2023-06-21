local M = {}

---@param shell_output string
---@return string
M.clean_vim_activator = function(shell_output)
	-- clean output in case Neovim is set to a non interactive mode
	local clean_output = {}
	for line in shell_output:gmatch("[^\r\n]+") do
		if string.match(line, "^(let|unlet)") then
			table.insert(clean_output, line)
		end
	end
	return table.concat(clean_output, "\n")
end

return M

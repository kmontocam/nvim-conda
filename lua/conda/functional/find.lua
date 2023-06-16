local M = {}

---@param tab table, table containing elements to search, can be nested
---@param search_value string, string to search for
---@return boolean, string? # lowest key of searched value if found
function M.has_value(tab, search_value)
	for k, v in pairs(tab) do
		if type(v) == "table" then
			if M.has_value(v, search_value) then
				return true, k
			end
		elseif v == search_value then
			return true, k
		end
	end
	return false
end

---@param matches table, table to store matches
---@param tab table, table containing elements to search, can be nested
---@param pattern string, regex parttern to match strings on table
---@return table # matches of given pattern
function M.table_regex_match(matches, tab, pattern)
	for _, v in pairs(tab) do
		if type(v) == "table" then
			M.table_regex_match(matches, v, pattern)
		elseif string.match(v, pattern) then
			local match = string.match(v, pattern)
			table.insert(matches, match)
		end
	end
	return matches
end

return M

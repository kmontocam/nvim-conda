local M = {}

---@param tab table
---@return table
function M.table_to_set(tab)
  local set = {}
  for _, v in ipairs(tab) do
    set[v] = true
  end
  return set
end

---@param a table
---@param b table
---@return table
function M.intersection(a, b)
  local in_a = {}
  for _, v in pairs(a) do
    in_a[v] = true
  end

  local common = {}
  local n = 0
  for _, v in pairs(b) do
    if in_a[v] then
      in_a[v] = false
      n = n + 1
      common[n] = v
    end
  end
  return common
end

return M

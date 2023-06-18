local utils = require("conda.utils")
local set = require("conda.functional.set")
local envs = {}

---@param env_name string, name of an existing conda environment
---@param conda_envs table, table containing existing conda environments
---@return nil
function envs.activate(env_name, conda_envs)
	if set.table_to_set(conda_envs)[env_name] == nil then
		print("The environment " .. env_name .. " does not exist")
		return nil
	end

	local subcommand = "activate"
	local activator_command = utils.get_activator_command(subcommand, env_name)
	if activator_command == nil then
		print("The current shell is not supported by conda")
		return nil
	end
	local vim_conda_activate_command = (vim.fn.system(activator_command))
	vim.cmd(vim_conda_activate_command)
end

---@return nil
function envs.deactivate()
	local subcommand = "deactivate"
	local activator_command = utils.get_activator_command(subcommand)
	if activator_command == nil then
		print("The current shell is not supported by conda")
		return nil
	end
	local vim_conda_deactivate_command = (vim.fn.system(activator_command))
	vim.cmd(vim_conda_deactivate_command)
end

return envs

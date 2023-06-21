local envs = require("conda.envs")
local utils = require("conda.utils")
local autocomplete = require("conda.ui.autocomplete")
local lsps_utils = require("conda.lsps.utils")

if vim.fn.executable("conda") == 0 then
	print(
		"nvim-conda: the conda command was not found. Please ensure that you"
			.. " have it installed and referenced in the PATH variable"
	)
	return nil
end

local conda_envs = utils.get_conda_environments()

---@param opts table
---@return nil
vim.api.nvim_create_user_command("CondaActivate", function(opts)
	local env_name = string.len(opts.args) > 0 and opts.args or nil
	if env_name then
		envs.activate(env_name, conda_envs)
		lsps_utils.restart_lsps()
	else
		--TODO: implement UI for choosing environment
		print("Please follow the command with an environment name")
		return nil
	end
end, {
	desc = "Equivalent to `conda activate env_name`. Start environment in Neovim session.",
	nargs = "?",
	---@param arg_lead string
	complete = function(arg_lead)
		return autocomplete.vim_subcommand(arg_lead, conda_envs)
	end,
})

---@return nil
vim.api.nvim_create_user_command("CondaDeactivate", function()
	envs.deactivate()
	lsps_utils.restart_lsps()
end, {
	desc = "Equivalent to `conda deactivate`. Stop environment in Neovim session.",
	nargs = 0,
})

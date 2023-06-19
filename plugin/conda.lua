-- user commands
local envs = require("conda.envs")
local utils = require("conda.utils")
local autocomplete = require("conda.ui.autocomplete")
local lsps_utils = require("conda.lsps.utils")

if not vim.fn.executable("conda") then
	print(
		"Conda was not found in your current shell. Please make sure you have it installed and initalized `conda init`"
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
		print("...")
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

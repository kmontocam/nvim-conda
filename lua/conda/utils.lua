local find = require("conda.functional.find")
local utils = {}

--retrieved from conda activate documentation
--supported shells as of conda 4.11
utils.activator_shells = {
	posix = {
		"ash",
		"bash",
		"dash",
		"zsh",
	},
	csh = {
		"csh",
		"tcsh",
	},
	xonsh = {
		"xonsh",
	},
	cmd_exe = {
		"cmd.exe",
	},
	fish = {
		"fish",
	},
	powershell = {
		"powershell",
	},
}

-- conda purpose functions

---@return table
function utils.get_conda_environments()
	local handle = io.popen("conda env list --json")
	if handle then
		utils.conda_envs_path_json = handle:read("*a")
		handle:close()
	end
	local conda_envs_path = vim.fn.json_decode(utils.conda_envs_path_json)
	local matches = {}
	local conda_envs = find.table_regex_match(matches, conda_envs_path, "[\\/]envs[\\/](.*)")
	table.insert(conda_envs, "base")
	return conda_envs
end

--TODO: add shell command for cmd.exe, currently not supported because of
--lack of regex in the shell.
---@param subcommand string, modify conda function
---@param env_name string | nil, name of an existing conda environment
---@return string? # command to run on user's terminal so conda
--envrionment's can be modified inside neovim's shell.
function utils.get_activator_command(subcommand, env_name)
	utils.running_shell = vim.api.nvim_get_option("shell"):match("[^/\\]+$")

	utils.activator_commands = {
		posix = {
			activate = (
				"conda shell."
				.. utils.running_shell
				.. " activate "
				.. env_name
				.. " | sed -e 's/export \\([^=]*\\)=\\(.*\\)/let \\$\\1=\\2/g'"
				.. " -e 's/^\\([^[:space:]]*\\)=\\(.*\\)/let \\1=\\2/g'"
			),
			deactivate = (
				"conda shell."
				.. utils.running_shell
				.. " deactivate "
				.. "| sed -e 's/export \\([^=]*\\)=\\(.*\\)/let \\$\\1=\\2/g'"
				.. " -e 's/^\\([^[:space:]]*\\)=\\(.*\\)/let \\1=\\2/g'"
				.. " -e 's/unset \\([^=]*\\)/unlet \\$\\1/g'"
			),
		},
		csh = {
			activate = (
				"conda shell."
				.. utils.running_shell
				.. " activate "
				.. env_name
				.. " | sed -e 's/setenv \\([^[:space:]]*\\) \\(.*\\);/let \\$\\1=\\2/g'"
				.. " -e 's/set \\([^=]*\\)=\\(.*\\);/let \\1=\\2/g'"
			),
			deactivate = (
				"conda shell."
				.. utils.running_shell
				.. " deactivate "
				.. " | sed -e 's/setenv \\([^[:space:]]*\\) \\(.*\\);/let \\$\\1=\\2/g'"
				.. " -e 's/set \\([^=]*\\)=\\(.*\\);/let \\1=\\2/g'"
				.. " -e 's/unsetenv \\([^=]*\\);/unlet \\$\\1/g'"
			),
		},
		xonsh = {
			activate = ("conda shell." .. utils.running_shell .. " activate " .. env_name .. " | sed -e 's/^/let /g'"),
			deactivate = (
				"conda shell."
				.. utils.running_shell
				.. " deactivate "
				.. "| sed -e 's/del/unlet/g'"
				.. " -e 's/\\\\([^=]*\\\\) = \\\\(.*\\\\)/let \\\\1 = \\\\2/g'"
			),
		},
		cmd_exe = "...",
		fish = {
			activate = (
				"conda shell."
				.. utils.running_shell
				.. " activate "
				.. env_name
				.. " | sed -e 's/set -gx \\([^[:space:]]*\\) \\(.*\\);/let \\$\\1=\\2/g'"
				.. [[ -e '/PATH=/ s/\\("[^=][\\s]*\\)"/:/g']]
			),
			deactivate = (
				"conda shell."
				.. utils.running_shell
				.. " deactivate "
				.. " | sed -e 's/set -gx \\([^[:space:]]*\\) \\(.*\\);/let \\$\\1=\\2/g'"
				.. " -e 's/set -e \\([^[:space:]]*\\);/unlet \\$\\1/g'"
				.. [[ -e '/PATH=/ s/\\("[^=][\\s]*\\)"/:/g']]
			),
		},
		powershell = {
			activate = (
				"conda shell."
				.. utils.running_shell
				.. " activate "
				.. env_name
				.. " | ForEach-Object {$_ -replace '(.*?):(.*)', 'let $$$2' }"
			),
			deactivate = (
				"conda shell."
				.. utils.running_shell
				.. " deactivate | ForEach-Object {$_ -replace '(.*?):(.*)', 'let $$$2' }"
			),
		},
	}

	local found, activator = find.has_value(utils.activator_shells, utils.running_shell)
	if found then
		return utils.activator_commands[activator][subcommand]
	else
		return nil
	end
end

return utils

local find = require("conda.functional.find")
local Job = require("plenary.job")
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
		"pwsh", -- if client is using powershell in Unix
	},
}

---@return table
function utils.get_conda_environments()
	local shell_output = {}
	local conda_envs = {}
	Job:new({
		command = "conda",
		args = { "env", "list" },
		on_stdout = function(_, stdout)
			table.insert(shell_output, stdout)
		end,
		on_exit = function()
			local _conda_envs = find.table_regex_match({}, shell_output, "[\\/]envs[\\/](.*)")
			table.move(_conda_envs, 1, #_conda_envs, #conda_envs + 1, conda_envs)
			table.insert(conda_envs, "base")
		end,
	}):start()
	return conda_envs
end

---@param subcommand string, modify conda function
---@param env_name string?, name of an existing conda environment. If nill,
--subcommand activate will treat it as base.
---@return string? # command to run on user's terminal so conda
--envrionments can be modified inside neovim's shell
function utils.get_activator_command(subcommand, env_name)
	utils.running_shell = vim.api.nvim_get_option("shell"):match("[^/\\]+$")
	if env_name == nil then
		env_name = ""
	end

	utils.activator_commands = {
		posix = {
			activate = (
				[[conda shell.]]
				.. utils.running_shell
				.. [[ activate ]]
				.. env_name
				.. [[ | sed -e 's/export \([^=]*\)=\(.*\)/let \$\1=\2/g']]
				.. " -e 's/^\\([^[:space:]]*\\)=\\(.*\\)/let \\1=\\2/g'"
			),
			deactivate = (
				[[conda shell.]]
				.. utils.running_shell
				.. [[ deactivate]]
				.. [[ | sed -e 's/export \([^=]*\)=\(.*\)/let \$\1=\2/g']]
				.. " -e 's/^\\([^[:space:]]*\\)=\\(.*\\)/let \\1=\\2/g'"
				.. [[ -e 's/unset \([^=]*\)/unlet \$\1/g']]
			),
		},
		csh = {
			activate = (
				[[conda shell.]]
				.. utils.running_shell
				.. [[ activate ]]
				.. env_name
				.. " | sed -e 's/setenv \\([^[:space:]]*\\) \\(.*\\);/let \\$\\1=\\2/g'"
				.. [[ -e 's/set \([^=]*\)=\(.*\);/let \1=\2/g']]
			),
			deactivate = (
				[[conda shell.]]
				.. utils.running_shell
				.. [[ deactivate]]
				.. " | sed -e 's/setenv \\([^[:space:]]*\\) \\(.*\\);/let \\$\\1=\\2/g'"
				.. [[ -e 's/set \([^=]*\)=\(.*\);/let \1=\2/g']]
				.. [[ -e 's/unsetenv \([^=]*\);/unlet \$\1/g']]
			),
		},
		xonsh = {
			activate = ("conda shell." .. utils.running_shell .. " activate " .. env_name .. " | sed -e 's/^/let /g'"),
			deactivate = (
				[[conda shell.]]
				.. utils.running_shell
				.. [[ deactivate]]
				.. [[ | sed -e 's/del/unlet/g']]
				.. [[ -e 's/\\([^=]*\\) = \\(.*\\)/let \\1 = \\2/g']]
			),
		},
		cmd_exe = {
			activate = (
				[[powershell -command "Get-Content -Path (Invoke-Expression -Command 'cmd.exe /c conda shell.]]
				.. [[cmd.exe]]
				.. [[ activate ]]
				.. env_name
				.. [[') | ForEach-Object {$_ -replace '^^@SET \"([^^=]+)=(.*)\"', 'let $$$1=\"$2\"'}]]
				.. [[ | ForEach-Object {$_ -replace '\\', '\\'}"]]
			),
			deactivate = (
				[[powershell -command "Get-Content -Path (Invoke-Expression -Command 'cmd.exe /c conda shell.]]
				.. [[cmd.exe]]
				.. [[ deactivate')]]
				.. [[ | ForEach-Object {$_ -replace '^^@SET \"([^^=]+)=(.*)\"', 'let $$$1=\"$2\"'}]]
				.. [[ | ForEach-Object {$_ -replace '\\', '\\'}"]]
			),
		},
		fish = {
			activate = (
				[[conda shell.]]
				.. utils.running_shell
				.. [[ activate ]]
				.. env_name
				.. " | sed -e 's/set -gx \\([^[:space:]]*\\) \\(.*\\);/let \\$\\1=\\2/g'"
				.. [[ -e '/PATH=/ s/\("[^=][:space:]*\)"/:/g']]
			),
			deactivate = (
				[[conda shell.]]
				.. utils.running_shell
				.. [[ deactivate]]
				.. " | sed -e 's/set -gx \\([^[:space:]]*\\) \\(.*\\);/let \\$\\1=\\2/g'"
				.. " -e 's/set -e \\([^[:space:]]*\\);/unlet \\$\\1/g'"
				.. [[ -e '/PATH=/ s/\("[^=][:space:]*\)"/:/g']]
			),
		},
		powershell = {
			activate = (
				[[conda shell.]]
				.. [[powershell]]
				.. [[ activate ]]
				.. env_name
				.. [[ | ForEach-Object {$_ -replace '(.*?):(.*)', 'let $$$2' }]]
				.. [[ | ForEach-Object {$_ -replace '\\', '\\'}"]]
			),
			deactivate = (
				[[conda shell.]]
				.. [[powershell]]
				.. [[ deactivate]]
				.. [[ | ForEach-Object {$_ -replace '(.*?):(.*)', 'let $$$2' }]]
				.. [[ | ForEach-Object {$_ -replace '\\', '\\'}"]]
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

local envs = require("conda.envs")
local utils = require("conda.utils")
local autocomplete = require("conda.ui.autocomplete")
local window = require("conda.ui.window")
local set = require("conda.functional.set")
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
    if set.table_to_set(conda_envs)[env_name] == nil then
      print("The environment " .. env_name .. " does not exist")
      return nil
    else
      envs.activate(env_name)
      lsps_utils.restart_lsps()
    end
  else
    -- no environment given triggers menu
    window.env_activation_menu(conda_envs, function(_, env_sel)
      envs.activate(env_sel)
      lsps_utils.restart_lsps()
    end)
  end
  return nil
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

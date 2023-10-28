local popup = require("plenary.popup")
local M = {}

M.create_menu = function(opts, cb)
  local height = 8
  local width = 24
  local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

  M.win_id, M.win = popup.create(opts, {
    title = "Conda Environments",
    highlight = "Normal",
    line = math.floor(((vim.o.lines - height) / 2) - 1),
    col = math.floor((vim.o.columns - width) / 2),
    minwidth = width,
    minheight = height,
    borderchars = borderchars,
    callback = cb,
  })

  local bufnr = vim.api.nvim_win_get_buf(M.win_id)
  vim.api.nvim_win_set_option(M.win_id, "number", true)
  vim.api.nvim_win_set_option(M.win.border.win_id, "winhl", "Normal:Normal")

  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "delete")
  vim.api.nvim_buf_set_keymap(
    bufnr,
    "n",
    "q",
    "<cmd>lua require('conda.ui.window').close_menu()<cr>",
    { silent = false }
  )
  vim.api.nvim_buf_set_keymap(
    bufnr,
    "n",
    "<ESC>",
    "<cmd>lua require('conda.ui.window').close_menu()<cr>",
    { silent = false }
  )

  vim.cmd("autocmd BufLeave <buffer> ++nested ++once silent lua require('conda.ui.window').close_menu()")
end

M.close_menu = function()
  vim.api.nvim_win_close(M.win_id, true)
end

return M

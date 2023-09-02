local M = {}

local utils = require("leetbuddy.utils")
local config = require("leetbuddy.config")
local info = require("leetbuddy.display").info
local i18n = require("leetbuddy.config").domain

local input_buffer
local results_buffer

function M.start_problem(q_id, slug)
  local question_slug = string.format("%04d-%s", q_id, slug)

  local code_file_path = utils.get_code_file_path(question_slug, config.language)
  local test_case_path = utils.get_test_case_path(question_slug)
  local question_path = utils.get_question_path(question_slug)

  if M.get_results_buffer() then
    vim.api.nvim_command("LBClose")
  end

  if not utils.file_exists(code_file_path) then
    vim.api.nvim_command(":silent !touch " .. code_file_path)
    vim.api.nvim_command(":silent !touch " .. test_case_path)
    vim.api.nvim_command(":silent !touch " .. question_path)
    vim.api.nvim_command("edit! " .. code_file_path)
    vim.api.nvim_command("LBReset")
  else
    vim.api.nvim_command("edit! " .. code_file_path)
  end
  vim.api.nvim_command("LBSplit")
  vim.api.nvim_command("LBQuestion")
end

function M.split()
  local code_buffer = vim.api.nvim_get_current_buf()

  if input_buffer == nil then
    input_buffer = vim.api.nvim_create_buf(false, false)
  end
  if results_buffer == nil then
    results_buffer = vim.api.nvim_create_buf(false, false)
  end

  vim.api.nvim_buf_set_option(input_buffer, "swapfile", false)
  vim.api.nvim_buf_set_option(input_buffer, "buflisted", false)

  vim.api.nvim_buf_set_option(results_buffer, "swapfile", false)
  vim.api.nvim_buf_set_option(results_buffer, "buflisted", false)
  vim.api.nvim_buf_set_option(results_buffer, "buftype", "nofile")
  vim.api.nvim_buf_set_option(results_buffer, "filetype", "Results")

  vim.api.nvim_buf_call(code_buffer, function()
    vim.cmd("botright vsplit " .. utils.get_current_buf_test_case())
  end)

  vim.api.nvim_buf_call(input_buffer, function()
    vim.cmd("rightbelow split +buffer" .. results_buffer)
  end)

  vim.api.nvim_buf_call(code_buffer, function()
    vim.cmd("vertical resize 200")
  end)

  vim.api.nvim_buf_call(results_buffer, function()
    vim.cmd("set nonumber")
    vim.cmd("set norelativenumber")
    local highlights = {
      -- [""] = "TabLineSel IncSearch",
      [".* Error.*"] = "StatusLine",
      [".*Line.*"] = "ErrorMsg",
    }
    local  extra_highlights = {
        [info["res"][i18n]] = "TabLineFill",
        [info["acc"][i18n]] = "DiffAdd",
        [info["pc"][i18n]] = "DiffAdd",
        [info["totc"][i18n]] = "DiffAdd",
        [info["f_case_in"][i18n]] = "ErrorMsg",
        [info["wrong_ans_err"][i18n]] = "ErrorMsg",
        [info["failed"][i18n]] = "ErrorMsg",
        [info["testc"][i18n] .. ": #\\d\\+"] = "Title",
        [info["mem"][i18n] .. ": .*"] = "Title",
        [info["rt"][i18n] .. ": .*"] = "Title",
        [info["exp"][i18n]] = "Type",
        [info["out"][i18n]] = "Type",
        [info["exp_out"][i18n]] = "Type",
        [info["stdo"][i18n]] = "Type",
        [info["exe"][i18n] .. "..."] = "Todo",
      }

    highlights = vim.tbl_deep_extend("force", highlights, extra_highlights)

    for match, group in pairs(highlights) do
      vim.fn.matchadd(group, match)
    end
  end)
end

function M.get_input_buffer()
  if input_buffer == nil then
    M.split()
  end
  return input_buffer
end

function M.get_results_buffer()
    if results_buffer == nil then
        M.split()
    end
  return results_buffer
end

local function close_buffer_window(win)
  local num = vim.api.nvim_win_get_number(win) - 1
  vim.cmd(num .. "close")
end

function M.close_split()
  if input_buffer then
    vim.api.nvim_buf_call(input_buffer, function()
      close_buffer_window(vim.api.nvim_get_current_win())
    end)
  end
  if results_buffer then
    vim.api.nvim_buf_call(results_buffer, function()
      close_buffer_window(vim.api.nvim_get_current_win())
    end)
  end

  if utils.is_in_folder(vim.api.nvim_buf_get_name(0), config.directory) then
    local buf_name = vim.api.nvim_buf_get_name(0)
    local id_slug = utils.get_current_buf_id_slug_name()
    vim.cmd("silent! bd " .. buf_name)
    vim.cmd("silent! bd " .. utils.get_test_case_path(id_slug))
  end
  input_buffer = nil
  results_buffer = nil
end

return M

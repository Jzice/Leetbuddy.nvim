local utils = require("leetbuddy.utils")
local question_data = require("leetbuddy.question_data")

local M = {}

M.question_content = vim.NIL
M.pre_slug = vim.NIL

local old_contents

local function display_question_content(contents, oldqbufnr)
  Qbufnr = oldqbufnr or vim.api.nvim_create_buf(true, true)

  local width = math.ceil(math.min(vim.o.columns, math.max(90, vim.o.columns - 20)))
  local height = math.ceil(math.min(vim.o.lines, math.max(25, vim.o.lines - 10)))

  local row = math.ceil(vim.o.lines - height) * 0.5 - 1
  local col = math.ceil(vim.o.columns - width) * 0.5 - 1

  vim.api.nvim_open_win(Qbufnr, true, {
    border = "rounded",
    style = "minimal",
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
  })

  if not oldqbufnr then
    local c = utils.pad(contents)
    vim.api.nvim_buf_set_lines(Qbufnr, 0, -1, true, c)
    vim.api.nvim_buf_set_option(Qbufnr, "swapfile", false)
    vim.api.nvim_buf_set_option(Qbufnr, "modifiable", false)
    vim.api.nvim_buf_set_option(Qbufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_option(Qbufnr, "filetype", "markdown")
    vim.api.nvim_buf_set_option(Qbufnr, "buflisted", false)
    vim.api.nvim_buf_set_keymap(Qbufnr, "n", "<esc>", "<cmd>hide<CR>", { noremap = true })
    vim.api.nvim_buf_set_keymap(Qbufnr, "n", "q", "<cmd>hide<CR>", { noremap = true })
  end

  vim.api.nvim_buf_set_keymap(Qbufnr, "v", "q", "<cmd>hide<CR>", { noremap = true })
  if contents ~= old_contents then
    contents = utils.pad(contents, { pad_top = 1 })
    vim.api.nvim_buf_set_option(Qbufnr, "modifiable", true)
    vim.api.nvim_buf_set_lines(Qbufnr, 0, -1, true, contents)
    vim.api.nvim_buf_set_option(Qbufnr, "modifiable", false)
  end

  old_contents = contents

  return Qbufnr
end

local function encode_question_content(slug)
end

function M.question()
    local slug = utils.get_cur_buf_slug()
    if M.pre_slug ~= slug then
        local data = question_data.get_question_data(slug)
        if data == vim.NIL then
            return "You don't have a premium plan"
        end
        local content = string.format(
            "# %s.%s\r\n\r\n%s",
            data["questionFrontendId"], data["title"],
            data["content"]
        )
        M.question_content = utils.split_string_to_table(content)
        M.pre_slug = slug
    end

    display_question_content(M.question_content, Qbufnr)
end

return M

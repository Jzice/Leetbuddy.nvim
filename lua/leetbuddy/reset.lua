local utils = require("leetbuddy.utils")
local config = require("leetbuddy.config")
local qdata = require("leetbuddy.question")

local M = {}

function M.reset_question()
  if utils.is_in_folder(vim.api.nvim_buf_get_name(0), config.directory) then
    local slug_name = utils.get_current_buf_slug_name()

    local question = qdata.fetch_question_data(slug_name)
    local ext = utils.get_file_extension(vim.fn.expand("%:t"))
    local question_id = question["questionFrontendId"]
    local title = question["title"]
    local content = question["content"]

    for _, table in ipairs(question["codeSnippets"]) do
      if table.langSlug == utils.langSlugToFileExt[ext] then
          local question_data = {
              question_id = question_id,
              slug = slug_name,
              lang = utils.langSlugToFileExt[ext],
              difficulty = question['difficulty'],
              ac_rate = question['acRate'] * 100,
              test_case = question['sampleTestCase'],
              title = title,
              content = content,
              code = table.code,
          }
        local code_src = utils.encode_code_by_templ( question_data)
        vim.api.nvim_buf_set_lines(
          vim.api.nvim_get_current_buf(),
          0,
          -1,
          false,
          utils.split_string_to_table(code_src)
        )
        break
      end
    end

    local question_slug = string.format("%04d-%s", question_id, slug_name)
    local test_case_path = utils.get_test_case_path(question_slug)
    local test_case_file = io.open(test_case_path, "w")
    if test_case_file then
      test_case_file:write(question["sampleTestCase"])
      test_case_file:close()
    else
      print("Failed to open test_case file.")
    end

    local question_path = utils.get_question_path(question_slug)
    local question_file = io.open(question_path, "w")
    if question_file then
      question_file:write(question["content"])
      question_file:close()
    else
      print("Failed to open question file.")
    end
  end
end

return M

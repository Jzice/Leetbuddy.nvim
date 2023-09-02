local sep = require("plenary.path").path.sep

local default_config = {
  domain = "com", -- Change to "cn" for china website
  directory = vim.loop.os_homedir() .. sep .. ".leetcode",
  language = "py",
  debug = false,
  page_next = "<Right>",
  page_prev = "<Left>",
  code_dir = "solution",
  test_case_dir = "test_case",
  question_dir = "question",
  code_tmpl_start = "// @lc code = start",
  code_tmpl_end = "// @lc code = end",
  code_template = [[
/*
@lc app=leetcode.cn id=%d lang=%s

# %d.%s

https://leetcode.%s/problems/%s/description/

%s

*/
use crate::solution::*;
%s
%s
%s
]],
}

return default_config

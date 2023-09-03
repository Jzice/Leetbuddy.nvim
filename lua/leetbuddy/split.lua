local M = {}

local utils = require("leetbuddy.utils")
local config = require("leetbuddy.config")
local info = require("leetbuddy.display").info
local i18n = require("leetbuddy.config").domain

local test_case_buffer_id
local results_buffer_id

function M.split()
    local code_buffer_id = vim.api.nvim_get_current_buf()
    if code_buffer_id == nil then
        utils.Debug("M.split() code_buffer_id is nil")
        return
    end

    -- 初始测试用例buffer
    if test_case_buffer_id == nil then
        test_case_buffer_id = vim.api.nvim_create_buf(false, false)
        utils.Debug(string.format("create test_case_buf: %d", test_case_buffer_id))
        vim.api.nvim_buf_set_option(test_case_buffer_id, "swapfile", false)
        vim.api.nvim_buf_set_option(test_case_buffer_id, "buflisted", false)

        vim.api.nvim_buf_call(code_buffer_id, function()
            vim.cmd(string.format("vert sb %d", test_case_buffer_id))
        end)
        utils.Debug("split(): vsplit test_case buffer id: "..test_case_buffer_id)
    end

    -- 加载测试用例数据到buffer
    local test_case_path = utils.get_cur_buf_test_case_path()
    vim.api.nvim_buf_call(test_case_buffer_id, function()
        vim.cmd("edit! "..test_case_path)
        vim.cmd("set nobuflisted")
    end)

    -- 初始化结果buffer窗口
    if results_buffer_id == nil then
        results_buffer_id = vim.api.nvim_create_buf(false, false)
        utils.Debug(string.format("create result_buf: %d", results_buffer_id))
        vim.api.nvim_buf_set_option(results_buffer_id, "swapfile", false)
        vim.api.nvim_buf_set_option(results_buffer_id, "buflisted", false)
        vim.api.nvim_buf_set_option(results_buffer_id, "buftype", "nofile")
        vim.api.nvim_buf_set_option(results_buffer_id, "filetype", "Results")
        vim.api.nvim_buf_call(test_case_buffer_id, function()
            vim.cmd("rightbelow split +buffer" .. results_buffer_id)
        end)
        vim.api.nvim_buf_call(results_buffer_id, function()
            vim.cmd("set nonumber")
            vim.cmd("set norelativenumber")
            local highlights = {
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

    -- 设置代码区大小
    vim.api.nvim_buf_call(code_buffer_id, function()
        vim.cmd("vertical resize 120")
    end)

end

function M.gej_test_case_buffer()
    if test_case_buffer_id == nil then
        M.split()
    end
    return test_case_buffer_id
end

function M.get_results_buffer()
    if results_buffer_id == nil then
        M.split()
    end
    return results_buffer_id
end

local function close_buffer_window(win)
    local num = vim.api.nvim_win_get_number(win) - 1
    vim.cmd(num .. "close")
    utils.Debug(string.format("close buffer win: %d", num))
end

function M.close_split()
    local file_name = utils.get_cur_buf_file_name()
    if test_case_buffer_id then
        vim.api.nvim_buf_call(test_case_buffer_id, function()
            close_buffer_window(vim.api.nvim_get_current_win())
        end)
        vim.cmd("silent! bd " .. test_case_buffer_id)
        vim.cmd("silent! bd! " .. utils.get_test_case_path(file_name))
        --utils.Debug(string.format("delete test_case_buffer: %d [%s]", test_case_buffer_id, file_name) )
        test_case_buffer_id = nil
    end

    if results_buffer_id then
        vim.api.nvim_buf_call(results_buffer_id, function()
            close_buffer_window(vim.api.nvim_get_current_win())
        end)
        vim.cmd("silent! bd " .. results_buffer_id)
        --utils.Debug(string.format("delete result_buffer: %d", results_buffer_id) )
        results_buffer_id = nil
    end

    if utils.is_in_folder(vim.api.nvim_buf_get_name(0), config.directory) then
        local buf_name = vim.api.nvim_buf_get_name(0)
        vim.cmd("silent! bd! " .. buf_name)
    end

end

return M

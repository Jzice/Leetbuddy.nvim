local utils = require("leetbuddy.utils")
local config = require("leetbuddy.config")
local qdata = require("leetbuddy.question")
local split = require("leetbuddy.split")

local M = {}
M.current_slug = vim.NIL
M.question_data = vim.NIL

function M.set_current_slug(slug)
    M.current_slug = slug
end

function M.get_current_slug()
    return M.current_slug
end

function M.reload_question()
    if not utils.is_in_folder(vim.api.nvim_buf_get_name(0), config.directory) then
        utils.Debug("current_buf not in leetcode base dir: ".. config.directory)
        return
    end
    local slug = utils.get_current_buf_slug_name()
    local question_data = qdata.fetch_question_data(slug)
    if question_data == vim.NIL then
        utils.Debug("question_data is nil, slug: ".. slug)
        return false
    end
    M.question_data = question_data
    M.load_question(M.current_slug)

    vim.api.nvim_command("LBSplit")
end

function M.load_question(slug_name)
    utils.Debug(string.format("start to load question: %s", slug_name))

    local question_id = tonumber(M.question_data["questionFrontendId"])
    local ext = config.language
    local title = M.question_data["title"]
    local content = M.question_data["content"]

    for _, table in ipairs(M.question_data["codeSnippets"]) do
        if table.langSlug == utils.langSlugToFileExt[ext] then
            local question_src_content = {
                question_id = question_id,
                slug = slug_name,
                lang = table.langSlug,
                difficulty = M.question_data['difficulty'],
                ac_rate = M.question_data['acRate'] * 100,
                test_case = M.question_data['sampleTestCase'],
                title = title,
                content = content,
                code = table.code,
            }
            local code_src = utils.encode_code_by_templ(question_src_content)
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

    local file_name = string.format("%04d-%s", question_id, slug_name)
    local test_case_path = utils.get_test_case_path(file_name)
    if utils.file_exists(test_case_path) then
        vim.api.nvim_command(":silent !touch " .. test_case_path)
    end
    local test_case_file = io.open(test_case_path, "w")
    if test_case_file then
        test_case_file:write(M.question_data["sampleTestCase"])
        test_case_file:close()
        utils.Debug("write to test_case_file: "..test_case_path)
    else
        utils.Debug("Failed to open test_case file: "..test_case_path)
    end

    local question_path = utils.get_question_path(file_name)
    if utils.file_exists(question_path) then
        vim.api.nvim_command(":silent !touch " .. question_path)
    end
    local question_file = io.open(question_path, "w")
    if question_file then
        utils.Debug("write to question_file: "..question_path)
        question_file:write(M.question_data["content"])
        question_file:close()
    else
        print("Failed to open question file.")
    end
    return true
end

function M.start_problem(slug)
    M.set_current_slug(slug)

    -- update question data
    M.question_data = qdata.fetch_question_data(slug)
    if M.question_data == vim.NIL then
        utils.Debug("question_data is nil, slug: ".. slug)
        return false
    end

    local question_id = M.question_data["questionFrontendId"]
    utils.Debug(string.format("start problem: %d.%s", question_id, slug))

    local question_file_name = string.format("%04d-%s", question_id, slug)
    local code_file_path = utils.get_code_file_path(question_file_name, config.language)
    if utils.file_exists(code_file_path) then
        utils.Debug(string.format("found code file: %s", code_file_path))
        vim.api.nvim_command("edit! " .. code_file_path)
    else
        utils.Debug(string.format("not found code file: %s", code_file_path))
        vim.api.nvim_command(":silent !touch " .. code_file_path)
        vim.api.nvim_command("edit! " .. code_file_path)

        local loaded = M.load_question(slug)
        if not loaded then
            print(string.format("question[%s] not loaded", slug))
            return
        end
    end

    -- display test_case window
    vim.api.nvim_command("LBSplit")

    -- display question content board
    vim.api.nvim_command("LBQuestion")
end

return M

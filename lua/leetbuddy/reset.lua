local log = require("leetbuddy.log")
local utils = require("leetbuddy.utils")
local config = require("leetbuddy.config")
local question_data = require("leetbuddy.question_data")

local M = {}

-- 重载问题数据
function M.reload_question()
    M.start_problem(utils.get_cur_buf_slug())
end

-- 加载问题
function M.load_question(slug)
    log.Debug(string.format("start to load question: %s", slug))

    local data = question_data.get_question_data(slug)

    local question_id = tonumber(data["questionFrontendId"])
    local ext = config.language
    local title = data["title"]
    local content = data["content"]

    local id_slug = utils.get_file_name_by_slug(question_id, slug)
    -- 根据id和slug生成文件名
    local code_file_name = utils.get_file_name_by_title(question_id, title)

    if utils.get_cur_buf_slug() ~= slug then
        -- 获取代码文件路径
        local code_file_path = utils.get_code_file_path(code_file_name, config.language)
        if utils.file_exists(code_file_path) then
            vim.api.nvim_command("edit! " .. code_file_path)
        else
            log.Debug(string.format("not found code file: %s", code_file_path))
            vim.api.nvim_command(":silent !touch " .. code_file_path)
            vim.api.nvim_command("edit! " .. code_file_path)
            for _, table in ipairs(data["codeSnippets"]) do
                if table.langSlug == utils.langSlugToFileExt[ext] then
                    local question_src_content = {
                        question_id = question_id,
                        slug = slug,
                        lang = table.langSlug,
                        difficulty = data['difficulty'],
                        ac_rate = data['acRate'] * 100,
                        test_case = data['sampleTestCase'],
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
        end
    end

    -- 保存测试用例数据到测试用例文件中
    local test_case_path = utils.get_test_case_path(id_slug)
    if not utils.file_exists(test_case_path) then
        vim.api.nvim_command(":silent !touch " .. test_case_path)
        local test_case_file = io.open(test_case_path, "w")
        if test_case_file then
            test_case_file:write(data["sampleTestCase"])
            test_case_file:close()
            log.Debug("write to test_case_file: "..test_case_path)
        else
            log.Debug("Failed to open test_case file: "..test_case_path)
        end
    end

    -- 保存问题描述到描述文件中
    local question_path = utils.get_question_path(id_slug)
    if not utils.file_exists(question_path) then
        vim.api.nvim_command(":silent !touch " .. question_path)
        local question_file = io.open(question_path, "w")
        if question_file then
            log.Debug("write to question_file: "..question_path)
            question_file:write(string.format("# %d.%s\n\n%s", 
                data["questionFrontendId"], data["title"],
                data["content"]))
            question_file:close()
        else
            print("Failed to open question file.")
        end
    end

    return true
end

-- 开始一个问题
function M.start_problem(slug)
    if slug == nil then
        print("question slug is nil!")
        return
    end

    -- 拉取问题数据
    local data = question_data.get_question_data(slug)
    if data == vim.NIL then
        log.Debug("question_data is nil, slug: ".. slug)
        return false
    end

    -- 加载源码文件
    local loaded = M.load_question(slug)
    if not loaded then
        print(string.format("question[%s] not loaded", slug))
        return
    end

    -- display split window
    vim.api.nvim_command("LBSplit")

    -- display question content panel 
    vim.api.nvim_command("LBQuestion")
end

return M

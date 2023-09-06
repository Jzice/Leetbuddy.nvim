local log = require("leetbuddy.log")
local utils = require("leetbuddy.utils")
local curl = require("plenary.curl")
local config = require("leetbuddy.config")
local headers = require("leetbuddy.headers")

M = {}
M.pre_slug = vim.NIL
M.question_data = vim.NIL

function M.get_question_data(slug)
  if slug ~= M.pre_slug or M.question_data == vim.NIL then
    M.fetch_question_data(slug)
  end
  return M.question_data
end

function M.get_question_id(slug)
  if slug ~= M.pre_slug or M.question_data == vim.NIL then
    M.fetch_question_data(slug)
  end
  return M.question_data["questionId"]
end

function M.get_question_content(slug)
    if slug ~= M.pre_slug or M.question_data == vim.NIL then
        M.fetch_question_data(slug)
    end
    return M.question_data["content"]
end

function M.fetch_question_data(slug)
    vim.cmd("silent !LBCheckCookies")

    local variables = {
        titleSlug = slug,
    }
    local query = config.domain == "cn" and [[
    query questionData($titleSlug: String!) {
        question(titleSlug: $titleSlug) {
            questionId
            questionFrontendId
            difficulty
            sampleTestCase
            acRate
            title: translatedTitle
            content: translatedContent
            codeSnippets {
                lang
                langSlug
                code
            }
        }
    }
    ]] or [[
    query questionData($titleSlug: String!) {
        question(titleSlug: $titleSlug) {
            questionId
            questionFrontendId
            difficulty
            sampleTestCase
            acRate
            title
            content
            codeSnippets {
                lang
                langSlug
                code
            }
        }
    }
    ]]

    local response = curl.post(
        config.graphql_endpoint,
        { headers = headers, body = vim.json.encode({ query = query, variables = variables }) }
    )
    local ok, data = pcall(vim.json.decode, response["body"])
    if not ok then
        log.Debug("cookies decode error: " .. response)
        return
    end
    local question_data = data["data"]["question"]
    if question_data["content"] == vim.NIL then
        print(string.format("question[%s] is paidOnly", slug))
        log.Debug("fetch question data error, slug: ".. slug)
        return vim.NIL
    end
    question_data["content"] = utils.tr_html_to_txt(question_data["content"])

    M.question_data = question_data
    M.question_id = question_data["questionId"]

    return M.question_data
end

return M

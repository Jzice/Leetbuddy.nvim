local curl = require("plenary.curl")
local config = require("leetbuddy.config")
local headers = require("leetbuddy.headers")
local utils = require("leetbuddy.utils")
local split = require("leetbuddy.split")
local question = require("leetbuddy.question")

local M = {}

local function show_random_problem(slug)
    local problem = question.fetch_question_data(slug)
    split.start_problem(problem["questionFrontendId"], slug)
end

function M.getRandomQuestion()
    vim.cmd("silent !LBCheckCookies")

    local variables = {
        categorySlug = "",
        filters = nil,
    }
    local query = config.domain == "cn" and [[
        query problemsetRandomFilteredQuestion(
            $categorySlug: String!,
            $filters: QuestionListFilterInput
        ) {
            problemsetRandomFilteredQuestion(
                categorySlug: $categorySlug,
                filters: $filters
            )
        }
    ]] or [[
        query problemsetRandomFilteredQuestion(
            $categorySlug: String!,
            $filters: QuestionListFilterInput
        ) {
            problemsetRandomFilteredQuestion(
                categorySlug: $categorySlug,
                filters: $filters
            )
        }
    ]]
	local response = curl.post(
        config.graphql_endpoint,
        {
            headers = headers,
            body = vim.json.encode({
                operationName = "problemsetRandomFilteredQuestion",
                query = query,
                variables = variables
            })
        }
    )
	local resp_json = vim.json.decode(response["body"])
    if resp_json == nil or resp_json["data"] == nil then
        if config.debug then
            print("Response from " .. config.graphql_endpoint)
            utils.P(response)
        end
        return
    end

    show_random_problem(resp_json["data"]["problemsetRandomFilteredQuestion"])
end

return M

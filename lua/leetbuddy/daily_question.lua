local curl = require("plenary.curl")
local config = require("leetbuddy.config")
local headers = require("leetbuddy.headers")
local utils = require("leetbuddy.utils")
local split = require("leetbuddy.split")

local M = {}

local function show_daily_problem(problem)
    split.start_problem(problem["frontendQuestionId"], problem["titleSlug"])
end

function M.getDailyQuestion()
    local query = config.domain == "cn" and [[
        query questionOfToday {
          todayRecord {
            date
            userStatus
            question {
              questionId
              frontendQuestionId: questionFrontendId
              difficulty
              title
              titleCn: translatedTitle
              titleSlug
              paidOnly: isPaidOnly
              freqBar
              isFavor
              acRate
              status
              solutionNum
              hasVideoSolution
              topicTags {
                name
                nameTranslated: translatedName
                id
              }
              extra {
                topCompanyTags {
                  imgUrl
                  slug
                  numSubscribed
                }
              }
            }
            lastSubmission {
              id
            }
          }
        }
    ]] or [[
    query questionOfToday {
        activeDailyCodingChallengeQuestion: todayRecord {
            question {
                frontendQuestionId: questionFrontendId
                titleSlug
            }
        }
    }
    ]]
	local response = curl.post(config.graphql_endpoint, {
		headers = headers,
		body = vim.json.encode({ operationName = "questionOfToday", query = query, variables = {} }),
	})
	local todayRecord = vim.json.decode(response["body"])["data"]["todayRecord"]
	if todayRecord ~= vim.NIL and todayRecord[1] ~= vim.NIL then
		if todayRecord[1]["question"] ~= vim.NIL then
			show_daily_problem(todayRecord[1]["question"])
		end
	end
end

return M

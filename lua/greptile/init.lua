-- TODO: require telescope and plenary

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")

local log = require("plenary.log")
log.level = "debug"

local curl = require("plenary.curl")
local json = require("plenary.json")

local search_repo = function(prompt)
	local response_body = {}

	local url = "https://api.greptile.com/v2/search"
	-- local method = "POST"
	local headers = {
		["Authorization"] = "Bearer" .. os.getenv("GREPTILE_API_KEY"),
		["Content-Type"] = "application/json",
		["X-Github-Token"] = os.getenv("GITHUB_TOKEN"),
	}

	local body = {
		["query"] = prompt,
		["repositories"] = {
			["remote"] = "github",
			["branch"] = "main",
			["repository"] = "rajitkhanna/greptile.nvim",
		},
	}

	local response = curl.post(url, {
		body = vim.fn.json_encode(body),
		headers = headers,
	})

	if response.status ~= 200 then
		error("API request failed with status code: " .. response.status)
	end

	return json.decode(table.concat(response_body))
end

local semantic_search = function(opts)
	pickers
		.new(opts, {
			prompt_title = "Semantic Search",
			finder = finders.new_table({
				results = search_repo("give me the file that extends telescope"),
				log.debug(results),
			}),
		})
		:find()
end

semantic_search()

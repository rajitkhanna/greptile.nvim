local pickers = require("telescope.pickers")
local finders = require("telescope.finders")

local log = require("plenary.log")
log.level = "debug"

local search_repo = function(prompt)
	local http = require("socket.http")
	local json = require("json")
	local ltn12 = require("ltn12")

	local response_body = {}

	local url = "https://api.greptile.com/v2/search"
	local method = "POST"
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

	local _, code, _ = http.request({
		url = url,
		method = method,
		headers = headers,
		source = ltn12.source.string(body),
		sink = ltn12.sink.table(response_body),
	})

	log.debug(response_body)

	if code ~= 200 then
		error("API request failed with status code: " .. code)
	end

	return json.decode(table.concat(response_body))
end

local semantic_search = function(opts)
	pickers
		.new(opts, {
			prompt_title = "Semantic Search",
			finder = finders.new_table({
				results = search_repo("give me the file that extends telescope"),
			}),
		})
		:find()
end

semantic_search()

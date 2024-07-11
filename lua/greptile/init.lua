local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
	error("This extension requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local has_plenary, plenary = pcall(require, "plenary")
if not has_plenary then
	error("This extension requires plenary.nvim (https://github.com/nvim-lua/plenary.nvim)")
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")

local log = require("plenary.log")
log.level = "debug"

local curl = require("plenary.curl")
local success_json, json = pcall(require, "plenary.json")

if not success_json then
	error("Failed to load plenary.json")
end

local greptile_api_key = os.getenv("GREPTILE_API_KEY")
local github_token = os.getenv("GITHUB_TOKEN")

local function write_to_log(file_path, content)
	local file = io.open(file_path, "a")
	if file then
		file:write(content .. "\n")
		file:close()
	else
		error("Could not open file for writing: " .. file_path)
	end
end

local function log_response(response)
	write_to_log("logfile.log", "Response Status: " .. (response.status or "nil"))
	write_to_log("logfile.log", "Response Body: " .. (response.body or "nil"))
	write_to_log("logfile.log", "Response Headers: " .. vim.inspect(response.headers or {}))
	write_to_log("logfile.log", "Response Exit: " .. (response.exit or "nil"))
	write_to_log("logfile.log", "Response Exit Signal: " .. (response.exit_signal or "nil"))
end

local search_repo = function(prompt)
	local url = "https://api.greptile.com/v2/search"
	local headers = {
		["Authorization"] = "Bearer " .. greptile_api_key,
		["Content-Type"] = "application/json",
		["X-Github-Token"] = github_token,
	}

	local body = {
		["query"] = prompt,
		["repositories"] = {
			{
				["remote"] = "github",
				["branch"] = "main",
				["repository"] = "rajitkhanna/greptile.nvim",
			},
		},
	}

	local response = curl.post(url, {
		body = vim.json.encode(body),
		headers = headers,
	})

	log_response(response)

	if response.status ~= 200 then
		error("API request failed with status code: " .. response.status)
	end

	return vim.json.decode(response.body)
end

local semantic_search = function(opts)
	local results = search_repo("where do I register this plugin as an extension of telescope")
	-- log.debug(results)

	pickers
		.new(opts, {
			prompt_title = "Semantic Search",
			finder = finders.new_table({
				results = results,
				entry_maker = function(entry)
					log.debug(entry)
					return {
						value = entry.filepath,
						display = entry.filepath,
						ordinal = entry.filepath,
					}
				end,
			}),
			sorter = require("telescope.config").values.generic_sorter(opts),
			previewer = require("telescope.previewers").new_termopen_previewer({
				get_command = function(entry)
					return { "bat", "--style=header,grid", entry.value }
				end,
			}),
			attach_mappings = function(prompt_bufnr, map)
				require("telescope.actions").select_default:replace(function()
					local selection = require("telescope.actions.state").get_selected_entry()
					require("telescope.actions").close(prompt_bufnr)
					vim.cmd("edit " .. selection.value.path)
				end)
				return true
			end,
		})
		:find()
end

semantic_search()

-- vim.print(search_repo("where do I register this plugin as an extension of telescope"))

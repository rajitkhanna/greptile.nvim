local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
	error("This extension requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local has_plenary, plenary = pcall(require, "plenary")
if not has_plenary then
	error("This extension requires plenary.nvim (https://github.com/nvim-lua/plenary.nvim)")
end

local utils = require("telescope.utils")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local builtin = require("telescope.builtin")

local curl = require("plenary.curl")

local greptile_api_key = os.getenv("GREPTILE_API_KEY")
local github_token = os.getenv("GITHUB_TOKEN")

local PROCESSING_STATUS = {
	NOT_STARTED = 1,
	IN_PROGRESS = 2,
	COMPLETED = 3,
}

local M = {}

local function get_git_info()
	local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD"):gsub("\n", "")
	local repo_url = vim.fn.system("git config --get remote.origin.url"):gsub("\n", "")
	repo_url = repo_url:gsub("%.git$", "") -- Remove the .git suffix if it exists
	local repo_name = repo_url:match("github.com[:/]([%w%-%.]+/[%w%-%.]+)")
	return branch, repo_name
end

local char_to_hex = function(c)
	return string.format("%%%02X", string.byte(c))
end

local function urlencode(url)
	if url == nil then
		return
	end
	url = url:gsub("\n", "\r\n")
	url = url:gsub("([^%w ])", char_to_hex)
	url = url:gsub(" ", "+")
	return url
end

local indexed = function()
	local branch, repo_name = get_git_info()
	local repository_id = "github:" .. branch .. ":" .. repo_name

	local url = "https://api.greptile.com/v2/repositories/" .. urlencode(repository_id)
	local headers = {
		["Authorization"] = "Bearer " .. greptile_api_key,
	}

	local response = curl.get(url, {
		headers = headers,
	})

	if response.status ~= 200 then
		return PROCESSING_STATUS.NOT_STARTED
	elseif vim.json.decode(response.body).status == "completed" then
		return PROCESSING_STATUS.COMPLETED
	else
		return PROCESSING_STATUS.IN_PROGRESS
	end
end

local search_repo = function(prompt)
	local branch, repo_name = get_git_info()

	local status = indexed()
	if status == PROCESSING_STATUS.NOT_STARTED then
		local url = "https://api.greptile.com/v2/repositories"

		local headers = {
			["Authorization"] = "Bearer " .. greptile_api_key,
			["Content-Type"] = "application/json",
			["X-Github-Token"] = github_token,
		}
		local body = {
			["remote"] = "github",
			["branch"] = branch,
			["repository"] = repo_name,
		}

		local response = curl.post(url, {
			body = vim.json.encode(body),
			headers = headers,
		})

		if response.status ~= 200 then
			error(
				"API request failed with status code: "
					.. response.status
					.. "\n"
					.. vim.json.decode(response.body).response
			)
		end
	elseif status == PROCESSING_STATUS.IN_PROGRESS then
		return { "Loading..." }
	else
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
					["branch"] = branch,
					["repository"] = repo_name,
				},
			},
		}

		local response = curl.post(url, {
			body = vim.json.encode(body),
			headers = headers,
			timeout = 10000,
		})

		if response.status ~= 200 then
			error("API request failed with status code: " .. response.status)
		end

		return vim.json.decode(response.body)
	end
end

M.semantic_search = function(opts)
	opts = opts or {}
	local cwd = vim.fn.getcwd()

	local function refresh_picker_with_results(prompt_bufnr)
		local prompt = action_state.get_current_line() .. ". Only return files (not directories)."
		local results = search_repo(prompt)
		local current_picker = action_state.get_current_picker(prompt_bufnr)

		current_picker:refresh(
			finders.new_table({
				results = results,
				entry_maker = function(entry)
					if entry.filepath == nil then
						return {
							value = "Loading...",
							display = "Loading...",
							ordinal = prompt,
						}
					else
						return {
							value = cwd .. "/" .. entry.filepath,
							display = utils.get_devicons(entry.filepath)
								.. " "
								.. utils.transform_path(opts, entry.filepath),
							ordinal = prompt,
							filepath = entry.filepath,
						}
					end
				end,
			}),
			{ reset_prompt = false }
		)
	end

	local function open_selected_file(prompt_bufnr)
		local selection = action_state.get_selected_entry()
		if selection and selection.value then
			actions.close(prompt_bufnr)
			vim.cmd("edit " .. selection.value)
		else
			print("No selection or selection value available")
		end
	end

	builtin.find_files({
		prompt_title = "Semantic Search",
		attach_mappings = function(prompt_bufnr, map)
			map("i", "<CR>", function()
				refresh_picker_with_results(prompt_bufnr)
			end)
			map("i", "<C-o>", function()
				open_selected_file(prompt_bufnr)
			end)
			map("n", "<CR>", function()
				refresh_picker_with_results(prompt_bufnr)
			end)
			map("n", "<C-o>", function()
				open_selected_file(prompt_bufnr)
			end)
			return true
		end,
	})
end

return M

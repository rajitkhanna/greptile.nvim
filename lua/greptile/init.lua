local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
	error("This extension requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local has_plenary, plenary = pcall(require, "plenary")
if not has_plenary then
	error("This extension requires plenary.nvim (https://github.com/nvim-lua/plenary.nvim)")
end

local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local builtin = require("telescope.builtin")

local curl = require("plenary.curl")

local greptile_api_key = os.getenv("GREPTILE_API_KEY")
local github_token = os.getenv("GITHUB_TOKEN")

local function get_git_info()
	local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD"):gsub("\n", "")
	local repo_url = vim.fn.system("git config --get remote.origin.url"):gsub("\n", "")
	local repo_name = repo_url:match("github.com[:/]([%w%-%.]+/[%w%-%.]+)")
	return branch, repo_name
end

local function get_file_icon(filename)
	local ok, devicons = pcall(require, "nvim-web-devicons")
	if not ok then
		return ""
	end
	local icon, _ = devicons.get_icon(filename, string.match(filename, "%a+$"), { default = true })
	return icon and (icon .. " ") or ""
end

local search_repo = function(prompt)
	local branch, repo_name = get_git_info()

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
	})

	if response.status ~= 200 then
		error("API request failed with status code: " .. response.status)
	end

	return vim.json.decode(response.body)
end

local semantic_search_picker = function(opts)
	opts = opts or {}
	local cwd = vim.fn.getcwd()

	local function refresh_picker_with_results(prompt_bufnr)
		local prompt = action_state.get_current_line() .. ". Exclude any directories."
		local results = search_repo(prompt)
		local current_picker = action_state.get_current_picker(prompt_bufnr)

		current_picker:refresh(
			finders.new_table({
				results = results,
				entry_maker = function(entry)
					return {
						value = cwd .. "/" .. entry.filepath,
						display = get_file_icon(entry.filepath) .. entry.filepath:gsub("^/", ""),
						ordinal = prompt,
					}
				end,
			}),
			{ reset_prompt = false }
		)
	end

	local function open_selected_file(prompt_bufnr)
		local selection = action_state.get_selected_entry()
		if selection and selection.value then
			local filepath = cwd .. "/" .. selection.value
			actions.close(prompt_bufnr)
			vim.cmd("edit " .. filepath)
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
			map("i", "<C-e>", function()
				open_selected_file(prompt_bufnr)
			end)
			map("n", "<CR>", function()
				refresh_picker_with_results(prompt_bufnr)
			end)
			map("n", "<C-e>", function()
				open_selected_file(prompt_bufnr)
			end)
			return true
		end,
	})
end

semantic_search_picker()

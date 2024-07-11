local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local config = require("telescope.config").values
local previewers = require("telescope.previewers")

local log = require("plenary.log")
log.level = "debug"

local M = {}

-- Function to execute a shell command and capture the output
function os.capture(cmd)
	local f = assert(io.popen(cmd, "r"))
	local s = assert(f:read("*a"))
	f:close()
	return s
end

-- Capture the current Git branch
local current_branch = os.capture("git branch --show-current"):gsub("%s+", "")
local remote_url = os.capture("git remote get-url origin"):gsub("%s+", "")
log.debug("Current branch: " .. current_branch)
log.debug("Remote url: " .. remote_url)

M.semantic_search = function(opts)
	pickers
		.new(opts, {
			finder = finders.new_table({

				results = {
					{ name = "Yes", value = { 1, 2, 3, 44 } },
					{ name = "No", value = { 1, 2, 3, 45 } },
					{ name = "Maybe", value = { 1, 2, 3, 46 } },
					{ name = "So", value = { 1, 2, 3, 47 } },
				},

				entry_maker = function(entry)
					return {
						value = entry.value,
						display = entry.name,
						ordinal = entry.name,
					}
				end,
			}),
			sorter = config.generic_sorter(opts),

			previewer = previewers.new_buffer_previewer({
				title = "Preview",
				define_preview = function(self, entry)
					vim.api.nvim_buf_set_lines(
						self.state.bufnr,
						0,
						0,
						false,
						vim.tbl_flatten({ "Hello", "Everyone", vim.inspect(entry.value) })
					)
				end,
			}),
		})
		:find()
end

M.semantic_search()

return M

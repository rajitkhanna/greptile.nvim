local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local config = require("telescope.config").values

local is_indexed = function ()

end

local search_repo = function (prompt)
   
end

local semantic_search = function (opts)
  pickers.new(opts, {
    prompt_title: 'Semantic Search',
    finder = finders.
  })
  
end

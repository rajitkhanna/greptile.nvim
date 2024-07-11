local greptile = require("greptile")

return require("telescope").register_extension({
	exports = {
		semantic_search = greptile.semantic_search,
	},
})

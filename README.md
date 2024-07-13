# greptile.nvim
💥 Semantic search for Neovim

```
return {
  "rajitkhanna/greptile.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local keymap = vim.keymap

    keymap.set("n", "<leader>ss", "<cmd>GreptileSearch<cr>", { desc = "Semantic search files" })
  end,
}
```

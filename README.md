# 💥 Semantic Search
**greptile.nvim** is a lua plugin for Neovim >= 0.8.0 to search for files in natural language. 

[image.png](https://github.com/user-attachments/assets/1a568885-b455-4ac6-9490-25347390b8c3)

## ✨ Features
- Search for any file or set of files is natural language with the [Greptile API](https://docs.greptile.com/introduction)
- Jump directly into the file
- [wip] Navigate directly to the line that's relevant to your query
- [wip] Chat with multiple codebases at once

## ⚡️ Requirements

- Neovim >= 0.8.0 (use the `neovim-pre-0.8.0` branch for older versions)
- optional:
  + [ripgrep](https://github.com/BurntSushi/ripgrep) and [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) are used for searching.
  + [Telescope](https://github.com/nvim-telescope/telescope.nvim)
 
This plugin also assumes `GREPTILE_API_KEY` and `GITHUB_TOKEN` are environment variables. Please see the [Greptile Docs](https://docs.greptile.com/introduction) for more information.

After creating these keys, you can add them to your environment in the following way:

```bash
export GREPTILE_API_KEY=XXX
export GITHUB_TOKEN=XXX
```

## 📦 Installation

Install the plugin with your preferred package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
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


## 🚀 Usage

**Semantic Search** queries the repo using your query:

```vim
:GreptileSearch
```

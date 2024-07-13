# 💥 Semantic Search
**greptile.nvim** is a lua plugin for Neovim >= 0.8.0 to search for files in natural language. 

## ✨ Features
- Search for any file or set of files is natural language with the [Greptile API](https://api.greptile.com) 
- Jump directly into the file

## ⚡️ Requirements

```
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
# ✅ Todo Comments

**todo-comments** is a lua plugin for Neovim >= 0.8.0 to highlight and search for todo comments like
`TODO`, `HACK`, `BUG` in your code base.

![image](https://user-images.githubusercontent.com/292349/118135272-ad21e980-b3b7-11eb-881c-e45a4a3d6192.png)

## ✨ Features

- **highlight** your todo comments in different styles
- optionally only highlights todos in comments using **TreeSitter**
- configurable **signs**
- open todos in a **quickfix** list
- open todos in [Trouble](https://github.com/folke/trouble.nvim)
- search todos with [Telescope](https://github.com/nvim-telescope/telescope.nvim)

## ⚡️ Requirements

- Neovim >= 0.8.0 (use the `neovim-pre-0.8.0` branch for older versions)
- a [patched font](https://www.nerdfonts.com/) for the icons, or change them to simple ASCII characters
- optional:
  + [ripgrep](https://github.com/BurntSushi/ripgrep) and [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) are used for searching.
  + [Trouble](https://github.com/folke/trouble.nvim)
  + [Telescope](https://github.com/nvim-telescope/telescope.nvim)


## 🚀 Usage

**Todo** matches on any text that starts with one of your defined keywords (or alt) followed by a colon:

- TODO: do something
- FIX: this should be fixed
- HACK: weird code warning

Todos are highlighted in all regular files.

Each of the commands below accept the following arguments:

- `cwd` - Specify the directory to search for comments, like:

```vim
:TodoTelescope cwd=~/projects/foobar
```

- `keywords` - Comma separated list of keywords to filter results by. Keywords are case-sensitive.

```vim
:TodoTelescope keywords=TODO,FIX
```

### 🔎 `:TodoQuickFix`

This uses the quickfix list to show all todos in your project.

![image](https://user-images.githubusercontent.com/292349/118135332-bf9c2300-b3b7-11eb-9a40-1307feb27c44.png)

### 🔎 `:TodoLocList`

This uses the location list to show all todos in your project.

![image](https://user-images.githubusercontent.com/292349/118135332-bf9c2300-b3b7-11eb-9a40-1307feb27c44.png)

### 🚦 `:Trouble todo`

List all project todos in [trouble](https://github.com/folke/trouble.nvim)

Use Trouble's filtering: `Trouble todo filter = {tag = {TODO,FIX,FIXME}}`

> See screenshot at the top

### 🔭 `:TodoTelescope`

Search through all project todos with Telescope

![image](https://user-images.githubusercontent.com/292349/118135371-ccb91200-b3b7-11eb-9002-66af3b683cf0.png)

<!-- markdownlint-disable-file MD033 -->
<!-- markdownlint-configure-file { "MD013": { "line_length": 120 } } -->
<!-- markdownlint-configure-file { "MD004": { "style": "sublist" } } -->

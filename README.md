<p align="center">
  <img src="https://github.com/ingur/captain.nvim/assets/45173070/f32d3dd6-7080-4799-b45c-830ca16107fd"/>
</p>

<h1 align="center">captain.nvim</h1>

<p align="center">
  A tiny plugin that allows for quick switching between files on a per-project basis, with support for Git branch-specific directories, inspired by <a href="https://github.com/ThePrimeagen/harpoon">Harpoon</a>
</p>

## Installation

Install with your favorite package manager. For example, in lazy.nvim:
```lua
{ "ingur/captain.nvim" }
```

## Setup

Below shows an example config:
```lua
local captain = require('captain')

captain.setup({        -- Default settings:
    autowrite = true,  -- Automatically save hooks on exit
    silent = false,    -- Disable notifications
    git = true,        -- Enable Git branch awareness
})

-- Hook files to specific indices or keys
vim.keymap.set('n', '<leader>1', function() captain.hook(1) end)
vim.keymap.set('n', '<leader>2', function() captain.hook(2) end)
vim.keymap.set('n', '<leader>3', function() captain.hook(3) end)

-- Show hooks information
vim.keymap.set('n', '<leader>hh', function() captain.info() end)

-- Unhook the current file or all files
vim.keymap.set('n', '<leader>hd', function() captain.unhook() end)
vim.keymap.set('n', '<leader>hD', function() captain.unhook({ all = true }) end)

-- Save hooks manually
vim.keymap.set('n', '<leader>hs', function() captain.save() end)

-- Reset all hooks
vim.keymap.set('n', '<leader>hr', function() captain.reset() end)
```


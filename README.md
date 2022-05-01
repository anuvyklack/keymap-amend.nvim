# Neovim keymap amend

> :warning: **WARNING**: Neovim v0.7 or higher is required

> :warning: **WARNING**: This plugin is in beta and a lot of rough edges are
> expected. You are welcome to open issues.

This plugin delivers a function that allows to amend the exisintg keybinding.
Its signature is equal to **vim.keymap.set** function (`:help vim.keymap.set()`)
with one exception: the `rhs` parameter should be function that receives one
parameter --- a function on call of which the original keymapping will be
executed. This function is constructed and passed automaticaly.  You only need
to 'accept' it in your `rhs` function and call on need.

```lua
local keymap = vim.keymap
keymap.amend = require('keymap-amend')

keymap.amend(mode, lhs, function(original)
    -- your custom logic
    original() -- execute the original 'lhs' mapping
end, opts)
```

You need to watch that the amendment happens after the original keymap is set.

## Examples

```lua
keymap.amend('n', 'k', function(original)
   print('k key is amended!')
   original()
end)
```

```lua
keymap.amend('n', '<Esc>', function(original)
   if vim.v.hlsearch and vim.v.hlsearch == 1 then
      vim.cmd('nohlsearch')
   end
   original()
end)
```

## Acknowledgments

This plugin was inspired with [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
fallback mechanics.

## A tip

The following custom `keymap` table I find useful:

```lua
local util = {}
util.keymap = {}

---Wrapper around vim.keymap.set() function. It accepts in the {opts} parameter
---table an additional option:
--- - requires: (string) A module name. If this module is not available the keymap
---   won't be set.
---Example:
---    keymap.set('n', '<leader>la', function()
---        require('lspsaga.codeaction').code_action()
---    end, { requires = 'lspsaga' })
util.keymap.set = function (...)
   local decision = true -- The decision to set keymap or not.
   local opts = select(-1, ...)
   if type(opts) == 'table' and opts.requires then
      decision, _ = pcall(require, opts.requires)
      opts.requires = nil
   end
   if decision then vim.keymap.set(...) end
end

util.keymap.amend = require('keymap-amend')
```

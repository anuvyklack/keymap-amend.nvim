# keymap-amend.nvim

> :warning: **WARNING**: This plugin is in beta and a lot of rough edges are expected.
> You are welcome to open issues.

**Neovim v0.7 or higher is required**

This plugin allows to amend the exisintg keybinding in Neovim. It is done with the
function which is required from the `keymap-amend` module.  The signature of this function
is equal to **vim.keymap.set** function (`:help vim.keymap.set()`) with one exception: the
`rhs` parameter should be a function that receives one parameter — a function on call of
which the original keymapping will be executed. This function is constructed and passed
automaticaly.  You only need to "accept" it in your `rhs` function and call on need.

```lua
local keymap = vim.keymap
keymap.amend = require('keymap-amend')

keymap.amend(mode, lhs, function(original)
    -- your custom logic
    original() -- execute the original 'lhs' mapping
end, opts)
```

You need to watch that the amendment happens after the original keymap is set.

## Instalation

With [packer](https://github.com/wbthomason/packer.nvim):

```lua
use 'anuvyklack/keymap-amend.nvim'
```

## Examples

```lua
local keymap = vim.keymap
keymap.amend = require('keymap-amend')

keymap.amend('n', 'k', function(original)
   print('k key is amended!')
   original()
end)
```

Make `<Esc>` disable highlighting of recently searched text in addition to its
original functionality:

```lua
local keymap = vim.keymap
keymap.amend = require('keymap-amend')

keymap.amend('n', '<Esc>', function(original)
   if vim.v.hlsearch and vim.v.hlsearch == 1 then
      vim.cmd('nohlsearch')
   end
   original()
end, { desc = 'disable search highlight' })
```

## Acknowledgments

This plugin was inspired with [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
fallback mechanics.


<!-- vim: set tw=90: -->

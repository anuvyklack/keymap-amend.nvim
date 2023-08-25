# keymap-amend.nvim

**Neovim v0.7 or higher is required**

This plugin allows to amend the exisintg keybinding in Neovim. It is done with the
function which is required from the `keymap-amend` module. The signature of this function
is equal to **vim.keymap.set** function (`:help vim.keymap.set()`) with one exception: the
`rhs` parameter should be a function that receives one parameter — a function on call of
which the original keymapping will be executed. This function is constructed and passed
automaticaly. You only need to "accept" it in your `rhs` function and call on need.

```lua
local keymap = vim.keymap
keymap.amend = require('keymap-amend')

keymap.amend(mode, lhs, function(original)
    -- your custom logic
    original() -- execute the original 'lhs' mapping
end, opts)
```

You need to watch that the amendment happens after the original keymap is set.

We also provide a helper function for getting the original keymap and a function that
executes the original 'lhs' mapping for use with other methods of creating keymaps

```lua
vim.keymap.get = require('keymap-amend').get
local original = vim.keymap.get(mode, lhs):original()
```

This is equivalent to the `original` parameter in keymap.amend
the get() function also returns other information about the keymapping:
It contains all the field from nvim_get_keymap,
as well as a buffer parameter that is false for global keymaps,
as well as the `original` method to get a callable

## Installation

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

### yank-ring with multiple-cursors

Make [yanky.nvim](https://github.com/gbprod/yanky.nvim) and
[vim-visual-multi](https://github.com/mg979/vim-visual-multi) plugins share `<C-n>`
key-chord. `vim-visual-multi` should be loaded before `yanky.nvim`. In this example
[packer.nvim](https://github.com/wbthomason/packer.nvim) plugin manager is used to achive this.

```lua
use 'mg979/vim-visual-multi'
use { 'gbprod/yanky.nvim',
   after = 'vim-visual-multi',
   config = function() require('yanky').setup() end
}

keymap.amend('n', '<C-p>', function(original)
   if yanky.can_cycle() then
      yanky.cycle(-1)
   else
      original()
   end
end)

keymap.amend('n', '<C-n>', function(original)
   if yanky.can_cycle() then
      yanky.cycle(1)
   else
      original()
   end
end, { desc = 'yank-ring + multiple-cursors' })
```

Now `<C-n>` will cycle the yank-ring only after paste, in all other cases it will activate
multiple cursors.

## Acknowledgments

This plugin was inspired with [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
fallback mechanics.

<!-- vim: set tw=90: -->

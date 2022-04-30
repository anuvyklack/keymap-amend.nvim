local keymap = {}

---Shortcut for `nvim_replace_termcodes`.
---@param keys string
---@return string
local function termcodes(keys)
   return vim.api.nvim_replace_termcodes(keys, true, true, true)
end

---Returns if two key sequence are equal or not.
---@param a string
---@param b string
---@return boolean
local function keymap_equals(a, b)
   return termcodes(a) == termcodes(b)
end

---Get map
---@param mode string
---@param lhs string
---@return table
keymap.get_map = function(mode, lhs)
   for _, map in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
      if keymap_equals(map.lhs, lhs) then
         return {
            lhs = map.lhs,
            rhs = map.rhs or '',
            expr = map.expr == 1,
            callback = map.callback,
            noremap = map.noremap == 1,
            script = map.script == 1,
            silent = map.silent == 1,
            nowait = map.nowait == 1,
            buffer = true,
         }
      end
   end

   for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
      if keymap_equals(map.lhs, lhs) then
         return {
            lhs = map.lhs,
            rhs = map.rhs or '',
            expr = map.expr == 1,
            callback = map.callback,
            noremap = map.noremap == 1,
            script = map.script == 1,
            silent = map.silent == 1,
            nowait = map.nowait == 1,
            buffer = false,
         }
      end
   end

   return {
      lhs = lhs,
      rhs = lhs,
      expr = false,
      callback = nil,
      noremap = true,
      script = false,
      silent = true,
      nowait = false,
      buffer = false,
   }
end

---Returns the function constructed from the passed keymap object on call of
---which the original keymapping will be executed.
---@param mode string mode short name
---@param map table keymap object
---@return function
keymap.original = function(mode, map)
   local lhs = string.format('<Plug>(keymap-amend.fallback:%s)', map.lhs)

   if map.buffer then
      local bufnr = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, map.rhs, {
         expr = map.expr,
         callback = map.callback,
         noremap = map.noremap,
         script = map.script,
         silent = map.silent,
         nowait = map.nowait
      })
   else
      vim.api.nvim_set_keymap(mode, lhs, map.rhs, {
         expr = map.expr,
         callback = map.callback,
         noremap = map.noremap,
         script = map.script,
         silent = map.silent,
         nowait = map.nowait
      })
   end

   local feedkeys_mode = map.noremap and 'in' or 'im'

   return function()
      vim.api.nvim_feedkeys(termcodes(lhs), feedkeys_mode, true)
   end
end

-- keymap.original = function(_, map)
--    return function()
--       local f = {} -- keys for feeding
--       if map.expr then
--          if map.callback then
--             f.keys = map.callback()
--          else
--             f.keys = vim.api.nvim_eval(map.rhs)
--          end
--          f.keys = termcodes(f.keys)
--          f.mode = map.noremap and 'in' or 'im'
--       elseif map.callback then
--          map.callback()
--          return
--       else
--          f.keys = map.rhs
--       end
--       f.keys = termcodes(f.keys)
--       f.mode = map.noremap and 'in' or 'im'
--       vim.api.nvim_feedkeys(f.keys, f.mode, true)
--    end
-- end

local function amend(mode, lhs, rhs, opts)
   local map = keymap.get_map(mode, lhs)
   local original = keymap.original(mode, map)
   vim.keymap.set(mode, lhs, function() rhs(original) end, opts)
end

keymap.amend = function(mode, ...)
   if type(mode) == 'table' then
      for _, m in ipairs(mode) do
         amend(m, ...)
      end
   else
      amend(mode, ...)
   end
end

return keymap

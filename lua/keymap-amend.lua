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
local function get_map(mode, lhs)
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
---@return function the function on call of which the original mapping will be executed
---@return string? desc the `dssc` field of the original mapping
local function get_original(mode, map)
   local lhs = string.format('<Plug>(keymap-amend.original:%s)', map.lhs)

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

   if map.desc:find('[keymap-amend.nvim', 1, true) then
      error('[keymap-amend.nvim] Trying to amend already amended keymap')
   end

   local feedkeys_mode = 'i'

   local function fun()
      if mode == 'n' then
         vim.api.nvim_feedkeys(vim.v.count1..termcodes(lhs), feedkeys_mode, false)
      else
         vim.api.nvim_feedkeys(termcodes(lhs), feedkeys_mode, false)
      end
   end

   return fun, map.desc
end

-- local function get_original(_, map)
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

---@param mode string
---@param lhs string
---@param rhs string | function
---@param opts table
local function single_mode_amend(mode, lhs, rhs, opts)
   local map = get_map(mode, lhs)
   local original, orig_desc = get_original(mode, map)
   opts = opts or {}
   opts.desc = table.concat{
      '[keymap-amend.nvim', (opts.desc and ': '..opts.desc or ''), '] ',
      orig_desc or ''
   }
   vim.keymap.set(mode, lhs, function() rhs(original) end, opts)
end

---Amend the existing keymap.
---@param mode string | string[]
---@param lhs string
---@param rhs string | function
---@param opts table
local function amend(mode, lhs, rhs, opts)
   if type(mode) == 'table' then
      for _, m in ipairs(mode) do
         single_mode_amend(m, lhs, rhs, opts)
      end
   else
      single_mode_amend(mode, lhs, rhs, opts)
   end
end

return amend

list = {}
list.__index = list

setmetatable(list, { __call = function(_, ...)
  local t = setmetatable({ length = 0 }, list)
  for _, v in ipairs{...} do t:push(v) end
  return t
end })

function list:push(t)
  if self.last then
    self.last._next = t
    t._prev = self.last
    self.last = t
  else
    -- this is the first node
    self.first = t
    self.last = t
  end
  
  self.length = self.length + 1
end

function list:unshift(t)
  if self.first then
    self.first._prev = t
    t._next = self.first
    self.first = t
  else
    self.first = t
    self.last = t
  end
  
  self.length = self.length + 1
end

function list:insert(t, after)
  if after then
    if after._next then
      after._next._prev = t
      t._next = after._next
    else
      self.last = t
    end
    
    t._prev = after    
    after._next = t
    self.length = self.length + 1
  elseif not self.first then
    -- this is the first node
    self.first = t
    self.last = t
  end
end

function list:pop()
  if not self.last then return end
  local ret = self.last
  
  if ret._prev then
    ret._prev._next = nil
    self.last = ret._prev
    ret._prev = nil
  else
    -- this was the only node
    self.first = nil
    self.last = nil
  end
  
  self.length = self.length - 1
  return ret
end

function list:shift()
  if not self.first then return end
  local ret = self.first
  
  if ret._next then
    ret._next._prev = nil
    self.first = ret._next
    ret._next = nil
  else
    self.first = nil
    self.last = nil
  end
  
  self.length = self.length - 1
  return ret
end

function list:remove(t)
  if t._next then
    if t._prev then
      t._next._prev = t._prev
      t._prev._next = t._next
    else
      -- this was the first node
      t._next._prev = nil
      self._first = t._next
    end
  elseif t._prev then
    -- this was the last node
    t._prev._next = nil
    self._last = t._prev
  else
    -- this was the only node
    self._first = nil
    self._last = nil
  end

  t._next = nil
  t._prev = nil
  self.length = self.length - 1
end

local function iterate(self, current)
  if not current then
    current = self.last
  elseif current then
    current = current._prev
  end
  
  return current
end

function list:iterate()
  return iterate, self, nil
end

-- function list:get(first, last) --allows for range
--   if first > last then --swap first and last if the range is reversed
--     local f,l = first,last
--     first = l
--     last = f
--   end
--   local retList = {}
--   for v in list:iterate() do
--     if 
--     table.insert(retList, 
--   end
--   list:iterate()
--   -- if not last then --if just the 
--   --   return self.first
--   -- end

-- end

return list
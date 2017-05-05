--[[
  This is the camera class
  @uses 
    HUMP library's timer for tweening between movements
  @usedBy 
    CURRENT_MAPManager.class.lua
    player.class.lua
]]


local camera = {}

local cos, sin = math.cos, math.sin
local lg = love.graphics
local function clampCoords(cam)
  cam._x = math.clamp(cam._x, cam._bounds.x1, cam._bounds.x2)
  cam._y = math.clamp(cam._y, cam._bounds.y1, cam._bounds.y2)
end

function camera:init()
  self.layers = {}
  self._x = 0
  self._y = 0
  self.scale = 1
  self.rotation = 0
  self.timer = _timer.new()
  self.pointOfRotation = {x=_windowWidth/2, y=_windowHeight/2}
  self.isShaking = false
end
 
function camera:set()
  lg.push()

  -- rotate around the center of the screen by angle radians
  lg.translate(self.pointOfRotation.x, self.pointOfRotation.y)
  lg.rotate(-self.rotation)
  lg.translate(-self.pointOfRotation.x, -self.pointOfRotation.y)

  lg.scale(1 / self.scale, 1 / self.scale)
  lg.translate(-self._x, -self._y)
end
 
function camera:unset()
  lg.pop()
end

function camera:newLayer(scale, func, index, name)
  table.insert(self.layers, { draw = func, scale = scale, index = index, name = name})
  table.sort(self.layers, function(a, b) return a.index < b.index end)
end

function camera:clearLayers(amount) -- if amount is set to true it will delete all layers of the camera 
  if amount == true then 
    for k in pairs (self.layers) do
      self.layers[k] = nil
    end
  else 
    for i=1,amount do
      table.remove(self.layers)
    end
  end
end

function camera:draw(drawDynamic)
  local bx, by = self._x, self._y
  camera:set()
  drawDynamic()
  camera:unset()
  -- for _, l in ipairs(self.layers) do

  --   self._x = bx * l.scale
  --   self._y = by * l.scale
  --   camera:set()
  --   if l.name == "Collision Layer" then
  --     drawDynamic()
  --   end
  -- if not debug then     
  --   l.draw()
  -- end
  -- if debug and l.name == "Collision Layer" then
    
  --   l.draw()
  -- end
  --   camera:unset()
  -- end
  lg.print("FPS: " .. love.timer.getFPS(), 0, 0)
   
end
 
function camera:rotate(dr)
  self.rotation = self.rotation + dr
end
--[[
  @parameters
  z_amount: is the amount (or speed) at which the zoom will occur
  postive numbers result in a zoom out while negative result in a zoom in
  x and y: These are optional parameters and zoom toward a the specified position
]]
function camera:zoom(newZoom)
  self.timer.tween(0.3, self, {scale = newZoom}, 'in-quad', clampCoords(self))
end

function camera:shake(intensity, duration, rotX, rotY)
  if rotX and rotY then
    local camX,camY = self:cameraCoords(rotX, rotY)
    self.pointOfRotation = {x = camX, y = camY}
  end
  local function shakeScript(wait) 
    self.isShaking = true
    camera.timer.tween(duration/4, self, {rotation = intensity}, 'linear')
    wait(duration/4)
    camera.timer.tween(duration/4, self, {rotation = -intensity*2}, 'linear')
    wait(duration/4)
    camera.timer.tween(duration/4, self, {rotation = intensity*2}, 'linear')
    wait(duration/4)
    camera.timer.tween(duration/4, self, {rotation = -intensity}, 'linear')
    wait(duration/4)
    --return to 0
    camera.timer.tween(duration/4, self, {rotation = 0}, 'linear')
    self.pointOfRotation = {x=_windowWidth/2, y=_windowHeight/2} --Set point of rotation back to default
    self.isShaking = false
    --print("After" .. self.rotation)
  end
  if not self.isShaking then
    --print("Before " .. self.rotation)
    self.timer.script(shakeScript)
  end

end
 
function camera:setX(value)
  value = value + (self.scale)
  if self._bounds then
    --print(self._x, self._bounds.x1, self._bounds.x2)
    self._x = math.clamp(value, self._bounds.x1, self._bounds.x2)
  else
    self._x = value
  end
end
 
function camera:setY(value)
  value = value+(self.scale)
  if self._bounds then
    self._y = math.clamp(value, self._bounds.y1, self._bounds.y2)
  else
    self._y = value
  end
end
 
function camera:setPosition(x, y)
  if x then self:setX(x) end
  if y then self:setY(y) end
end

function camera:move(x,y)
  if self._bounds then
    
    if x then 
      local targetX = math.clamp(self._x + x, self._bounds.x1, self._bounds.x2) 
      local noclampX = self._x + x
     
      if(noclampX ~= targetX) then 
        
         self._x = targetX
      else
        self.timer.tween(0.3, self, {_x = targetX}, 'in-out-quad')
      end
      --cameraTimer.tween(0.2, self, {_x = targetX}, 'out-quad')
    end

    if y then 
      local targetY = math.clamp(self._y + y, self._bounds.y1, self._bounds.y2)
      local noclampY = self._y + y
      
      if(noclampY ~= targetY) then 
        self._y = targetY
      else
        self.timer.tween(0.3, self, {_y = targetY}, 'in-out-quad')
      end

    end

  end
end

 
function camera:setScale(s)

  self.scale = s or self.scale
  clampCoords(self)
  self:setBounds(self._bounds.x1,self._bounds.y1,self._bounds.x2,self._bounds.y2)
  -- self._x = math.clamp(self._x, self._bounds.x1, self._bounds.x2)
  -- self._y = math.clamp(self._y, self._bounds.y1, self._bounds.y2)
end

function camera:getScale()
  return self.scale
end
 
function camera:getBounds()
  return self._bounds
end
 
function camera:setBounds(x1, y1, x2, y2)
  --self._bounds = { x1 = -1000, y1 = -1000, x2 = 1000, y2 = 1000}
  self._bounds = { x1 = (x1/self.scale), y1 = (y1/self.scale), x2 = (x2/self.scale), y2 = (y2/self.scale) }
end

function camera:cameraCoords(x,y)
	-- local w,h = lg.getWidth(), lg.getHeight()
	-- local c,s = cos(self.rotation), sin(self.rotation)
	-- x,y = x - self._x, y - self._y
	-- x,y = c*x - s*y, s*x + c*y
	-- return x*self.scale + w/2, y*self.scale + h/2
  x,y = (x-self._x)/self.scale, (y-self._y)/self.scale
  return x, y
end

function camera:worldCoords(x,y)
  x,y = x*self.scale, y*self.scale
	return x+self._x, y+self._y
end

function camera:centerOnPoint(x,y)
  local centerX = (_windowWidth/2)*self.scale
  local centerY = (_windowHeight/2)*self.scale

  self:setPosition( (x-centerX), (y-centerY))

 -- self:setBounds(0, 0, (1000 - (_windowWidth*self.scale)), (1000 - (_windowHeight*self.scale)))

  --self:move(0,0)

  -- if x < _windowWidth/10 and x >= 0 then
  --   self:move(-10*self.scale, 0)
  -- elseif x > _windowWidth - _windowWidth/10 and x <= _windowWidth then
  --   self:move(10*self.scale, 0)
  -- end
  -- if y < _windowHeight/10 and y >= 0 then
  --   self:move(0 , -10*self.scale)
  -- elseif y > _windowHeight - _windowHeight/10 and y <= _windowHeight then
  --   self:move(0 , 10*self.scale)
  -- end
  -- self:setBounds(0, 0, (1000 - (_windowWidth*self.scale)), (1000 - (_windowHeight*self.scale)))
end


return camera
local bombManager = {}
local Camera = require("Code/Util/camera")
local Class = require "Assets/Libs/HUMP/class"

--local FoodParticles = require("Code/particles/food_particle")
local function calcAngle(x1,y1,x2,y2)
	return math.atan2((y2-y1),(x2-x1))
end
local testx, testy = 0,0
-- local timer = _timer.new()
local Bomb = Class{}

function Bomb:init(id)
	local x, y = math.random(10,_windowWidth-10), math.random(10,_windowHeight-10)
	self.col = _collider:circle(x, y, 7)
	self.col.type = "bomb"
	self.col.lethal = false
	self.angle = math.random()
	self.stretch = 1
	self.growth = 0
	self.detectionRange = _collider:circle(x, y, 100)
	self.detectionRange.type = "bomb_range"

	self.timer = _timer.new()
	self.timer.script(function(wait) 
		wait(math.random(0.0, 3.0))
		self.timer.every(3, function()self:pulse()end)
	end)
	
	self.img = lg.newImage("Assets/Sprites/Entities/bomb.png")
	self.imgLethal = lg.newImage("Assets/Sprites/Entities/bomb_lethal.png")
	self.id = id
end

function Bomb:moveToward(other)
	local x, y = self.col:center()
	local sx, sy = other:center()
	x = x + (sx-x)*0.03
	y = y + (sy-y)*0.03
	self.angle = calcAngle(x, y, sx, sy)
	self.col:moveTo(x, y)
	self.detectionRange:moveTo(x, y)
end

function Bomb:moveAway(other, dx, dy)
	self.col:move(dx, dy)
	self.detectionRange:move(dx, dy)
end

function Bomb:pulse()
	self.timer.script(function(wait)
		self.col.lethal = true
		self.timer.tween(0.2, self, {stretch = 1.3}, 'in-out-quad')
		wait(0.6)
		self.timer.tween(0.2, self, {stretch = 1}, 'in-out-quad')
		wait(0.6)
		self.col.lethal = false
	end)
end

function Bomb:eat(amount)
	self.timer.tween(0.2, self, {growth = (self.growth + amount)}, 'in-out-quad')
end

function Bomb:die()
	self.timer.script(function(wait) --must wait for all collisions to resolve before dying
    	wait(0)
    	_collider:remove(self.col)
		_collider:remove(self.detectionRange)
		bombManager:removeBomb(self)	
    end)
end

function Bomb:update(dt)
	self.timer.update(dt)
	--Collision detection/handling
	local candidates = _collider:neighbors(self.detectionRange) -- shapes close to the detection range
	for other in pairs(candidates) do -- iterate these shapes
		if other.type ~= "bomb_range" and other.id ~= self.id then -- move away from other shapes
    		local collides, dx, dy = self.col:collidesWith(other)
    		if collides and other.type == "snake_head" then -- if bomb hits snakes head
    			self:die()
    		end
    		if collides and other.type == "food" then
    			self:eat(0.01)
    		end
    		if collides then -- if bomb expierences a great change in dy and dx = explode
    			if dx > 4 and dy > 4 then
    				self:die()
    			else
    				self:moveAway(other, dx, dy)
    			end
    		end
    	end
		if other.type == "snake_head" then --is within detection range

			local collides, dx, dy = self.detectionRange:collidesWith(other)
    		if collides then
        		self:moveToward(other)
    		end
    	elseif other.type == "food" then
    		local collides, dx, dy = self.detectionRange:collidesWith(other)
    		if collides then
        		self:moveToward(other)
    		end

    	end

	end
end

function Bomb:draw()
	local x, y = self.col:center()

	if self.col.lethal == true then 
		lg.draw(self.imgLethal, x, y, self.angle, 
		(self.stretch + self.growth), (self.stretch + self.growth), 
   		self.imgLethal:getWidth()/2, 
   		self.imgLethal:getHeight()/2)
	else  
		lg.draw(self.img, x, y, self.angle, 
		(self.stretch + self.growth), (self.stretch + self.growth), 
   		self.img:getWidth()/2, 
   		self.img:getHeight()/2)
	end

	if _debugMode then 
		self.detectionRange:draw("line")
		self.col:draw("line")
		local x, y = self.col:center()
		lg.print("Lethal: " .. tostring(self.col.lethal), x, y)

	end
end

function bombManager:init(numBomb)

	-- self.timer = _timer.new()
	self.bombs = {}
	bombManager:addBomb(numBomb or 10)
	
end

function bombManager:draw()
	--FoodParticles:draw()
	for _,bomb in pairs(self.bombs) do
		bomb:draw()
	end
end

function bombManager:update(dt) --which shape to move towards
	for i,bomb in ipairs(self.bombs) do
		bomb:update(dt)
	end
end

function bombManager:addBomb(amount)
	for i=1,amount do
		table.insert(self.bombs, Bomb(i))
	end
end

function bombManager:removeBomb(bomb, id)
	-- FoodParticles:start()
	-- FoodParticles:emit(self.bombs[index].pos.x, self.bombs[index].pos.y, headAngle)
	-- FoodParticles:stop()
	for i,v in ipairs(self.bombs) do
		if v == bomb then -- create two bombs and remove a bomb
			table.insert(self.bombs, Bomb(bomb.id))
			table.insert(self.bombs, Bomb(#self.bombs))
			table.remove(self.bombs, i)
		end
	end
	-- print(self.bombs[bomb]);
	-- table.insert(self.bombs, Bomb(index))


	--self:addBomb(1, index)
end

function bombManager:getFood()
	
end

return bombManager
local foodManager = {}
local FoodParticles = require("Code/particles/food_particle")
local Camera = require("Code/Util/camera")

--Util functions
local function calcAngle(x1,y1,x2,y2)
	return math.atan2((y2-y1),(x2-x1))
end
-- local timer = _timer.new()

function foodManager:init(numFood)
	self.timer = _timer.new()
	FoodParticles:init()
	self.foods = {}
	--images
	self.foodImg = lg.newImage("Assets/Sprites/Entities/food.png")
	foodManager:addFood(numFood or 10)
end

function foodManager:draw()
	FoodParticles:draw()
	for _,foodPiece in pairs(self.foods) do
		local x, y = foodPiece:center()
   		lg.draw(self.foodImg, x, y, foodPiece.angle, 1, 1, 
   			self.foodImg:getWidth()/2, self.foodImg:getHeight()/2)
		if _debugMode then
			foodPiece:draw("line")
		end
	end
end

function foodManager:update(dt)
	FoodParticles:update(dt)
	self.timer.update(dt)
	for index,food in ipairs(self.foods) do
		local collisions = _collider:collisions(food)
		for other, separating_vector in pairs(collisions) do
    		if other.type == "snake_head" or other.type == "bomb" then
    			local x, y = food:center()
        		local calcedAngle = (calcAngle(x, y, separating_vector.x , separating_vector.y))
    			foodManager:removeFood(index, calcedAngle)
    		end
		end
	end
end

function foodManager:addFood(amount)
	for i=1, amount do
		--Add window width/height because the x2 and y2 bounds stop at the top left of the window
		local ranX = math.random(0, (Camera._bounds.x2+_windowWidth)) 
		local ranY = math.random(0, (Camera._bounds.y2+ _windowHeight))
		local ranAngle = math.random()
		local foodPiece = _collider:circle(ranX, ranY, 5)
		foodPiece.angle = ranAngle
		foodPiece.type = "food"
		table.insert(self.foods, foodPiece)
	end
end

function foodManager:removeFood(index, angle)
	local x, y = self.foods[index]:center()
	FoodParticles:start()
	FoodParticles:emit(x, y, angle)
	FoodParticles:stop()

	self.timer.script(function(wait) --must wait for all collisions to resolve before dying
    	wait(0)
    	_collider:remove(self.foods[index])
		table.remove(self.foods, index)
    end)
	
	self:addFood(1)
end

function foodManager:getFood()
	
end

return foodManager
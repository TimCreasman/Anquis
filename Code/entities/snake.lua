
--Tweening method for reference
--x = x + (target-x)*delay

local Class = require "Assets/Libs/HUMP/class"
local list = require("Code/Util/list")
local FoodManager = require "Code/entities/foodManager"
local Camera = require "Code/Util/camera"
local SoundManager = require "Code/Util/soundManager"

--Util functions
local function calcAngle(x1,y1,x2,y2)
	return math.atan2((y2-y1),(x2-x1))
end

--[[
	px: X coordinate of point to check
	py: Y coordinate of point to check
	bx: X coordinate fo bounding box
	by: Y coordinate fo bounding box
	bs: size of bounding box
]]

--move out of this class
local function pointInBounds(px,py,bx,by,bs)
	return ((px > bx-bs) and (px < bx+bs) and (py > by-bs) and (py < by+bs))
end

local function loadSprites(this) 
	this.eyeImg = lg.newImage("Assets/Sprites/Entities/Snake/snake_eye.png")
	this.headImg = lg.newImage("Assets/Sprites/Entities/Snake/snake_head.png")
	this.neckImg = lg.newImage("Assets/Sprites/Entities/Snake/snake_neck.png")
	this.bodyImg = lg.newImage("Assets/Sprites/Entities/Snake/snake_body.png")
	this.lethalButtImg = lg.newImage("Assets/Sprites/Entities/Snake/snake_butt_lethal.png")
	this.buttImg = lg.newImage("Assets/Sprites/Entities/Snake/snake_butt.png")
end

local function loadSFX(this)
  this.crunchSFX = "Assets/SoundEffects/Crunch.wav"
end

--move to sound sound class
local function playSoundVariant(sound)
	local ranVol = math.random(0.9,1.0)
	local ranPit = math.random(0.8,1.0)
	SoundManager.play(sound, "static", false, ranVol, ranPit)
end

Snake = Class{}

function Snake:init(x,y, snakeId, segmentAmount, controller)
	self.timer = _timer.new()
	self.snakeId = snakeId --used to identify colliders in a collision
	loadSprites(self)
	loadSFX(self)

	--hidden first part
	local hidCol = _collider:rectangle(x-110, y, 1, 1)
	hidCol.type = "hidden"
	local hiddenSegment = {{
	collider = hidCol}}
	--body segments
	self.controller = controller --Replace with AI:controller

	local headCol = _collider:rectangle(x-100, y, 30, 30)
	headCol.snakeId = self.snakeId
	headCol.type = "snake_head"
	self.head = {{
		collider = headCol, 
		isBroken = false}}

	local neckCol = _collider:rectangle(x, y, 20, 20)
	neckCol.snakeId = self.snakeId
	neckCol.type = "neck"
	self.neck = {{
		collider = neckCol,
		isBroken = false}}

	local buttCol = _collider:rectangle(x+100, y, 20, 20)
	buttCol.snakeId = self.snakeId
	buttCol.type = "butt"
	self.butt = {{ 
		collider = buttCol,
		isBroken = false}}

	self.body = list(hiddenSegment, self.head,self.neck,self.butt)

	self.splitBodies = {}

	for i=1,segmentAmount do
		self:addSegment()
	end


	--other
	self.speed = 200
	self.headAngle = 3.14
	self.health = 100
	self.lethalButt = false

end

function Snake:draw()
	--self.getController
	local jrx = self.controller:getXRotation()
	local jry = self.controller:getYRotation()
	
	local function calcDistance(x1,y1,x2,y2)
		return math.sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2))
	end
	for v in self.body:iterate() do 
		--if not v[1].isBroken then
			local segment = v[1]
			local segX, segY = segment.collider:center()

			local prevSeg, prevSegX, prevSegY
			local segAngle, segDistance

			if v._prev then 
				prevSeg = v._prev[1]
				prevSegX, prevSegY = prevSeg.collider:center()
				segAngle = calcAngle(segX, segY,prevSegX,prevSegY)
				segDistance = calcDistance(segX, segY,prevSegX,prevSegY)
			end

			local nextSeg, nextSegX, nextSegY
			if v._next then 
				nextSeg = v._next[1] 
				nextSegX, nextSegY = nextSeg.collider:center()
			end

			local segType = segment.collider.type	

			if segType == "body" then
				
				local sx = 1+(segDistance/20)
				local sy = 1+(-(segDistance/160))
				--local sy = 1+(math.abs((prevSegX)-(segY))/20)
				--local sy = 1+((prevSegX-(segY))/20)
				if segment.isBroken and v ~= self.body.last then 
					lg.setColor(100,100,100)
					segAngle = calcAngle(segX, segY,nextSegX,nextSegY)
					sx, sy = 2,1 
				else 
					lg.setColor(255,255,255)
				end
				
  				lg.draw(self.bodyImg, segX, segY,segAngle,sx,sy,self.bodyImg:getWidth()/2,self.bodyImg:getHeight()/2)
			end
			if segType == "butt" then
				lg.setColor(255,255,255)
				if self.lethalButt then
  					lg.draw(self.lethalButtImg, segX, segY,_,1.5,1.5,self.lethalButtImg:getWidth()/2,self.lethalButtImg:getHeight()/2)
  				else
  					lg.draw(self.buttImg, segX, segY,_,1.5,1.5,self.buttImg:getWidth()/2,self.buttImg:getHeight()/2)
  				end
			end
			if segType == "neck" then
				lg.setColor(255,255,255)
				local sx = 1+(segDistance/200)
				local sy = 1+(-(segDistance/100))
  				lg.draw(self.neckImg, segX, segY,segAngle,sx * 1.5,sy * 1.5,self.neckImg:getWidth()/2,self.neckImg:getHeight()/2)
  			
			end
			if segType == "snake_head" then
			
				--x = x + (target-x)*delay
				lg.setColor(255,255,255)

				-- self.headAngle = self.headAngle + (calcedAngle-self.headAngle)*0.2
				self.headAngle = segAngle

				if math.abs(jrx) > 0.1 or math.abs(jry) > 0.1 then
					local calcedAngle = calcAngle(segX, segY,(segX+jrx),(segY+jry))
					self.headAngle = calcedAngle
				end

  				lg.draw(self.headImg, segX, segY,self.headAngle,2,2,self.headImg:getWidth()/2,self.headImg:getHeight()/2)
  				-- lg.print("angle " .. self.headAngle, segX+16, segY)
  			
  				local eyeSX, eyeSY = 1,1
  		-- 		if pointInBounds(self.butt[1].pos.x, self.butt[1].pos.y, segX, segY, 16) 
				-- 	and self.lethalButt then
				-- 	eyeSX = eyeSX + (2-eyeSX)*0.03
				-- 	eyeSY = eyeSY + (2-eyeSY)*0.03
				-- else
				-- 	eyeSX, eyeSY = 1,1
				-- end
				lg.draw(self.eyeImg, segX, segY,_,eyeSX,eyeSY,self.eyeImg:getWidth()/2,self.eyeImg:getHeight()/2)
			end
		--end
		if _debugMode then 
			segment.collider:draw("line")
			if segType == "hidden" then
				lg.draw(self.eyeImg, segX, segY,_,1.5,1.5,self.headImg:getWidth()/2,self.headImg:getHeight()/2)
			end
		end
	end
  --lg.draw(self.eyeImg, self.pos.x, self.pos.y,_,_,_,self.eyeImg:getWidth()/2,-self.eyeImg:getHeight()/2)
end

function Snake:update(dt)
	self.timer.update(dt)

	local jx = self.controller:getXMovement()*(self.speed)
	local jy = self.controller:getYMovement()*(self.speed)


	if self.body.length > 7 then 
		self.lethalButt = true
	else
		self.lethalButt = false
	end

	self:handleCollisions()

	for v in self.body:iterate() do 

		local segment = v[1]
		local segX, segY = segment.collider:center()

		local prevSeg, prevSegX, prevSegY
		local segAngle
		if v._prev then 
			prevSeg = v._prev[1]
			prevSegX, prevSegY = prevSeg.collider:center()
			segAngle = calcAngle(segX, segY,prevSegX,prevSegY)
		end

		local nextSeg, nextSegX, nextSegY
		if v._next then 
			nextSeg = v._next[1] 
			nextSegX, nextSegY = nextSeg.collider:center()
		end

		local segType = segment.collider.type	

		--move the hidden segment
		if segType == "hidden" then
			if math.abs(jx) > 10 then 
				segX = segX+((segX+(jx))-segX)*.03
			end
			if math.abs(jy) > 10 then 
				segY = segY+((segY+(jy))-segY)*.03
			end
		end

		if not segment.isBroken then

			if segType == "snake_head" then
				for shape, delta in pairs(_collider:collisions(segment.collider)) do
					if shape.type == "bomb" then
						if shape.lethal then
							self:removeBody(v._next._next, 5) -- remove one before neck
						else -- NOTE should be eatFood but eatFood method needs to be more general
							self:addSegment(2)
						end
					end
					if shape.type == "food" then
				 		self:addSegment()
					end
				end
				--Move snake
				if math.abs(prevSegX-segX) > 1 or math.abs(prevSegX-segY) > 1 then
					segX = segX+(prevSegX-segX)*.2
					segY = segY+(prevSegY-segY)*.2
					segment.collider:setRotation(segAngle)
					-- segX = prevSegX
					-- segY = prevSegY
				end
			end
			if segType == "body" or segType == "butt" or segType == "neck" then
				local targetX = 0
				local targetY = 0
			
				-- if distance is more than an amount set target values to current position
				if math.abs(prevSegX-segX) <= 10 and math.abs(prevSegY-segY) <= 10  then
					targetY = segY
					targetX = segX
				else
					targetY = prevSegY
					targetX = prevSegX
				end

				segX = segX+(targetX-segX)*.2
				segY = segY+(targetY-segY)*.2
				segment.collider:setRotation(segAngle)

			end
			if segType == "body" then
				for shape, delta in pairs(_collider:collisions(segment.collider)) do

					if shape.snakeId then --if the shape is from a snake
						if shape.snakeId ~= self.snakeId then --another snake
							if shape.type == "snake_head" then
								self:markBodyBroken(v)
							end
					 		-- for i,v in ipairs(shape) do
					 		-- 	print(i,v)
					 		-- end
						end
					end
				end
				-- if segment.collider:contains(self.head[1].collider:center()) then
				-- 	self:markBodyBroken(v)
				-- end
				-- if pointInBounds(segX, segY, , self.head[1].pos.y, 16) then --Head touches body
					
				-- end 
			end
			if segType == "butt" then
				-- if pointInBounds(segX, segY, self.head[1].pos.x, self.head[1].pos.y, 16) --Head touches butt
				-- 	and self.lethalButt then
				-- 	self:removeBody(v._prev)
				-- 	--self.head[1].pos.x = self.head[1].pos.x+( math.random(self.head[1].pos.x-70,self.head[1].pos.x+70) -self.head[1].pos.x)*.3
				-- 	--self.head[1].pos.y = self.head[1].pos.y+(math.random(self.head[1].pos.y-70,self.head[1].pos.y+70)-self.head[1].pos.y)*.3
				-- end 
			end
		else --segment is broken
			--if v ~= self.body.last then 
				self:markBodyBroken(v._next) -- set the next body as broken as well, 
				-- this creates a chain reaction

				if not prevSeg.isBroken then --the body part just before the broken part
					self.butt = v._prev
					prevSeg.collider.type = "butt"
				end
				
				-- if pointInBounds(segX, segY, self.head[1].pos.x, self.head[1].pos.y, 16) then --Head touches body
				-- 	self:removeBody(v)
				-- 	self:addSegment()
				-- end
			--end
			
		end

		v[1].collider:moveTo(segX,segY)

	end
end

function Snake:handleCollisions()

end

function Snake:addSegment(amount)

	local x, y = self.butt[1].collider:center()

	if amount then
		for i=1,amount do
			local bodyCol = _collider:rectangle(x, y, 25, 10)
			bodyCol.snakeId = self.snakeId
			bodyCol.type = "body"
			local body = {{
			collider = bodyCol,
			isBroken=false}}
			self.body:insert(body, self.butt._prev)
			--Zoom out
			Camera:zoom(Camera:getScale()+0.003)
		end
	else
		local bodyCol = _collider:rectangle(x, y, 25, 10)
		bodyCol.snakeId = self.snakeId
		bodyCol.type = "body"
		local body = {{
		collider = bodyCol,
		isBroken=false}}
		self.body:insert(body, self.butt._prev)
		--Zoom out
		Camera:zoom(Camera:getScale()+0.003)
	end
	
end

function Snake:markBodyBroken(segment)
	if segment[1].collider.type == "body" 
	and segment._prev[1].collider.type ~= "neck" then
		segment[1].isBroken = true
	end
end

function Snake:removeBody(segment, amount)
	if amount then
		for i=1, amount do
			self.body:remove(segment)
			Camera:zoom(Camera:getScale()-0.003)
		end
	else
		self.body:remove(segment)
		Camera:zoom(Camera:getScale()-0.003)
	end

	Camera:shake(0.05, 0.3, self.head[1].pos.x, self.head[1].pos.y)
end

function Snake:eatFood(foodIndex, headAngle)
	playSoundVariant(self.crunchSFX)
  	self:addSegment()
end

function Snake:getPosition()
	return self.head[1].collider:center()
end

return Snake
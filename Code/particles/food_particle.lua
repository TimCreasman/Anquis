local foodParticles = {}

function foodParticles:init() 
	local texture = lg.newImage("Assets/Particles/food.png")
	self.particleSystem = love.graphics.newParticleSystem(texture, 1000)
	self.particleSystem:setEmissionRate(100)
	self.particleSystem:setSpeed(100, 300)
	self.particleSystem:setSpin(3, 0, 1)
	self.particleSystem:setLinearDamping(5,20)
	self.particleSystem:setSpinVariation(0)
	self.particleSystem:setParticleLifetime(2, 4)
	self.particleSystem:setSizes(3, 1)
	self.particleSystem:setColors(255, 255, 255, 255, 132,104,48, 200)
	self.particleSystem:setEmitterLifetime(1)
	self.particleSystem:setRadialAcceleration(0)
	self.particleSystem:setSpread(3.14)
	self.particleSystem:setTangentialAcceleration(0)
	self.particleSystem:stop()
end

function foodParticles:draw()
	lg.draw(self.particleSystem, 0, 0)
end

function foodParticles:update(dt) 
	self.particleSystem:update(dt)
end

function foodParticles:emit(x,y,dir) 
	self.particleSystem:setPosition(x,y)
	self.particleSystem:setDirection(dir)
	self.particleSystem:emit(35)
end
function foodParticles:start() 
	self.particleSystem:start()
end
function foodParticles:stop() 
	self.particleSystem:stop()
end

return foodParticles
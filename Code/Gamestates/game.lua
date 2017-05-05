local game = {}
local Snake = require "Code/entities/snake"
local FoodManager = require "Code/entities/foodManager"
local BombManager = require "Code/entities/BombManager"
local Camera = require "Code/Util/camera"
local SoundManager = require "Code/Util/soundManager"
local ControllerManager = require "Code/Util/controllerManager"

function game:name()
  return "game"
end

function game:init()
  print("Initiating game...")
  Camera:init()
  
  Camera:setBounds(0, 0, 1500 - (_windowWidth), 1500 - (_windowHeight))
  --Camera:setBounds(0, 0, (1000 - (_windowWidth/2)), (1000 - (_windowHeight/2)))
  Camera:setScale(0.5)
  
  FoodManager:init(300)
  BombManager:init(10)

  snake = Snake(300,300, 1, 1, ControllerManager.getController(1))
  -- --snake2 = Snake(200,200, 2, 10, {})
  -- if _Joysticks[2] then 
  --   snake2 = Snake(200,200, 2, 10, _Joysticks[2])
  -- end

  self.music = love.audio.newSource("Assets/Music/Mysterium.mp3", "stream", true)
  print("Game initiation complete.")

end

function game:enter(from)
  print("Entered game from " .. from.name())
  love.mouse.setVisible(false)
  SoundManager.play(self.music)

end

function game:resize(w,h)
  Camera:setBounds(0, 0, (1000 - (window_width*camera_scale)), (1000 - (window_height*camera_scale)))

end

function game:draw()
  lg.clear(80,112,188)
  -- lg.draw(bg)
  
  Camera:draw(function() 
    FoodManager:draw()
    BombManager:draw()
    snake:draw()
    end)
end

function game:keyreleased(key, code)

end

function game:keypressed(key, code)

end

function game:update(dt)
  SoundManager.update()
  snake:update(dt, FoodManager)
  -- if _Joysticks[2] then 
  --   snake2:update(dt, FoodManager)
  -- end
  FoodManager:update(dt)
  BombManager:update(dt)
  Camera.timer.update(dt)

  local snakeX,snakeY = snake:getPosition()
  --local snake1Pos = snake2:getPosition()
  Camera:centerOnPoint(snakeX, snakeY)
  
end

function game:leave()
  print("Leaving game.")
  SoundManager.stop(self.music)
  love.mouse.setVisible(true)
end

return game
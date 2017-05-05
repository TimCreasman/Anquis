local menu = {}
local SoundManager = require "Code/Util/soundManager"
local Gui = require "Assets/Libs/SUIT"
local show_message = false
local ControllerManager = require "Code/Util/controllerManager"

function menu:name()
  return "menu"
end

function menu:init()
  print("Initiating menu...")

  self.menuTimer = _timer.new()
  --self.menuImage = lg.newImage("Assets/Sprites/splash.png")
  self.layout = {
    padding = {
      w = 20, --Width and height of padding
      h = 20
    },
    button = {
      w = 150, --Width and height of a button
      h = 40
    }
  }
  --Find the exact center of the screen
  self.layout.pos = {
    x = (_windowWidth/2) - (self.layout.button.w/2),
    y = (_windowHeight/2) - (self.layout.button.h/2)
  }
  
 -- self.imageWidth,self.imageHeight = self.menuImage:getWidth(), -self.menuImage:getHeight()
  --self.menuPos = lg.newQuad(0,0, 536,101, self.menuImage:getDimensions())
  self.textPosition = _windowWidth
  self.music = love.audio.newSource("Assets/Music/Title.mp3")
  self.title = lg.newImage("Assets/Sprites/Menu/title.png")
  --self.menuTimer.script(introScript)
  print("Splash initiation complete.")
end

function menu:enter(from)
  print("Entered menu.")
  
  SoundManager.setMute(true)
  SoundManager.play(self.music)

end

function menu:update(dt)
  self.menuTimer.update(dt)

  Gui.layout:reset(self.layout.pos.x, 
    self.layout.pos.y, 
    self.layout.padding.w, 
    self.layout.padding.h)
  
  local startButton = Gui.Button(
    "Start Game",
    Gui.layout:row(self.layout.button.w,self.layout.button.h))

  local optionsButton = Gui.Button("Options", Gui.layout:row())
  local quitButton = Gui.Button("Quit", Gui.layout:row())

  if startButton.hit then
    _stateMachine.switch(_gameState)
  end
  if optionsButton.hit then
    _stateMachine.switch(_optionsState)
  end
  if quitButton.hit then
    love.event.quit()
  end


end

function menu:draw()
  lg.clear(255,255,255)
  lg.draw(self.title, _windowWidth/2, _windowHeight/4+self.title:getHeight(),_,_,_,self.title:getWidth()/2, self.title:getHeight()/2)
  
  Gui.draw()

  local numOfControllers = ControllerManager.getControllerAmount()
  local color = {176,60,60,255}
  local joystickMsg = {color, "No Controller Connected!!!"}

  if numOfControllers == 1 then
    color = {0,0,0,255}
    joystickMsg = {color, "1 Controller Connected"}
  elseif numOfControllers > 1 then
    color = {0,0,0,255}
    joystickMsg = {color, numOfControllers .. " Controllers Connected"}
  end

  lg.printf(joystickMsg,-30,(_windowHeight-30), _windowWidth, "right") 


  --lg.draw(self.menuImage, _windowWidth/2, _windowHeight/2,_,10,10,self.imageWidth/2,-self.imageHeight/2)

end

function menu:keyreleased(key, code)
  --switchs states into game state if the enter key is pressed
    -- if key ~= 'escape' then
    --     _stateMachine.switch(_gameState)
    -- end
end

function menu:joystickreleased(joystick, button )
  if button ~= 13 then
      _stateMachine.switch(_gameState)
  end
end

function menu:leave()
  print("Leaving menu...")
  self.menuTimer.clear()
  SoundManager.stop(self.music)
  print("Left menu.")
end

return menu
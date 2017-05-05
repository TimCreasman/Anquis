local splash = {}
local SoundManager = require "Code/Util/soundManager"
local Anim8 = require "Assets/Libs/anim8/anim8"

function splash:name()
  return "splash"
end



function splash:init()
  print("Initiating splash...")

  self.splashTimer = _timer.new()
  self.splashImage = lg.newImage("Assets/Sprites/Splash/logo_sheet.png")

  self.gamePadImage = lg.newImage("Assets/Sprites/Splash/gamepad.png")


  local splashGrid = Anim8.newGrid(196, 83, self.splashImage:getWidth(), self.splashImage:getHeight())
  self.splashAnimation = Anim8.newAnimation(splashGrid("1-35",1), {["1-9"]=0.025, ["10-35"]=0.0375})

  self.doDrawLogo = false
  self.doDrawGamePad = false

  self.splashPosition = {x = (_windowWidth / 2), y = (_windowHeight / 2)}
  
  --self.splashAnimation:getDimensions()

  self.alpha = 0
  --self.imageWidth,self.imageHeight = self.splashImage:getWidth(), -self.splashImage:getHeight()
  --self.splashPos = lg.newQuad(0,0, 536,101, self.splashImage:getDimensions())
  --self.textPosition = _windowWidth
  self.music = love.audio.newSource("Assets/Music/Title.mp3")

  --self.splashTimer.script(introScript)
  print("Splash initiation complete.")

end

function splash:enter(from)
  print("Entered splash.")
  
  local function logoScript(wait) 
    
    --wait for screen to open up
    wait(0.2)
    --start drawing the animation
    self.doDrawLogo = true
    wait(0.175)
    --flash the screen
    self.splashTimer.tween(0.0375, self, {alpha = 255}, "linear")
    wait(0.0375)
    self.splashTimer.tween(0.0375, self, {alpha = 0}, "linear")
    --play the rest of the animation
    wait(0.74)
    self.splashAnimation:pauseAtEnd()
    --show the last frame for 0.5 seconds
    wait(1)
    --stop drawing logo
    self.doDrawLogo = false
    

  end 
  local function gamePadScript(wait)
    self.splashTimer.tween(0.1, self, {alpha = 255}, "linear")
    wait(0.1)
    self.splashTimer.tween(0.1, self, {alpha = 0}, "linear")
    wait(0.1)

    self.doDrawGamePad = true
    wait(1)
    --Fade out
    self.splashTimer.tween(0.3, self, {alpha = 255}, "linear")
    wait(0.1)
    --switch to menu
  end
  local function introScript(wait)
    logoScript(wait)
    gamePadScript(wait)
    _stateMachine.switch(_menuState)
    
  end
  self.splashTimer.script(introScript)

  SoundManager.setMute(true)
  SoundManager.play(self.music)

end

function splash:draw()
  lg.clear(0,0,0)

  lg.setColor(255,255,255, self.alpha)
  lg.rectangle("fill", 0, 0, _windowWidth, _windowHeight)
  -- if not _Joystick then
  --   lg.printf("Joystick not connected",_windowWidth/10,(_windowHeight/2)+self.splashImage:getHeight()+30, _windowWidth, "center") 
  -- else
  --   lg.printf("Press any button to begin",_windowWidth/10,(_windowHeight/2)+self.splashImage:getHeight()+30, _windowWidth, "center") 
  -- end
  lg.setColor(255,255,255)

  if self.doDrawLogo then 
    self.splashAnimation:draw(
      self.splashImage, 
      self.splashPosition.x, self.splashPosition.y
      ,_, -- skip the angle, scale x, and scale y parameters
      1.5,1.5, --scale the image
      (196/2),(83/2)) --half the width of a single frame
  end
  if self.doDrawGamePad then
    lg.draw(self.gamePadImage, 
      _windowWidth/2, -- x
      _windowHeight/2, -- y
      _, -- r
      5,5, -- sx, sy
      self.gamePadImage:getWidth()/2, --ox
      self.gamePadImage:getHeight()/2) --oy

    lg.printf("Gamepad Required", 
      0, -- x
      ((_windowHeight/2) + ((self.gamePadImage:getHeight()/2)*5) +20), -- y
      _windowWidth,
      "center")
  end
  --, _, _, _, ,self.splashImage:getHeight()/2
end

function splash:keyreleased(key, code)
  --switchs states into game state if the enter key is pressed
    if key ~= "escape" then
        _stateMachine.switch(_menuState)
    end
end

function splash:joystickreleased(joystick, button )
 
  if button ~= 13 then
      _stateMachine.switch(_menuState)
  end
end

function splash:update(dt)
  self.splashTimer.update(dt)
  self.splashAnimation:update(dt)
end

function splash:leave()
  print("Leaving splash...")
  self.splashTimer.clear()
  SoundManager.stop(self.music)

  print("Left splash.")

end

return splash
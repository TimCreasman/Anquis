if _logDebug == true then
  require "Assets/Libs/lovedebug" --Debug logger
end

local ControllerManager = require "Code/Util/controllerManager"


function love.load()

  --Common paths
  _FONTS_PATH = "Assets/Fonts/"
  _LIBS_PATH = "Assets/Libs/"
  _MUSIC_PATH = "Assets/Music/"
  _STATES_PATH = "Code/Gamestates/"

  --Load globals
  _stateMachine = require (_LIBS_PATH.."HUMP/gamestate")
  --global timer
  _timer = require (_LIBS_PATH.."HUMP/timer")

  --states
  _splashState = require (_STATES_PATH.."splash")
  _menuState = require (_STATES_PATH.."menu")
  _gameState = require (_STATES_PATH.."game")

  --Create Love module shortcuts
  lg = love.graphics
  la = love.audio

  local font = love.graphics.newImageFont(_FONTS_PATH .. "Anquis-Main-White.png", 
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.:,;(*!?}^)$%", 1) --..
    --"123456789.,!?-+/():;%&`'*#=[]\"" )

  lg.setFont(font)

  local HC = require 'Assets/Libs/HardonCollider'
  _collider = HC.new(96)

  love.graphics.setDefaultFilter( 'nearest', 'nearest' )    
  _stateMachine.registerEvents()
  local _, _, flags = love.window.getMode()
  _screenWidth, _screenHeight = love.window.getDesktopDimensions(flags.display)
  _windowWidth, _windowHeight = love.window.getMode()
  
  math.randomseed(os.time()) --prepping the lua random system See http://lua-users.org/wiki/MathLibraryTutorial
  math.random(); math.random(); math.random()

  _stateMachine.switch(_splashState)

end

function love.update(dt)
  require("lovebird").update() --Access debugger at http://127.0.0.1:8000/#
  _timer.update(dt)
end

function love.resize(w,h)
  _windowWidth, _windowHeight = w,h
  
end

function love.focus(f)
  if not f then
  else
  end
end

function love.keypressed(key)
 	if key == '`' then
 		_debugMode =  not _debugMode
 	end

 	 if key == 'escape' then

      love.event.quit()
   end
end

function love.joystickpressed(joystick, button)
  if button == 13 then
     love.event.quit()
  end
end

function love.joystickadded( joystick )
  ControllerManager.addController("gamepad", 1)
    ControllerManager.addController("gamepad", 2) --TESTING
  --_Joysticks[table.getn(_Joysticks)+1] = joystick
end

function love.joystickremoved( joystick )
  -- for i=#_Joysticks,1,-1 do
  --   if _Joysticks[i] == joystick then
  --     table.remove(_Joysticks, i)
  --   end
  -- end
end

function love.draw()
  lg.clear(255,255,255)
  lg.setColor(255,255,255)

  if _debugMode then
    --lg.setColor(255,0,255)
    lg.print("FPS: " .. love.timer.getFPS(), 0, 0)
  end
end

--[[Utility Functions]]--

function math.clamp(low, n, high) 
  return math.min(math.max(n, low), high) 
end
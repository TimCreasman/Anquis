-- Creates a common controller interface for all forms of input.
-- Currently only gamepad is supported.
--The controller object
local Controller = {}
Controller.__index = Controller

local supportedCtrls = {
    ["mouse"] = true,
    ["gamepad"] = true
}

--[[
    param [enum:string] kind the type of controller (mouse, gamepad, or keyboard)
]]--
function Controller.new(kind)
    print(kind)
    assert(supportedCtrls[kind] == true, "Invalid controller type")
    local ctrl
    if kind == "gamepad" then
        local joysticks = love.joystick.getJoysticks()
        ctrl = joysticks[#joysticks] --set controller to the last connected joystick
    else 
        ctrl = love[kind] --sets the ctrl to either mouse or keyboard
    end
    return setmetatable({kind = kind, ctrl = ctrl or love.mouse}, Controller)
end

function Controller:getXMovement()
    if self.kind == "gamepad" then
        return self.ctrl:getGamepadAxis("leftx")
    elseif self.kind == "mouse" then
        return 
    end
end

function Controller:getYMovement()
    if self.kind == "gamepad" then
        return self.ctrl:getGamepadAxis("lefty")
    elseif self.kind == "mouse" then
        return 
    end
end

function Controller:getXRotation() --Used to calculate the rotation of the snakes head
    if self.kind == "gamepad" then
        return self.ctrl:getGamepadAxis("rightx")
    end
end

function Controller:getYRotation() --Used to calculate the rotation of the snakes head
    if self.kind == "gamepad" then
        return self.ctrl:getGamepadAxis("righty")
    end
end

setmetatable(Controller, { __call = function(_, ...) return Controller.new(...) end })

local controllerManager = {}
local controllers = {} -- array of controllers

    function controllerManager.addController(kind, playerNum, ...)
        local newController = Controller(kind)
        --Set a specific players controller or add just append the controller
        controllers[playerNum or table.getn(controllers)+1] = newController
        return newController
    end

    function controllerManager.getController(playerNum)
        return controllers[playerNum]
    end

    function controllerManager.getControllerAmount()
        return #controllers
    end

return controllerManager
-- sends out events for all input to the game

local eventmanager = require'engine/eventmanager'
local event = require'engine/event'

local Controller = {}

-- sends an event if a button on a gamepad is pressed
function Controller:joystickpressed(joystick, button)
  BEvent = event:new("ButtonPressEvent")
  BEvent.button = button
  BEvent.joystick = joystick
  eventmanager:sendEvent(BEvent)
  print(button)
end

-- sends an event if a button on a gamepad is released
function Controller:joystickreleased(joystick, button)
  BEvent = event:new("ButtonReleaseEvent")
  BEvent.button = button
  BEvent.joystick = joystick
  eventmanager:sendEvent(BEvent)
end

-- ditto above, for keys
function Controller:keypressed(key, isrepeat)
  KEvent = event:new("KeyPressedEvent")
  KEvent.key = key
  KEvent.isrepeat = isrepeat
  eventmanager:sendEvent(KEvent)
end

function Controller:keyreleased(key, isrepeat)
  KEvent = event:new("KeyReleasedEvent")
  KEvent.key = key
  KEvent.isrepeat = isrepeat
  eventmanager:sendEvent(KEvent)
end

-- returns the point on screen the mouse was pressed
function Controller:mousepressed(x, y, button)
  MEvent = event:new("MousePressedEvent")
  MEvent.x = x
  MEvent.y = y
  MEvent.button = button
  eventmanager:sendConsumableEvent(MEvent)
end

-- ditto above for released
function Controller:mousereleased(x, y, button)
  MEvent = event:new("MouseReleasedEvent")
  MEvent.x = x
  MEvent.y = y
  MEvent.button = button
  eventmanager:sendEvent(MEvent)
end

-- sends an event when a joystick axis changes
function Controller:joystickaxis(joystick, axis, value)
  local AEvent = event:new("ControllerAxisEvent")
  AEvent.joystick = joystick
  AEvent.axis = axis
  AEvent.value = value
  eventmanager:sendEvent(AEvent)
end

return Controller
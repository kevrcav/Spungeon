local eventmanager = require'eventmanager'
local event = require'event'

local Controller = {}

function Controller:joystickpressed(joystick, button)
  BEvent = event:new("ButtonPressEvent")
  BEvent.button = button
  BEvent.joystick = joystick
  eventmanager:sendEvent(BEvent)
  print(button)
end

function Controller:joystickreleased(joystick, button)
  BEvent = event:new("ButtonReleaseEvent")
  BEvent.button = button
  BEvent.joystick = joystick
  eventmanager:sendEvent(BEvent)
end


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

function Controller:mousepressed(x, y, button)
  MEvent = event:new("MousePressedEvent")
  MEvent.x = x
  MEvent.y = y
  MEvent.button = button
  eventmanager:sendConsumableEvent(MEvent)
end

function Controller:mousereleased(x, y, button)
  MEvent = event:new("MouseReleasedEvent")
  MEvent.x = x
  MEvent.y = y
  MEvent.button = button
  eventmanager:sendEvent(MEvent)
end

function Controller:joystickaxis(joystick, axis, value)
  local AEvent = event:new("ControllerAxisEvent")
  AEvent.joystick = joystick
  AEvent.axis = axis
  AEvent.value = value
  eventmanager:sendEvent(AEvent)
end

return Controller
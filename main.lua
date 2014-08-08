World = require'world'
Controller = require'controller'

function love:load()
  World:load()
end

function love:draw()
  World:draw()
end

function love.update(dt)
  World:update(dt)
end

function love:quit()
  World:quit()
end

love.keypressed = function (key, isrepeat)
  Controller:keypressed(key, isrepeat)
end

love.keyreleased = function (key, isrepeat)
  Controller:keyreleased(key, isrepeat)
end

love.joystickpressed = function (joystick, button)
  Controller:joystickpressed(joystick, button)
end

love.joystickreleased = function (joystick, button)
  Controller:joystickreleased(joystick, button)
end

love.joystickaxis = function (joystick, axis, value)
  Controller:joystickaxis(joystick, axis, value)
end

love.mousepressed = function (x, y, button)
  Controller:mousepressed(x, y, button)
end

love.mousereleased = function (x, y, button)
  Controller:mousereleased(x, y, button)
end
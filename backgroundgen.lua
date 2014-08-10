local constants = require 'constants'
local backgroundgen = {}

function backgroundgen:makeStars()
  local space = love.graphics.newCanvas()
  love.graphics.setCanvas(space)
  space:clear(0, 0, 0, 255)
  love.graphics.setColor(255, 255, 255)
  for i=0,20 do
    local size = math.random(10)+5
    love.graphics.rectangle('fill', math.random(constants.WIDTH), math.random(constants.HEIGHT), size, size)
  end
  love.graphics.setCanvas()
  return space
end

return backgroundgen

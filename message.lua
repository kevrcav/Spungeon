local drawmanager = require 'drawmanager'
local eventmanager = require 'engine/eventmanager'
local listener = require 'engine/listener'
local vector = require 'engine/vector'
local message = {words = '', center = vector:vect0(), maxwidth = 0, color={r=0, g=0, b=0}}

function message:new(words, center, maxwidth, color)
  local o = {words = words, center = center, maxwidth = maxwidth, color=color}
  setmetatable(o, self)
  self.__index = self
  return o
end

function message:registerDraw()
  drawmanager:registerdrawable(2, self)
end

function message:removeDrawListener()
  eventmanager:removeListenersForObject(self)
end

function message:draw()
  local currentcolor={love.graphics.getColor()}
  love.graphics.setColor(125, 125, 125, 200)
  love.graphics.rectangle('fill', self.center.x, self.center.y - 20, self.maxwidth+20, 100)
  love.graphics.setColor(self.color.r, self.color.g, self.color.b)
  love.graphics.printf(self.words, self.center.x, self.center.y, self.maxwidth, 'center')
  love.graphics.setColor(currentcolor[1], currentcolor[2], currentcolor[3], currentcolor[4])
end

return message

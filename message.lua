local eventmanager = require 'eventmanager'
local listener = require 'listener'
local vector = require 'vector'
local message = {words = '', center = vector:vect0(), maxwidth = 0, color={r=0, g=0, b=0}}

function message:new(words, center, maxwidth, color)
  local o = {words = words, center = center, maxwidth = maxwidth, color=color}
  setmetatable(o, self)
  self.__index = self
  return o
end

function message:addDrawListener()
  eventmanager:addListener('DrawEvent', listener:new(self, self.draw))
end

function message:removeDrawListener()
  eventmanager:removeListenersForObject(self)
end

function message:draw()
  local currentcolor={love.graphics.getColor()}
  love.graphics.setColor(self.color.r, self.color.g, self.color.b)
  love.graphics.printf(self.words, self.center.x, self.center.y, self.maxwidth, 'center')
  love.graphics.setColor(currentcolor[1], currentcolor[2], currentcolor[3], currentcolor[4])
end

return message

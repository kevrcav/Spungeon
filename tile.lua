local drawmanager = require 'drawmanager'
local vector = require 'vector'
local tile = {loc = vector:vect0(), size = vector:vect0()}

function tile:new(x, y, width, height, pixelSize, color)
  local o = {loc = vector:new(x, y), size = vector:new(width, height),
             numberX = math.ceil(width/pixelSize), numberY = math.floor(height/pixelSize),
             pixelSize = pixelSize,
             surface = love.graphics.newCanvas(width, height)}
  setmetatable(o, self)
  self.__index = self
  o.surface:clear(color)
  return o
end

function tile:setPixel(x, y, color)
  love.graphics.setCanvas(self.surface)
  oldColor = {love.graphics.getColor()}
  love.graphics.setColor(color[1], color[2], color[3], color[4])
  love.graphics.rectangle('fill', x*self.pixelSize, y*self.pixelSize, self.pixelSize, self.pixelSize)
  love.graphics.setCanvas()
  love.graphics.setColor(oldColor[1], oldColor[2], oldColor[3], oldColor[4])
end

function tile:setColumn(x, start, size, color)
  for i=start,start+size do
    self:setPixel(x, i, color)
  end
end

function tile:setRow(y, start, size, color)
  for i=start,start+size do
    self:setPixel(i, y, color)
  end
end

function tile:setBox(tl, tr, bl, color)
  for i=tl,tr do
    for j=tl,bl do
      self:setPixel(i, j, color)
    end
  end
end

function tile:registerDraw(layer)
  drawmanager:registerdrawable(layer, self)
end

function tile:draw()
  love.graphics.draw(self.surface, self.loc.x - self.size.x/2, self.loc.y - self.size.y/2)
end

return tile

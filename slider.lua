local HitBox = require'hitbox'[1]
local Vector  = require'vector'

local Slider = {x = 0, y = 0, button = HitBox:new(Vector:vect0(), Vector:vect0()), val = 0.5, size = 100, isGrabbed = false}

function Slider:new(newx, newy, newSize)
  local o = {x = newx-newSize/2, y = newy, button = HitBox:new(Vector:new(newx, newy-5), Vector:new(20, 20)), size = newSize, val=0.5}
  setmetatable(o, Slider)
  self.__index=self
  return o
end

function Slider:update() 
  
  mousePos = Vector:new(love.mouse.getPosition())
  
  if not self.isGrabbed and love.mouse.isDown("l") then
    self.isGrabbed = self.button:detectPoint(mousePos)  
  elseif self.isGrabbed and not love.mouse.isDown("l") then
    self.isGrabbed = false
  end
  if self.isGrabbed then  
    self.val = (mousePos.x-self.x)/self.size
    self.val = math.min(math.max(self.val, 0), 1)
    self.button:moveOverTo(Vector:new(math.max(math.min(mousePos.x, self.x+self.size), self.x), self.y-self.button.size.y/4))
  end
end

function Slider:draw()
  mousePos = Vector:new(love.mouse.getPosition())
  love.graphics.setColor(255, 0, 0)
  love.graphics.rectangle("fill", self.x, self.y-10, self.size, 10)
  love.graphics.setColor(0, 255, 255)
  love.graphics.rectangle("fill", self.button.loc.x-self.button.size.x/2, 
                          self.button.loc.y-self.button.size.y/2, self.button.size.x, self.button.size.y)
end

function Slider:scaleNumber(n)
  return n*self.val
end

return Slider
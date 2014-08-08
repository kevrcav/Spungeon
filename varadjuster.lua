Slider = require'slider'

local Adjuster = {name = "", slider = Slider:new(0, 0, 0), var = 0, initvar = 0}

function Adjuster:new(newx, newy, newsize, newname, newinitvar)
  local o = {name = newname, slider = Slider:new(newx, newy, newsize), initvar = newinitvar}
  o.var = o.slider:scaleNumber(self.initvar)
  setmetatable(o, self)
  self.__index = self
  return o
end

function Adjuster:update()
  self.slider:update()
  self.var = self.slider:scaleNumber(self.initvar)
  return self.var
end

function Adjuster:draw()
  self.slider:draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(self.name, self.slider.x, self.slider.y - 30)
  love.graphics.print(tostring(self.var), self.slider.x + self.slider.size + 10, self.slider.y - 10)
end

return Adjuster
local event = 
{ }

function event:new(type)
  local o = {type = type}
  setmetatable(o, self)
  self.__index = self
  return o
end

return event
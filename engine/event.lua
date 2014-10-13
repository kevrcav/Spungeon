--Event: Assigned string as a type, then it can be assigned any fields needed. 
--Thanks to Lua's lack of type checking, this just acts as a table with a lable.
local event = 
{ }

function event:new(type)
  local o = {type = type}
  setmetatable(o, self)
  self.__index = self
  return o
end

return event
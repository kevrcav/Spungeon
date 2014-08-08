local listener = {}

function listener:new(reference, hook)
  local o = {reference = reference, hook = hook}  
  setmetatable(o, self)
  self.__index = self
  return o
end

function listener:sendEvent(event)
  return self.hook(self.reference, event)
end

return listener
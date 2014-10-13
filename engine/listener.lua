-- Listener that acts as a callback for events
local listener = {}

-- Make a new listener. The reference is the object this is attached to and the hook is the function to be called.
function listener:new(reference, hook)
  local o = {reference = reference, hook = hook}  
  setmetatable(o, self)
  self.__index = self
  return o
end

-- Send the event to the given reference using the given hook.
function listener:sendEvent(event)
  return self.hook(self.reference, event)
end

return listener
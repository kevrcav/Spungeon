-- Event manager:
-- Stores listeners in a map of event types -> listeners for that event. 
local eventmanager = {registeredListeners = {}}

-- register a listener to listen for events of the given type
function eventmanager:registerListener(eventType, listener)
  self.registeredListeners[eventType] = self.registeredListeners[eventType] or {}
  table.insert(self.registeredListeners[eventType], listener)
end

-- send the given event to all listeners of its type
function eventmanager:sendEvent(event)
  if self.registeredListeners[event.type] then
    table.foreach(self.registeredListeners[event.type], function(i, l)
      l:sendEvent(event)
    end)
  end
end

-- Send an event and the first listener to respond will stop sending it to the rest
function eventmanager:sendConsumableEvent(event)
  if self.registeredListeners[event.type] then
    local quitstatus = false
    for i, l in ipairs(self.registeredListeners[event.type]) do
      quitstatus = l:sendEvent(event)
      if quitstatus then 
        return 
      end
    end
  end
end

-- Removes all listeners attached to the given object
function eventmanager:removeListenersForObject(o)
  table.foreach(self.registeredListeners, function(type, listeners)
    local toRemove = {}
    table.foreach(listeners, function(i, listener)
      if listener.reference == o then
        table.insert(toRemove, i)
      end
    end)
    table.foreach(toRemove, function(i, ref)
      table.remove(listeners, ref)
    end)
  end)
end

return eventmanager
local eventmanager = {registeredListeners = {}}

function eventmanager:registerListener(eventType, listener)
  self.registeredListeners[eventType] = self.registeredListeners[eventType] or {}
  table.insert(self.registeredListeners[eventType], listener)
end

function eventmanager:sendEvent(event)
  if self.registeredListeners[event.type] then
    table.foreach(self.registeredListeners[event.type], function(i, l)
      l:sendEvent(event)
    end)
  end
end

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
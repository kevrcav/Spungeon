local collisionmanager = {hitboxes = {}, roamingHitboxes = {}, activeX = 0, activeY = 0}

function collisionmanager:registerHitbox(listener, layer)
  layer = layer or "default"
  self.hitboxes[self.activeX] = self.hitboxes[self.activeX] or {}
  self.hitboxes[self.activeX][self.activeY] = self.hitboxes[self.activeX][self.activeY] or {}
  self.hitboxes[self.activeX][self.activeY][layer] = self.hitboxes[self.activeX][self.activeY][layer] or {}
  table.insert(self.hitboxes[self.activeX][self.activeY][layer], listener)
end

function collisionmanager:registerRoamingHitbox(listener, layer)
  layer = layer or "default"
  self.roamingHitboxes[layer] = self.roamingHitboxes[layer] or {}
  table.insert(self.roamingHitboxes[layer], listener)
end

function collisionmanager:sendEvent(event)
  if self.hitboxes[self.activeX]
 and self.hitboxes[self.activeX][self.activeY]
 and self.hitboxes[self.activeX][self.activeY][event.type] then
    table.foreach(self.hitboxes[self.activeX][self.activeY][event.type], function(i, l)
      l:sendEvent(event)
    end)
  end
end

function collisionmanager:SetActiveRoom(x, y)
  self.activeX = x
  self.activeY = y
end

--[[
function collisionmanager:sendConsumableEvent(event)
  if self.hitboxes[event.type] then
    local quitstatus = false
    for i, l in ipairs(self.registeredListeners[event.type]) do
      quitstatus = l:sendEvent(event)
      if quitstatus then 
        return 
      end
    end
  end
end]]

function collisionmanager:removeListenersForObject(o)
  table.foreach(self.hitboxes, function(type, roomX)
    table.foreach(roomX, function(type, roomY)
      table.foreach(roomY, function(type, label)
        local toRemove = {}
        table.foreach(label, function(i, listener)
          if listener.reference == o then
            table.insert(toRemove, i)
          end
        end)
        table.foreach(toRemove, function(i, ref)
          table.remove(label, ref)
          print("done or something")
        end)
      end)
    end)
  end)
end

return collisionmanager
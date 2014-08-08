local sortedlist = {list = {}}

function sortedlist:new()
  o = {list = {}}
  setmetatable(o, self)
  self.__index = self
  return o
end

function sortedlist:insert(val, x)
  local insertLoc = #self.list+1
  for i,y in ipairs(self.list) do
    if y.val > val then
      insertLoc = i
      break
    end
  end
  table.insert(self.list, insertLoc, {val = val, x = x})
end

function sortedlist:pop(i)
  i = i or 1
  local popped = self.list[i].x
  table.remove(self.list, i)
  return popped
end

function sortedlist:contains(x)
  for i,y in ipairs(self.list) do
    if y.x == x then
      return true
    end
  end
  return false
end

sortedlist.__len = function(x)
  return #x.list
end


return sortedlist

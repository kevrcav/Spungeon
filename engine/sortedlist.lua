-- a sorted list that adds elements using binary-insert
local sortedlist = {list = {}}

-- create a new sorted list
function sortedlist:new()
  o = {list = {}}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- insert a new element into the list at the given value
function sortedlist:insert(val, x)
  print (#self.list)
  if #self.list == 0 then
    table.insert(self.list, {val = val, x = x})
  end
  local intmin = 1
  local intmax = #self.list
  print (intmax)
  local notinserted = true
  while notinserted do
	local searchloc = intmin+math.floor((intmax-intmin)/2)
	local y = self.list[searchloc]
	if not y or y.val == val or intmin > intmax then
		table.insert(self.list, math.max(searchloc, 1), {val = val, x = x})
		notinserted = false
	elseif y.val > val then
		intmin = searchloc+1
	elseif y.val < val then
		intmax = searchloc-1
	end
  end
end

-- take out either the first element or the given element
function sortedlist:pop(i)
  i = i or 1
  local popped = self.list[i].x
  table.remove(self.list, i)
  return popped
end

-- check if the list contains x
function sortedlist:contains(x)
  for i, pair in ipairs(self.list) do
    if pair.x == x then
      return true
    end
  end
  return false
end

-- define the length function as the length of the list
sortedlist.__len = function(x)
  return #x.list
end


return sortedlist

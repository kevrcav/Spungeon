local constants = require 'constants'
local maxHeight = constants.HEIGHT/50
local maxWidth = constants.WIDTH/50
local vector = require 'engine/vector'
local pit = {start = vector:vect0(), size=0, type='', previous=false, next = {}}

function pit:new(x, y, size, type)
  local o = {start = vector:new(x, y), size= size, type = type, previous = false, next = {}, is = 'pit'}
  setmetatable(o, self)
  self.__index = self
  return o
end

function pit:setPrevious(prev)
  self.previous = prev
end

function pit:setNext(next)
  table.insert(self.next, next)
end

function pit:clearOnlyThisPath(blueprint)
   local curHeight = 2--math.random(solver.minTunHeight, solver.maxTunHeight)
  if self.type == 'right' then
    for i=self.start.x,self.start.x+self.size do
      for j=self.start.y-curHeight,self.start.y do
        if blueprint.full[i] and j ~= 0 and (i >0 and i<maxWidth-1 or self.start.y-j < 3) then
          blueprint.full[i][j]=nil
        end
      end
    end
    for i=self.start.x,self.start.x+self.size do
      for j=self.start.y, maxHeight do
        if blueprint.full[i] and j ~= 0 and i >0 and i<maxWidth-1 then
          blueprint.full[i][j]='pit'
        end
      end
    end
  elseif self.type == 'left' then
    for i=self.start.x-self.size,self.start.x do
      for j=self.start.y-curHeight,self.start.y do
        if blueprint.full[i] and j ~= 0 and (i >0 and i<maxWidth-1 or self.start.y-j < 3) then
          blueprint.full[i][j]=nil
        end
      end
    end
    for i=self.start.x-self.size,self.start.x do
      for j=self.start.y, maxHeight do
        if blueprint.full[i] and j ~= 0 and i >0 and i<maxWidth-1 then
          blueprint.full[i][j]='pit'
        end
      end
    end
  end
end

function pit:clearPath(blueprint)
  self:clearOnlyThisPath(blueprint)
  for i,path in ipairs(self.next) do
    path:clearPath(blueprint)
  end
end

function pit.makePitSection(solver, path)
  if path.type == 'up' or path.type == 'down' then return end
  local newpath = pit:new(path.start.x, path.start.y, path.size, path.type)
  if path.previous then
    newpath:setPrevious(path.previous)
    local toRemove = 0
    for i,npath in ipairs(path.previous.next) do
      if path == npath then
        toRemove = i
      end
    end
    table.remove(path.previous.next, toRemove)
    newpath.previous:setNext(newpath)
  end
  for i,npath in ipairs(path.next) do
    npath:setPrevious(newpath)
    newpath:setNext(npath)
  end
  return true
end

return pit
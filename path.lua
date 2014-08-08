local constants = require 'constants'
local vector = require 'vector'
local maxHeight = constants.HEIGHT/50
local maxWidth = constants.WIDTH/50

local pathSection = {start = vector:vect0(), size = vector:vect0(), previous = nil, next = {}, is = 'path'}

function pathSection:new(x, y, s, type)
  local o = {start = vector:new(x, y), size = s, type = type, next = {}}
  setmetatable(o, self)
  self.__index = self
  return o
end

function pathSection:setPrevious(path)
  self.previous = path
end

function pathSection:setNext(path)
  table.insert(self.next, path)
end

function pathSection:clearPath(blueprint)
  self:clearOnlyThisPath(blueprint)
  for i,path in ipairs(self.next) do
    path:clearPath(blueprint)
  end
end

function pathSection:clearOnlyThisPath(blueprint)
  local curHeight = 2--math.random(solver.minTunHeight, solver.maxTunHeight)
  if self.type == 'right' then
    for i=self.start.x,self.start.x+self.size do
      for j=self.start.y-curHeight,self.start.y+1 do
        if blueprint.full[i] and j ~= 0 and (i >0 and i<maxWidth-1 or self.start.y-j < 3) then
          blueprint.full[i][j]=nil
        end
      end
      curHeight = 2--math.max(math.min(curHeight+math.random(3)-2, solver.maxTunHeight), solver.minTunHeight)
    end
  elseif self.type == 'down' then
    for j=self.start.y,self.start.y+self.size do
      for i=self.start.x-1,self.start.x+2 do
        if blueprint.full[i] and i ~= 0 and (j >0 and j<maxHeight-1 or self.start.x-i < 2) then
          blueprint.full[i][j]=nil
        end
      end
    end
  elseif self.type == 'left' then
    for i=self.start.x-self.size,self.start.x do
      for j=self.start.y-curHeight,self.start.y+1 do
        if blueprint.full[i] and j ~= 0 and (i >0 and i<maxWidth-1 or self.start.y-j < 3) then
          blueprint.full[i][j]=nil
        end
      end
      curHeight = 2--math.max(math.min(curHeight+math.random(3)-2, solver.maxTunHeight), solver.minTunHeight)
    end
  elseif self.type == 'up' then
    for j=self.start.y-self.size,self.start.y do
      for i=self.start.x-1,self.start.x+2 do
        if blueprint.full[i] and i ~= 0 and (j >0 and j<maxHeight-1 or self.start.x-i < 2) then
          blueprint.full[i][j]=nil
        end
      end
    end
  end
end

function pathSection:__tostring(s)
  return self.type..' '..tostring(self.start)..' '..tostring(self.size)
end

return pathSection

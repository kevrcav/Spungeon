local constants = require 'constants'
local maxHeight = constants.HEIGHT/50
local maxWidth = constants.WIDTH/50
local vector = require 'engine/vector'
local wallhall = {start = vector:vect0(), size = 0, type = '', previous = false, next = {}, is = 'wallhall'}

function wallhall:new(x, y, size, type)
  local o = {start = vector:new(x, y), size= size, type = type, previous = false, next = {}}
  setmetatable(o, self)
  self.__index = self
  return o
end

function wallhall:setPrevious(prev)
  self.previous = prev
end

function wallhall:setNext(next)
  table.insert(self.next, next)
end

function wallhall:clearPath(blueprint)
  self:clearOnlyThisPath(blueprint)
  for i,path in ipairs(self.next) do
    path:clearPath(blueprint)
  end
end

function wallhall:clearOnlyThisPath(blueprint)
  local curHeight = 4--math.random(solver.minTunHeight, solver.maxTunHeight)
  if self.type == 'right' then
    for i=self.start.x,self.start.x+self.size do
      for j=self.start.y-curHeight,self.start.y+1 do
        if blueprint.full[i] and j ~= 0 and (i >0 and i<maxWidth-1 or self.start.y-j < 3) then
          blueprint.full[i][j]=nil
        end
      end
      curHeight = 4--math.max(math.min(curHeight+math.random(3)-2, solver.maxTunHeight), solver.minTunHeight)
    end
    blueprint.col[self.start.x+math.floor(self.size/2)][self.start.y+1] = 'right'
    blueprint.col[self.start.x+math.floor(self.size/2)][self.start.y]   = 'right'
    blueprint.col[self.start.x+math.floor(self.size/2)][self.start.y-1] = 'right'
    blueprint.col[self.start.x+math.floor(self.size/2)][self.start.y-2] = 'right'
    blueprint.row[self.start.x+math.floor(self.size/2)][self.start.y-3] = 'bottom'
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
      curHeight = 4--math.max(math.min(curHeight+math.random(3)-2, solver.maxTunHeight), solver.minTunHeight)
    end
    blueprint.col[self.start.x-math.floor(self.size/2)][self.start.y+1] = 'left'
    blueprint.col[self.start.x-math.floor(self.size/2)][self.start.y]   = 'left'
    blueprint.col[self.start.x-math.floor(self.size/2)][self.start.y-1] = 'left'
    blueprint.col[self.start.x-math.floor(self.size/2)][self.start.y-2] = 'left'
    blueprint.row[self.start.x-math.floor(self.size/2)][self.start.y-3] = 'bottom'
  elseif self.type == 'up' then
    for j=self.start.y-self.size,self.start.y do
      for i=self.start.x-1,self.start.x+2 do
        if blueprint.full[i] and i ~= 0 and (j >0 and j<maxHeight-1 or self.start.x-i < 2) then
          blueprint.full[i][j]=nil
        end
      end
    end  
    blueprint.row[self.start.x-1][self.start.y-self.size] = 'bottom'
    blueprint.full[self.start.x-1][self.start.y-self.size] = 'occupied'
    blueprint.row[self.start.x+1][self.start.y-self.size] = 'bottom'
    blueprint.full[self.start.x+1][self.start.y-self.size] = 'occupied'
    blueprint.row[self.start.x+2][self.start.y-self.size] = 'bottom'
    blueprint.full[self.start.x+2][self.start.y-self.size] = 'occupied'
  end
end

function wallhall.makeWallSection(solver, path)
  if (path.type == 'up' or path.type == 'down') and path.size < 3 or path.size < 4 then return end
  local newpath = wallhall:new(path.start.x, path.start.y, path.size, path.type)
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

return wallhall

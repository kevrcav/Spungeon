local collisionmanager = require 'engine/collisionmanager'
local eventmanager = require 'engine/eventmanager'
local listener = require 'engine/listener'
local HitTri = require'engine/hittriangle'
local Vector = require'engine/vector'

function vect0() return Vector:new(0, 0) end

--[[A hit box is defined by a point vector and a size vector.
	Its hit detection is done by splitting it into two triangles.
  ]]

local HitBox = {loc = vect0(), size = vect0(), points = {}, parent = nil}

-- create a new hitbox
function HitBox:new(newLoc, newSize, parent)
  local o = {loc = newLoc, size = newSize, points = self:makeCorners(newLoc, newSize), parent = parent}
  setmetatable(o, self)
  o.maxDist = math.sqrt((newSize.x/2)^2+(newSize.y/2)^2)
  self.__index = self
  return o
end

-- register this hitbox in the collision manager
function HitBox:registerListener()
  collisionmanager:registerHitbox(listener:new(self, self.ObjectCollide))
end

-- create the four corners used for hit detection
function HitBox:makeCorners(loc, size)
  local left, right = loc.x - size.x/2, loc.x + size.x/2
  local top, bottom = loc.y - size.y/2, loc.y + size.y/2
  return {Vector:new(left, top),
          Vector:new(left, bottom),
          Vector:new(right, top),
          Vector:new(right, bottom)}
end

-- Collide with another object that has a collision body
function HitBox:ObjectCollide(event)
  if event.body ~= self and self:boxCollide(event.body) then
    if self.parent and self.parent.hitboxCallback then
      self.parent:hitboxCallback(event)
    else
      print("This didn't do anything when it collided")
    end
  end
end

-- move this by the given distance
function HitBox:move(v)
  for i,p in ipairs(self.points) do
    p:addm(v)
  end
  self.loc:addm(v)
end

-- move this object by the given distance... backwards! (I have no idea why this isn't just move. 
-- TODO: remove this silly function
function HitBox:moveBack(v)
  for i,p in ipairs(self.points) do
    p:subm(v)
  end
  self.loc:subm(v)
end

-- Move this to a specific point
function HitBox:moveOverTo(point)
  self:move(Vector:sub(point, self.loc))
end

-- detects if the point is within the hit box (relatively) quickly
function HitBox:detectPoint(point)
  return HitTri:detectPoint(self.points[1], self.points[2], self.points[3], point)
      or HitTri:detectPoint(self.points[2], self.points[3], self.points[4], point)
end

-- move the given hitbox along the given velocity up to the side of this
-- then return the side that the point was moved to.
-- left = 1, top = 2, right = 3, bottom = 4
-- moveTo : HitBox + Vector -> int
function HitBox:moveTo(point, vel)
  local xSide = Vector:determineDir(Vector:sub(point.loc, self.loc), Vector:new(1, 0))
  local ySide = Vector:determineDir(Vector:sub(point.loc, self.loc), Vector:new(0, 1))
  local xWall = self.loc.x + self.size.x / 2 * xSide
  local yWall = self.loc.y + self.size.y / 2 * ySide
  local xT = (xWall - (point.loc.x - point.size.x/2*xSide)) / vel.x
  local yT = (yWall - (point.loc.y - point.size.y/2*ySide)) / vel.y
  -- moving along the top
  if (tostring(yT) == tostring(0/0) or tostring(yT) == tostring(-(0/0)))
  and (point.loc.y+point.size.y/2<=self.loc.y-self.size.y/2
    or point.loc.y-point.size.y/2>=self.loc.y+self.size.y/2) then
    point:move(vel)
    return ySide + 3
  elseif (tostring(xT) == tostring(0/0) or tostring(xT) == tostring(-(0/0)))
    and not (point.loc.x+point.size.x/2>=self.loc.x-self.size.x/2
        and  point.loc.x-point.size.x/2<=self.loc.x+self.size.x/2) then
    point:move(vel)
    return xSide + 2
  end
  if (xT < yT and yT >= 0 and xT >=0) or yT < -0.1 then
    point:moveOverTo(Vector:new(xWall + point.size.x / 2 * xSide, point.loc.y + vel.y))
    return xSide + 2
  elseif (yT <= xT and yT >=0 and xT >= 0) or xT < 0  or tostring(xT) == tostring(0/0) then
    point:moveOverTo(Vector:new(point.loc.x + vel.x, 
                                yWall + point.size.y / 2 * ySide))
    return ySide + 3
  else
    point:moveOverTo(Vector:new(xWall + point.size.x / 2 * xSide,
                                yWall + point.size.y / 2 * ySide))
  end
  return 0
end

-- tests if any of these points are within the given hit box
function HitBox:anyPointWithin(hb)
  for i, p in ipairs(self.points) do
    if hb:detectPoint(p) then 
      return true
    end
  end
  return false
end

-- tests if this box collides with the given box
function HitBox:boxCollide(hb)
  return self:CanCollide(hb)
     and (self:anyPointWithin(hb)
      or hb:anyPointWithin(self)
      or self:cornLessIntersect(hb))
end

-- tests if this box has any chance to collide with the given hitbox
function HitBox:CanCollide(hb)
  return self.loc:distance(hb.loc) <= self.maxDist + hb.maxDist
end

-- tests if the two boxes intersect without corners intersecting
function HitBox:cornLessIntersect(hb)
  return self:horzIntersect(hb)
      or hb:horzIntersect(self)
end

-- returns if this intersects horizontally with the given box
function HitBox:horzIntersect(hb)
  topLeft = self.points[1]
  bottomLeft = self.points[2]
  topRight = self.points[3]
  otherBot = hb.loc.y+hb.size.y/2
  otherTop = hb.loc.y-hb.size.y/2
  otherLeft = hb.loc.x-hb.size.x/2
  otherRight = hb.loc.x+hb.size.x/2
  return bottomLeft.y < otherBot
     and topLeft.y > otherTop
     and topLeft.x < otherRight
     and topRight.x > otherLeft
end

-- NoBottom: A platform that only has a collider on the top.
-- Not actually used at this point, consider removing.
function createNoBottom()
  local NoBottom = {}
  
  function NoBottom:new(newLoc, newSize, parent)
    local o = {loc = newLoc, size = newSize, points = self:makeCorners(newLoc, newSize)}
    o.parent = parent
    setmetatable(o, self)
    o.maxDist = math.sqrt((newSize.x/2)^2+(newSize.y/2)^2)
    self.__index = self
    return o
  end
  
  if HitBox then
    setmetatable(NoBottom, { __index = HitBox })
  end
  
  return NoBottom
end

local NoBottom = createNoBottom()

function NoBottom:moveTo(point, vel)
  if point.loc.y + point.size.y/2 <= self.loc.y - self.size.y/2 then
    point:moveOverTo(Vector:new(point.loc.x + vel.x,
                                self.loc.y - point.size.y/2 - self.size.y/2))
    return 2
  else
    point:move(vel)
    return 0
  end
end

return HitBox
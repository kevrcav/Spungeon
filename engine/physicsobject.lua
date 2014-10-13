local collisionmanager = require 'engine/collisionmanager'
local listener = require 'engine/listener'
local eventmanager = require 'engine/eventmanager'
local event = require 'engine/event'
local Vector = require'engine/vector'
local HitBox = require'engine/hitbox'

vect0 =  Vector.vect0

-- A physics object that follows very simple, purely non-rotational kinematic physics.
local PObject = {v = vect0(), a = vect0(), loc = vect0(), size = vect0(), accelsleep = 0}

-- the Physics Object is also a hitbox.
setmetatable(PObject, { __index = HitBox })

-- create a new physics object
function PObject:new(nx, nv, na, size, parent)
  local o = {v = nv, a = na, loc = nx, size = size, points = self:makeCorners(nx, size), parent = parent, accelsleep = 0}
  setmetatable(o, self)
  self.__index = self
  o.maxDist = math.sqrt((size.x/2)^2 + (size.y/2)^2)
  eventmanager:registerListener("UpdateEvent", listener:new(o, o.update))
  collisionmanager:registerRoamingHitbox(listener:new(o, o.ObjectCollide))
  return o
end

-- returns the first entity this collides with, if none returns nil
function PObject:firstCollide(entities)
  for i, e in ipairs(entities) do
    if e.body.col:boxCollide(self.col) then
      return e
    end
  end
end

-- move this object and check to see if it's collided with anything
function PObject:update(event)
  if self.accelsleep > 0 then
    self.accelsleep = self.accelsleep - event.dt
  else
    self.v:addm(Vector:multc(self.a, event.dt))
  end
  move = Vector:multc(self.v, event.dt)
  self:move(move)
  sideHits = {}
  self.onGround = false
  self.onWall = 0
  self.sidesCollided = {}
  MEvent = event:new("default")
  MEvent.body = self
  MEvent.move = move
  collisionmanager:sendEvent(MEvent)
  --[[for i, sideHit in ipairs(sideHits) do
    if sideHit == 1 or sideHit == 3 then
      self.v = Vector:new(0.01*self.v.x, self.v.y)
    elseif sideHit == 2 or sideHit == 4 then
      if math.abs(self.a.x)<100 or self.a.x*self.v.x < 0 then
        self.v = Vector:new(constants.FRICTION*self.v.x, 0.01*self.v.y)
      else
        self.v = Vector:new(self.v.x, 0.01*self.v.y)
      end
    end
  end]]
end

-- set the horizontal acceleration
function PObject:setXA(newXA)
  self.a.x = newXA*constants.ACCELERATION
end

-- set the vertical acceleration
function PObject:setYA(newYA)
  self.a.y = newYA*constants.ACCELERATION
end

-- Ignore all forces (forces being equal to accel because mass=1) being applied to this
function PObject:ignoreAccel(t)
  self.accelsleep = t
end
  
return PObject
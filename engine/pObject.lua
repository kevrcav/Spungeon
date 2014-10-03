local collisionmanager = require 'collisionmanager'
local listener = require 'listener'
local eventmanager = require 'eventmanager'
local event = require 'event'
local Vector = require'vector'
local HitBoxF = require'hitbox'
local HitBox = HitBoxF[1]
local constants = require'constants'

vect0 =  Vector.vect0

local PObject = {v = vect0(), a = vect0(), loc = vect0(), size = vect0(), accelsleep = 0}

setmetatable(PObject, { __index = HitBox })

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

function PObject:update(event)
  if self.accelsleep > 0 then
    self.accelsleep = self.accelsleep - event.dt
  else
    self.v:addm(Vector:multc(self.a, event.dt))    
    if self.onGround then
      if self.v.x > constants.MAX_SPEED then self.v.x = constants.MAX_SPEED end
      if self.v.x < -constants.MAX_SPEED then self.v.x = -constants.MAX_SPEED end
    else
      if self.v.x > constants.MAX_AIR_SPEED then self.v.x = constants.MAX_AIR_SPEED end
      if self.v.x < -constants.MAX_AIR_SPEED then self.v.x = -constants.MAX_AIR_SPEED end
    end
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

function PObject:setXA(newXA)
  self.a.x = newXA*constants.ACCELERATION
end

function PObject:setYA(newYA)
  self.a.y = newYA*constants.ACCELERATION
end

function PObject:ignoreAccel(t)
  self.accelsleep = t
end

function PObject:draw() end
  
return PObject
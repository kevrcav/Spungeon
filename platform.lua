local event = require 'engine/event'
local eventmanager = require 'engine/eventmanager'
local powerup = require 'powerup'
local Vector = require'engine/vector'
local Hitbox = require'engine/hitbox'

local Platform = {
  colBody =  Hitbox:new(Vector.vect0(), Vector.vect0()), 
  color = {0, 0, 0}, 
  toDelete = false, 
  removable = true
}

function Platform:load() end

function Platform:new(loc, size, r, g, b)
  local o = {colBody = Hitbox:new(loc, size), color = {r, g, b}}
  o.colBody.parent = o
  o.type = "fill"
  setmetatable(o, self)
  self.__index = self
  return o
end

function Platform:registerListener()
  self.colBody:registerListener()
end

function Platform:newBottomless(loc, size, r, g, b)
  o = {colBody = NoBottom:new(loc, size), color = {r, g, b}}
  o.colBody.parent = o
  o.type = "line"
  setmetatable(o, self)
  self.__index = self
  return o
end

function Platform:hitboxCallback(event)
    event.body:moveBack(event.move)
    local sideHit = self.colBody:moveTo(event.body, event.move)
    if sideHit == 1 or sideHit == 3 then
      local yfriction = 1
      if event.move.y > 0 then yfriction = 0.8 end
      if event.body.accelsleep <= 0 then
        event.body.v = Vector:new(0.01*event.body.v.x, event.body.v.y*yfriction)
      end
      if event.body.size.y < self.colBody.size.y then
        event.body.onWall = sideHit
      end
      event.body.hit = true
    elseif sideHit == 2 or sideHit == 4 then
      if event.body.accelsleep <= 0 then
        if math.abs(event.body.a.x)<100 then
          event.body.v = Vector:new(constants.FRICTION*event.body.v.x, 0.01*event.body.v.y)
        else
          event.body.v = Vector:new(event.body.v.x, 0.01*event.body.v.y)
        end
    end
      if sideHit == 2 then
        event.body.onGround = true
        event.body.lastPlatform = self
        lpevent = event:new('PlatformTouchedEvent')
        lpevent.platform = self
        eventmanager:sendEvent(lpevent)
        event.body.hit = true
      end
    end
end

function Platform:collide(body)
  return self.active and self.colBody:boxCollide(body)
end

function Platform:moveTo(body, move)
  movedBody = Hitbox:new(body.loc+move, body.size)
  if self.colBody:boxCollide(movedBody) then
    return self.colBody:moveTo(body, move)
  end
  return 0
end

function Platform:draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle('line', self.colBody.loc.x - self.colBody.size.x/2,
                                  self.colBody.loc.y - self.colBody.size.y/2,
                                  self.colBody.size.x, 
                                  self.colBody.size.y)
  love.graphics.setColor(self.color[1], self.color[2], self.color[3])
  love.graphics.rectangle(self.type, self.colBody.loc.x - self.colBody.size.x/2,
                                  self.colBody.loc.y - self.colBody.size.y/2,
                                  self.colBody.size.x, 
                                  self.colBody.size.y)
end

return Platform

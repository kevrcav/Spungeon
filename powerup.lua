local collisionmanager = require 'engine/collisionmanager'
local event = require 'engine/event'
local eventmanager = require 'engine/eventmanager'
constants = require'constants'
Hitbox = require'engine/hitbox'
Vector = require'engine/vector'

-- a powerup has a body, a name, and knows if it's grabbed
local powerup = {body = Hitbox:new(Vector:vect0(), Vector:vect0()), isGrabbed = false, name = ""}

function powerup:addEffect(player)
end

-- draw a powerup
function powerup:draw()
  love.graphics.setColor(255, 0, 255)
  love.graphics.rectangle("fill", self.body.loc.x-self.body.size.x/2,
                                   self.body.loc.y-self.body.size.y/2,
                                   self.body.size.x, self.body.size.y)
  love.graphics.setColor(0, 0, 0)
  love.graphics.printf(self.name, self.body.loc.x-self.body.size.x/2, self.body.loc.y-self.body.size.y/3, self.body.size.x, 'center')
end

-- name a new powerup type
function powerup:newTemplate(powername, message)
  o = {name = powername, message = message or ''}
  setmetatable(o, self)
  self.__index = self
  return o
end

function powerup:hitboxCallback(event)
  if event.body.parent.isPlayer then
    self:addEffect(event.body.parent)
    event.body.parent.collectedPUps[#event.body.parent.collectedPUps+1] = self
    collisionmanager:removeListenersForObject(self.body)
    PEvent = event:new("RemovePowerupFromRoomEvent")
    PEvent.powerup = self
    eventmanager:sendEvent(PEvent)
  end
end

function powerup:registerListener()
  self.body:registerListener()
end

-- instantiate a new powerup
function powerup:new(loc)
  local o = {body = Hitbox:new(loc, Vector:new(50, 50), self), name = self.name, message = self.message}
  o.body.parent = o
  setmetatable(o, self)
  self.__index = self
  return o
end

function powerup:addMessage()
  local mevent = event:new("AddMessageEvent")
  mevent.owner = self
  mevent.message = self.message
  eventmanager:sendEvent(mevent)
end

-- the super jump powerup
local superJump = powerup:newTemplate("Double Jump", "Wow, the double jump! Now your jumps are double. Wait, that's not right. Again! You can jump again. In the air. By pressing space or A button.")

-- the super jump effect
function superJump:addEffect(player)
  player.DoubleJump = true
  self:addMessage()
end

-- map powerup and effect
local map = powerup:newTemplate("Map", "Neeto, the map! Now you know the whole layout of the \"Spungeon\" (portmanteou of Space Dungeon. Just a little wordplay ;)) It's too bad this doesn't let you see the items, though...")

function map:addEffect(player)
  constants.HASMAP = true
  self:addMessage()
end

-- compass powerup and effect
local compass = powerup:newTemplate("Compass", "The compass! Now you can see where the items are! BLAPPO! ...But I guess it would be more useful if you actually knew how to get there. Maybe you do! I dunno!")

function compass:addEffect(player)
  constants.HASCOMPASS = true
  self:addMessage()
end

local dash = powerup:newTemplate("Dash", "Now here's a cool thing. Dashing! You can dash left or right at the touch of a button. The X key for left and the C key for right, or the controller's bumpers for their respective directions."..
                                          "\nBy the way! You can dash in the air or on the ground, but you'll need to touch a wall or the ground before you can dash again.")

function dash:addEffect(player)
  player.hasDash = true
  self:addMessage()
end

local bestthing = powerup:newTemplate("The Best Thing", "You did it! You found the best thing!\n\n...Which means you can go. If you ever want to visit again, you can close the game and start it up again.\nBe warned though: I love to remodel!")

return {powerup, superJump, map, compass, dash, bestthing}
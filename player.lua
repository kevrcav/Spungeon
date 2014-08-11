local drawmanager = require 'drawmanager'
local pObject = require'pObject'
local Vector = require'vector'
local Hitbox = require'hitbox'
local constants = require'constants'
local eventmanager = require'eventmanager'
local listener = require'listener'
local event = require'event'
vect0=Vector.vect0

local Player = {
  body=nil, 
  collectedPUps = {},
  isActive = true, 
  toDelete = false,
  deltaX = 0
}

function Player:new(x, coVars)
  local o = {body = pObject:new(x, vect0(), Vector:new(0, constants.INIT_GRAVITY), Vector:new(20, 30)), lastDash = 0}
  o.body.parent = o
  setmetatable(o, self)
  self.__index = self
  o.isPlayer = true
  o.fallofftime = 0
  eventmanager:registerListener("ButtonPressEvent", listener:new(o, o.jumped))
  eventmanager:registerListener("ControllerAxisEvent", listener:new(o, o.updateXCallback))
  eventmanager:registerListener("UpdateEvent", listener:new(o, o.update))
  eventmanager:registerListener("KeyPressedEvent", listener:new(o, o.keyPressed))
  eventmanager:registerListener("KeyReleasedEvent", listener:new(o, o.keyReleased))
  self:registerDraw()
  return o
end

function Player:load()
end  

function Player:registerDraw()
  drawmanager:registerplayerdrawable(10, self)
end

function Player:draw()
  if self.body.a.x < 0 then 
    rot = -1
  else
    rot = 1
  end
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", self.body.loc.x - self.body.size.x/2,
                                    self.body.loc.y - self.body.size.y/2,
                                    self.body.size.x, 
                                    self.body.size.y)
end

function Player:jumped(event)
  if event.button == 9 then
    self:dash(-1)
  elseif event.button == 10 then
    self:dash(1)
  end
  if not (event.button == 11 or event.key == ' ') then return end
  if self.body.onGround then
    self.body.v.y = -constants.JUMP_HEIGHT
    self.notDoubleJumped = true
  elseif self.body.onWall == 1 then
    self.body.v.y = -constants.JUMP_HEIGHT*math.sin(constants.WALL_JUMP_ANGLE*2*math.pi/360)
    self.body.v.x = -constants.JUMP_HEIGHT*math.cos(constants.WALL_JUMP_ANGLE*2*math.pi/360)
    self.notDoubleJumped = true
  elseif self.body.onWall == 3 then
    self.body.v.y = -constants.JUMP_HEIGHT*math.sin(constants.WALL_JUMP_ANGLE*2*math.pi/360)
    self.body.v.x = constants.JUMP_HEIGHT*math.cos(constants.WALL_JUMP_ANGLE*2*math.pi/360)
    self.notDoubleJumped = true
  elseif self.DoubleJump and self.notDoubleJumped then
    self.body.v.y = -constants.JUMP_HEIGHT
    self.notDoubleJumped = false
  end
end

function Player:updateXCallback(event)
  if event.axis ~= 1 then return end
  self:updateX(event.value)
end

function Player:updateX(x)
  self.deltaX = x
  if math.abs(self.deltaX) < 0.1 then self.deltaX = 0 end
end

function Player:keyPressed(event)
  if event.key == 'left' then
    self:updateX(-1)
  end
  if event.key == 'right' then
    self:updateX(1)
  end
  if event.key == ' ' then
    self:jumped(event)
  end
  if event.key == 'c' then
    self:dash(1)
  end
  if event.key == 'x' then
    self:dash(-1)
  end
end

function Player:keyReleased(event)
  if event.key == 'left' and self.deltaX < 0 then
    self.deltaX = 0
  end
  if event.key == 'right' and self.deltaX > 0 then
    self.deltaX = 0
  end
end

function Player:dash(dir)
  if not self.hasDash or self.dashed or love.timer.getTime() - self.lastDash < 0.5 then return end
  self.lastDash = love.timer.getTime()
  self.body.v.x = 800*dir
  self.body.v.y = 0
  self.body:ignoreAccel(0.25)
  self.dashed = true
end

function Player:update(event)
  self.body:setXA(self.deltaX)
  if self.deltaX * self.body.v.x < 0 and self.body.accelsleep <= 0 then
    self.body.v.x = self.body.v.x*0.9
  end
  if self.body.onGround or self.body.onWall > 0 then
    self.notDoubleJumped = true
    self.dashed = false
  end
  if self:checkForDeath() then
    eventmanager:sendEvent(event:new("TransitionPlayerEvent"))
  end
  return
end

function Player:checkPowerups(powerups)
  table.foreach(powerups, function(i, p) 
    if p.body:boxCollide(self.body.col) then
      p.isGrabbed = true
      self.collectedPUps[#self.collectedPUps] = p
      p:addEffect(self)
    end
  end)
end

function Player:reset()
  self.isActive = true
  self.body = pObject:new(Vector:new(450, 100), vect0(), Vector:new(0, 980), self.body.col.size)
end

function Player:checkForDeath()
  return self.body.loc.y < 0
      or self.body.loc.y > constants.HEIGHT
      or self.body.loc.x > constants.WIDTH
      or self.body.loc.x < 0
end

return Player
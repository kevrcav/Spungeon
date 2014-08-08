local constants = require 'constants'
local message = require 'message'
local listener = require 'listener'
local eventmanager = require 'eventmanager'
local collisionmanager = require 'collisionmanager'
PlatFile = require'platform'
Platform = PlatFile[1]
DPlat = PlatFile[2]
Vector = require'vector'
constants = require'constants'
vect0 = Vector.vect0

Room = {platforms = {}, 
        enemies = {}, 
        powerups = {},
        messages = {},
        x = 0, y = 0, 
        numberDoors = 0}

function Room:new(newX, newY)
  local o = {platforms = {}, enemies = {}, powerups = {}, messages = {}, x = newX, y = newY,
             hasLeftDoor = false, hasRightDoor = false, hasTopDoor = false, hasBottomDoor = false, visited = false,
             numberDoors = 0}
  setmetatable(o, self)
  self.__index = self
  --o:setWall("right")
  --o:setWall("left")
  --o:setWall("top")
  --o:setWall("bottom")
  eventmanager:registerListener("RemovePowerupFromRoomEvent", listener:new(o, o.RemovePowerup))
  return o
end

function Room:setPlatform(loc, size, color, platType)
  platType = platType or "solid"
  if platType=="bottomless" then
    table.insert(self.platforms, Platform:newBottomless(loc, size, color[1], color[2], color[3]))
  elseif platType=="solid" then
    table.insert(self.platforms, Platform:new(loc, size, color[1], color[2], color[3]))
  end
end

function Room:addPowerup(powerup)
  self.powerups[#self.powerups+1]=powerup
  self.hasPowerup = true
end

function Room:RemovePowerup(event)
  local pToRemove = nil
  for i,p in ipairs(self.powerups) do
    if p == event.powerup then
      pToRemove = i
    end
  end
  if pToRemove then
    print(self.powerups[pToRemove].message)
    self:addMessage(message:new(self.powerups[pToRemove].message, vector:new(constants.WIDTH/4, constants.HEIGHT/2), constants.WIDTH/2))
    table.remove(self.powerups, pToRemove)
  end
end

function Room:addMessage(message)
  table.insert(self.messages, message)
end

--update the room by checking for dead powerups
function Room:update()
end

-- draw each platform and powerup
function Room:draw()
  table.foreach(self.platforms, function(k, p) p:draw() end)
  table.foreach(self.powerups, function(k, p) p:draw() end)
  table.foreach(self.messages, function(k, m) m:draw() end)
end

-- draw the room small, checking if this is active, the player has the map, 
-- if this has a powerup and if the player has a compass
function Room:drawSmall(offsetx, offsety, scale, active)
  collisionmanager:SetActiveRoom(self.x, self.y)
  love.graphics.setColor(0, 0, 0)
  if active then
    love.graphics.setColor(255,0,0)
  elseif self.visited then
    love.graphics.setColor(0, 200, 0)
  end
  if self.visited or constants.HASMAP then
    love.graphics.rectangle("fill", (self.x-offsetx-1/2)*20*scale, (self.y-offsety-1/2)*20*scale, scale*20, scale*20)
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("line", (self.x-offsetx-1/2)*20*scale, (self.y-offsety-1/2)*20*scale, scale*20, scale*20)
  end
  if self.hasPowerup and (self.visited or constants.HASCOMPASS) then
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("line", (self.x-offsetx)*20*scale, (self.y-offsety)*20*scale, 3, 10)
  end
end

-- set the given wall. if hasDoor is true, it comes with a door.
function Room:setWall(wall, hasDoor)
  collisionmanager:SetActiveRoom(self.x, self.y)
  if wall=="left" then
    if self.platforms.left then
      collisionmanager:removeListenersForObject(self.platforms.left.colBody)
    end
    if hasDoor then
      plat1 = Platform:new(Vector:new(25, constants.HEIGHT/8-15), 
                           Vector:new(50, constants.HEIGHT/4-30), 0, 0, 255)
      plat2 = Platform:new(Vector:new(25, constants.HEIGHT*3/4), 
                           Vector:new(50, constants.HEIGHT/2), 0, 0, 255)
      self.platforms.left = DPlat:new(plat1, plat2)
    else
      self.platforms.left = Platform:new(Vector:new(25, constants.HEIGHT/2),
                              Vector:new(50, constants.HEIGHT), 0, 0, 255)
    end
  elseif wall=="right" then
    if self.platforms.right then
      collisionmanager:removeListenersForObject(self.platforms.right.colBody)
    end
    if hasDoor then
      plat1 = Platform:new(Vector:new(constants.WIDTH-25, constants.HEIGHT/8-15), 
                           Vector:new(50, constants.HEIGHT/4-30), 0, 0, 255)
      plat2 = Platform:new(Vector:new(constants.WIDTH-25, constants.HEIGHT*3/4), 
                           Vector:new(50, constants.HEIGHT/2), 0, 0, 255)
      self.platforms.right = DPlat:new(plat1, plat2)
    else
      self.platforms.right = Platform:new(Vector:new(constants.WIDTH-25, constants.HEIGHT/2),
                               Vector:new(50, constants.HEIGHT), 0, 0, 255)
    end
  elseif wall == "top" then
    if self.platforms.top then
      collisionmanager:removeListenersForObject(self.platforms.top.colBody)
    end
    if hasDoor then
      plat1 = Platform:new(Vector:new(constants.WIDTH/6, 25), 
                           Vector:new(constants.WIDTH/3, 50), 0, 0, 255)
      plat2 = Platform:new(Vector:new(constants.WIDTH*5/6, 25), 
                           Vector:new(constants.WIDTH/3, 50), 0, 0, 255)
      self.platforms.top = DPlat:new(plat1, plat2)
    else
      self.platforms.top = Platform:new(Vector:new(constants.WIDTH/2, 25), 
                             Vector:new(constants.WIDTH, 50), 0, 0, 255)
    end
  elseif wall == "bottom" then
    if self.platforms.bottom then
      collisionmanager:removeListenersForObject(self.platforms.bottom.colBody)
    end
    if hasDoor then
      plat1 = Platform:new(Vector:new(constants.WIDTH/6, constants.HEIGHT-25),
                           Vector:new(constants.WIDTH/3, 50), 0, 0, 255)
      plat2 = Platform:new(Vector:new(constants.WIDTH*5/6, constants.HEIGHT-25),
                           Vector:new(constants.WIDTH/3, 50), 0, 0, 255)
      self.platforms.bottom = DPlat:new(plat1, plat2)
    else
      self.platforms.bottom = Platform:new(Vector:new(constants.WIDTH/2, constants.HEIGHT-25),
                                Vector:new(constants.WIDTH, 50), 0, 0, 255)
    end
  end
end

-- make doors on the given walls
function Room:makeDoors(left, right, top, bottom)
  if left then
    --self:setWall("left", true)
    self.hasLeftDoor = true
    self.numberDoors = self.numberDoors+1
  end
  if right then
    --self:setWall("right", true)
    self.hasRightDoor = true
    self.numberDoors = self.numberDoors+1
  end
  if top then
    --self:setWall("top", true)
    self.hasTopDoor = true
    self.numberDoors = self.numberDoors+1
  end
  if bottom then
    --self:setWall("bottom", true)
    self.hasBottomDoor = true
    self.numberDoors = self.numberDoors+1
  end
end

function Room:RegisterHitboxesInRoom()
  collisionmanager:SetActiveRoom(self.x, self.y)
  table.foreach(self.platforms, function(i, platform)
    platform:registerListener()
  end)
  table.foreach(self.powerups, function(i, powerup)
    powerup:registerListener()
  end)
end

function Room:containsPlatform(platform)
  for i,plat in ipairs(self.platforms) do
    if plat == platform then
      return true
    end
  end
  return false
end

function Room.__tostring(r)
  return "Room at "..r.x..","..r.y
end

return Room
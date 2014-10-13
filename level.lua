local listener = require 'engine/listener'
local eventmanager = require 'engine/eventmanager'
local collisionmanager = require 'engine/collisionmanager'
local Room = require'room'
local constants = require'constants'
local Vector = require'engine/vector'

local Level = { rooms = {}, -- a table of table of rooms 
currentRoom = Room:new(0, 0) -- the active room
}

local function placeinGrid(i, r, grid)
  grid[r.x] = grid[r.x] or  {}
  grid[r.x][r.y] = r
end

-- takes a list of rooms and sorts them into a grid
-- it's probably best not to put two rooms in one place
local function organizeRooms(rooms)
  grid = {}
  table.foreach(rooms, function(i, r) placeinGrid(i, r, grid) end)
  return grid
end

-- makes doors starting from the given room in the given grid
local function makeDoors(grid)
  table.foreach(grid, function(i, column)
    table.foreach(column, function(i, room)
    collisionmanager:SetActiveRoom(room.x, room.y)
    if room.x > 0 and grid[room.x-1] then
      left = grid[room.x-1][room.y]
    end
    if room.y > 0 then
      top = grid[room.x][room.y-1]
    end
    if grid[room.x+1] then
      right = grid[room.x+1][room.y]
    end
      bottom = grid[room.x][room.y+1]
    room:makeDoors(left, right, top, bottom)
    if room.y > 9 then
      print("this is a low room!")
      print(room)
      print(left, right, top, bottom)
      print(room.hasLeftDoor, room.hasRightDoor, room.hasTopDoor, room.hasBottomDoor)
    end
    left = nil
    right = nil
    top = nil
    bottom = nil
  end)
  end)
end

function Level:new(someRooms, curRoomLoc) 
  local o = { rooms = organizeRooms(someRooms)}
  o.currentRoom = o.rooms[curRoomLoc.x][curRoomLoc.y]
  o.currentRoom.visited = true
  makeDoors(o.rooms)
  collisionmanager:SetActiveRoom(curRoomLoc.x, curRoomLoc.y)
  setmetatable(o, self)
  self.__index = self
  eventmanager:registerListener("ButtonPressEvent", listener:new(o, o.turnOnMap))
  eventmanager:registerListener("KeyPressedEvent", listener:new(o, o.turnOnMap))
  eventmanager:registerListener('PlatformTouchedEvent', listener:new(o, o.setPlayerRoom))
  return o
end

function Level:newEmpty()
  o = {{}, Room:new(0, 0)}
  setmetatable(o, self)
  self.__index = self
  return o

end

function Level:RegisterHitboxes()
  table.foreach(self.rooms, function(i, col)
    table.foreach(col, function(i, room)
      room:RegisterHitboxesInRoom()
    end)
  end)
  collisionmanager:SetActiveRoom(self.currentRoom.x, self.currentRoom.y)
end

-- moves the players between rooms
-- this looks like a lot of stuff, but it's just a bunch of checks to make sure the player is making a legal move
function Level:switchRooms(player)
  if     player.body.loc.x < 0
  and self.rooms[self.currentRoom.x-1]
  and self.rooms[self.currentRoom.x-1][self.currentRoom.y] then
    player.body:moveOverTo(Vector:new(constants.WIDTH, player.body.loc.y))
    self.currentRoom = self.rooms[self.currentRoom.x-1][self.currentRoom.y]
    collisionmanager:SetActiveRoom(self.currentRoom.x, self.currentRoom.y)
  elseif player.body.loc.x > constants.WIDTH 
  and self.rooms[self.currentRoom.x+1]
  and self.rooms[self.currentRoom.x+1][self.currentRoom.y] then
    player.body:moveOverTo(Vector:new(0, player.body.loc.y))
    self.currentRoom = self.rooms[self.currentRoom.x+1][self.currentRoom.y]
    collisionmanager:SetActiveRoom(self.currentRoom.x, self.currentRoom.y)
  elseif  player.body.loc.y < 0 
  and self.rooms[self.currentRoom.x]
  and self.rooms[self.currentRoom.x][self.currentRoom.y-1] then
    player.body:moveOverTo(Vector:new(player.body.loc.x, constants.HEIGHT))
    self.currentRoom = self.rooms[self.currentRoom.x][self.currentRoom.y-1]
    collisionmanager:SetActiveRoom(self.currentRoom.x, self.currentRoom.y)
  elseif  player.body.loc.y > constants.HEIGHT
  and self.rooms[self.currentRoom.x]
  and self.rooms[self.currentRoom.x][self.currentRoom.y+1] then
    player.body:moveOverTo(Vector:new(player.body.loc.x, 0))
    self.currentRoom = self.rooms[self.currentRoom.x][self.currentRoom.y+1]
    collisionmanager:SetActiveRoom(self.currentRoom.x, self.currentRoom.y)
  else
    if player.body.lastPlatform then
      if self.lastRoom then
        self.currentRoom = self.lastRoom
      end
      local moveVector = Vector:new(player.body.lastPlatform.colBody.loc.x,
                              player.body.lastPlatform.colBody.loc.y-player.body.lastPlatform.colBody.size.y/2-50)
      player.body:moveOverTo(moveVector)
    else
      player.body:moveOverTo(Vector:new(constants.WIDTH/2, constants.HEIGHT/2))
    end
    player.body.v.y = 0
  end
  self.currentRoom.visited = true
end

-- update the current room
function Level:update()
  self.currentRoom:update()
end

function Level:setPlayerRoom(event)
  local roomsToSearch = {self.currentRoom}
  while #roomsToSearch > 0 do
    if roomsToSearch[1]:containsPlatform(event.platform) then
      self.lastRoom = roomsToSearch[1]
      return
    else
      if self.rooms[self.currentRoom.x][self.currentRoom.y-1] then
        table.insert(roomsToSearch, self.rooms[self.currentRoom.x][self.currentRoom.y-1])
      end
      if self.rooms[self.currentRoom.x][self.currentRoom.y+1] then
        table.insert(roomsToSearch, self.rooms[self.currentRoom.x][self.currentRoom.y+1])
      end
      if self.rooms[self.currentRoom.x-1]
      and self.rooms[self.currentRoom.x-1][self.currentRoom.y] then
        table.insert(roomsToSearch, self.rooms[self.currentRoom.x-1][self.currentRoom.y])
      end
      if self.rooms[self.currentRoom.x+1]
      and self.rooms[self.currentRoom.x+1][self.currentRoom.y] then
        table.insert(roomsToSearch, self.rooms[self.currentRoom.x+1][self.currentRoom.y])
      end
    end
    table.remove(roomsToSearch, 1)
  end
end

function Level:turnOnMap(event)
  if event.button == 5 or event.key == 'return' then
    self.mapOn = not self.mapOn
  end
end

-- draw the current room then the mini map
function Level:draw()
  self.currentRoom:draw()
  
  -- translate the matrix and then draw a background
  love.graphics.push()
  love.graphics.translate(constants.WIDTH-80, 50)
  love.graphics.setColor(200, 200, 200)
  love.graphics.rectangle("fill", -51, -31, 102, 62)
  function drawColumn(i, c)
    table.foreach(c, 
    function(k, r)
      -- have each room draw itself
      if math.abs(r.x - self.currentRoom.x) < 3
      and math.abs(r.y - self.currentRoom.y) < 2 then
       r:drawSmall(self.currentRoom.x, self.currentRoom.y, 1)
      end
    end)
  end
  table.foreach(self.rooms, function(i, c) drawColumn(i, c) end)
  -- have the active room draw itself a different color
  self.currentRoom:drawSmall(self.currentRoom.x, self.currentRoom.y, 1, true)
  love.graphics.pop()
end

-- draw the whole map in the center of the screen
-- do the same thing as the mini map, just every room instead
function Level:drawMap()
  if not self.mapOn then return end
  love.graphics.push()
  love.graphics.translate(constants.WIDTH/2, constants.HEIGHT/2)
  function drawColumn(i, c)
    table.foreach(c, 
    function(k, r)
     r:drawSmall(self.currentRoom.x, self.currentRoom.y, 1)
    end)
  end
  table.foreach(self.rooms, function(i, c) drawColumn(i, c) end)
  self.currentRoom:drawSmall(self.currentRoom.x, self.currentRoom.y, 1, true)
  love.graphics.pop()
end

return Level
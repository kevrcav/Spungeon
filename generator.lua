local tile = require 'tile'
local message = require 'message'
local solver = require 'solver'
local collisionmanager = require 'collisionmanager'
Room = require'room'
constants = require'constants'
vector = require'vector'
PowerupF = require'powerup'
powerup, superJump, map, compass, dash, bestthing = PowerupF[1], PowerupF[2], PowerupF[3], PowerupF[4], PowerupF[5], PowerupF[6]
powerupHolder = require'powerupholder'
testtile = tile:new(constants.WIDTH/2, constants.HEIGHT/2, 50, 50, 5, {255, 0, 0, 255})
-- a generator has powerups and active functions
local generator = {activeFunctions = {},
             powerups = {},
             textRooms = {},
             messages = {'Welcome to Space Dungeon! Your mission is to find the Best Thing. I left it around here somewhere. So. Get to it.\n Oh! Also! Controls! For the keyboard it\'s left and right keys for movement and space to jump. On a controller it\'s left stick to move and A button to jump.',
                         'Hey, another thing. You can jump on walls. Thats probably an important thing to know.',
                         'Oh, also, things may be unreasonably difficult to get the Thing. I maaaaay also have blocked off some areas. If I did, just close and reopen and I\'ll probably have fixed it. By rebuilding the whole thing. Go big or go home, y\'know?',
                         'Aaaand just one more tiny thing: This is an alpha. Beware the strange and unexpected.'},
             bestHolder = powerupHolder:new(bestthing:new(vector:new(constants.WIDTH/2, constants.HEIGHT/2))),
             tile = testtile}

-- changes the random seed to the given value
function generator:Init(seed)
  self.tile:setColumn(3, 0, 10, {0, 0, 255})
  self.tile:setRow(2, 0, 10, {0, 255, 0})
  self.tile:setBox(5, 8, 8, {255, 255, 0})
  math.randomseed(seed)
end

-- makes a with about the number of rooms given.
function generator:GenerateWorld(numberRooms)
  rooms = {}
  -- places the map can build off. the entries are in the form
  -- {X direction, Y direction, Base Room X, Base Room Y}
  openDirections = {}
  curX = 0
  curY = 0
  
  -- makes a string of rooms along the X axis
  function makeRow(increment, roomsToMake)
    if roomsToMake <= 0 then -- end recursion
      return
    end
    -- move the placement location
    curX=curX+increment
    -- make a new room
    table.insert(rooms, Room:new(curX, curY))
    -- potentially place a side room
    if roomsToMake > 1 and roomsToMake < 4 and math.random(3)==1 then
      table.insert(rooms, Room:new(curX, curY+math.random(2)*2-3))
    end
    makeRow(increment, roomsToMake-1)
  end
  
  -- makes a string of rooms along the Y axis
  -- note: Works the same as makeRow, but for Y
  function makeColumn(increment, roomsToMake)
    if roomsToMake <= 0 then
      return
    end
    curY=curY+increment
    table.insert(rooms, Room:new(curX, curY))
    if roomsToMake > 1 and roomsToMake < 4 and math.random(5)==1 then
      table.insert(rooms, Room:new(curX+math.random(2)*2-3, curY))
    end
    makeColumn(increment, roomsToMake-1)
  end
  
  -- find the greatest negative X and Y values among the rooms in the current world
  function getGreatestNegatives()
    negativeX = 0
    negativeY = 0
    table.foreach(rooms, function (i, r) 
                          if r.x < negativeX then negativeX = r.x end
                          if r.y < negativeY then negativeY = r.y end
                         end)
    return negativeX, negativeY
  end
  
  -- move all the rooms by the given X and Y
  function adjustRooms(negaX, negaY)
    table.foreach(rooms, function (i, r)
                          r.x = r.x - negativeX
                          r.y = r.y - negativeY
                         end)
  end
  
  -- make the overall map
  function makeMap()
    -- set the rooms to make to the number of rooms
    roomsLeft = numberRooms
    -- keep making rooms until there are no more requested
    while roomsLeft > 0 do
      -- the next way to go is the first in the queue
      nextDirection = openDirections[1]
      table.remove(openDirections, 1)
      
      -- get where the open door is located
      curX = nextDirection[3]
      curY = nextDirection[4]
      
      -- if the next direction is on the X, build that way
      if nextDirection[2] == 0 then
        roomsInChunk = math.random(2)+1
        makeRow(nextDirection[1], roomsInChunk)
        -- usually build vertically, and occasionally build in the same direction
        if math.random(46)==1 then
          openDirections[#openDirections+1]={nextDirection[1], 0, curX, curY}
        else
          openDirections[#openDirections+1]={0, nextDirection[1], curX, curY}
        end
      -- otherwise build vertically
      else
        roomsInChunk = 3
        makeColumn(nextDirection[2], roomsInChunk)
        -- always go both left and right
        openDirections[#openDirections+1]={1, 0, curX, curY}
        openDirections[#openDirections+1]={-1, 0, curX, curY}
      end
      -- move towards termination
      roomsLeft = roomsLeft - roomsInChunk
    end
    
  end
  -- start a room at the current X and Y
  table.insert(rooms, Room:new(curX, curY))
  -- open the first directions to go
  openDirections[#openDirections+1]={-1, 0, curX, curY}
  openDirections[#openDirections+1]={1, 0, curX, curY}
  
  -- make the map
  makeMap()
  -- adjust rooms so all their positions are positive
  negX, negY = getGreatestNegatives()
  adjustRooms(negX, negY)
  
  for i,room in ipairs(rooms) do
    room.tile = self.tile
  end
  -- return the location of the starting room and the list of rooms
  return rooms, -negX, -negY
end

-- build the platforms for the given set of rooms starting from the given X and Y
function generator:makePlatforms(rooms, firstX, firstY)
  -- add the starting room to the list of rooms to complete
  roomsToComplete = {rooms[firstX][firstY]}
  local entrances = {}
  table.foreach(rooms, function(i, col)
    table.foreach(col, function(i, room)
      entrances[room.x] = entrances[room.x] or {}
      entrances[room.x][room.y] = {}
    end)
  end)
  entrances[firstX][firstY].entrance = vector:new(0, constants.HEIGHT/50/2)
  entrances[firstX][firstY].entranceSide = 'left'
  entrances[firstX-1][firstY].entrance = vector:new(constants.WIDTH/50, constants.HEIGHT/50/2)
  entrances[firstX-1][firstY].entranceSide = 'right'
  local highestX, lowestY, correctX = 0,100,0
  for i,col in ipairs(rooms) do
    highestX = math.max(highestX, i)
    for i, room in pairs(col) do
      lowestY = math.min(lowestY, i)
    end
  end
  for i=0, highestX do
    if rooms[i] and rooms[i][lowestY] then
      correctX = i
    end
  end
  local maxX, maxY = 0, 0
  -- while there are still rooms to complete, keep going
  while #roomsToComplete > 0 do
    -- update the room to build in
    local room = roomsToComplete[#roomsToComplete]
    local exits = {}
    maxX = math.max(room.x, maxX)
    maxY = math.max(room.y, maxY)
    if room.x == correctX and room.y == lowestY and not rooms[correctX][lowestY-1] then
        rooms[correctX][lowestY]:makeDoors(false, false, true, false)
        rooms[correctX][lowestY-1] = room:new(correctX, lowestY-1)
        rooms[correctX][lowestY-2] = room:new(correctX, lowestY-2)
        rooms[correctX][lowestY-3] = room:new(correctX, lowestY-3)
        rooms[correctX][lowestY-4] = room:new(correctX, lowestY-4)
        rooms[correctX][lowestY-1]:makeDoors(false, false, true, true)
        rooms[correctX][lowestY-2]:makeDoors(false, false, true, true)
        rooms[correctX][lowestY-3]:makeDoors(false, false, true, true)
        rooms[correctX][lowestY-4]:makeDoors(false, false, false, true)
        entrances[correctX][lowestY-1] = {}
        entrances[correctX][lowestY-2] = {}
        entrances[correctX][lowestY-3] = {}
        entrances[correctX][lowestY-4] = {}
        rooms[correctX][lowestY-2].challenge1 = true
        table.remove(roomsToComplete, #roomsToComplete)
        table.insert(roomsToComplete, 1, room)
     else
    -- if the room has not already been built in, build the room
    if #room.platforms == 0 then
      -- if there are active barrier functions then maybe make a barrier
      --if #self.activeFunctions > 0 and math.random(2)==1 then
      --  self.activeFunctions[math.random(#self.activeFunctions)](room)
      --else
      -- else make regular platforms
      local endDirs = {}
      local entranceSide = entrances[room.x][room.y].entranceSide 
      local entrance = entrances[room.x][room.y].entrance
      if room.hasLeftDoor and entranceSide ~= 'left' then
        local goal = {dir = 'left'}
        if entrances[room.x][room.y].exitdir == 'left' then
          goal.endloc = entrances[room.x][room.y].exitloc
        end
        table.insert(endDirs, goal)
      end
      if room.hasRightDoor  and entranceSide ~= 'right' then
        local goal = {dir = 'right'}
        if entrances[room.x][room.y].exitdir == 'right' then
          goal.endloc = entrances[room.x][room.y].exitloc
        end
        table.insert(endDirs, goal)
      end
      if room.hasTopDoor  and entranceSide ~= 'up' then
        local goal = {dir = 'up'}
        if entrances[room.x][room.y].exitdir =='up' then
          goal.endloc = entrances[room.x][room.y].exitloc
        end
        table.insert(endDirs, goal)
      end
      if room.hasBottomDoor  and entranceSide ~= 'down' then
        local goal = {dir = 'down'}
        if entrances[room.x][room.y].exitdir == 'down' then
          goal.endloc = entrances[room.x][room.y].exitloc
        end
        table.insert(endDirs, goal)
      end
      exits = self:makePlatsFromSolver(room, entrance, entranceSide, endDirs)
      entrances[room.x][room.y].exits = exits
      -- end
    end
    -- remove this room from the list
    table.remove(roomsToComplete, #roomsToComplete)
    -- add any rooms that are adjacent to this and exist
    -- does not use room.has[Direction]Door to ensure it doesn't try to populate a nil room
    if  rooms[room.x-1]
    and rooms[room.x-1][room.y]
    and #rooms[room.x-1][room.y].platforms == 0 then
      roomsToComplete[#roomsToComplete+1] = rooms[room.x-1][room.y]
      if exits['left'] then
        exits['left'].x = constants.WIDTH/50
        if entrances[room.x-1][room.y].entrance then
          entrances[room.x-1][room.y].exitloc = exits['left'].y
          entrances[room.x-1][room.y].exitdir = 'right'
        else
          entrances[room.x-1][room.y].entrance = exits['left']
          entrances[room.x-1][room.y].entranceSide = 'right'
        end
      end
    end
    if  rooms[room.x+1]
    and rooms[room.x+1][room.y]
    and #rooms[room.x+1][room.y].platforms == 0 then
      roomsToComplete[#roomsToComplete+1] = rooms[room.x+1][room.y]
      if exits['right'] then
        exits['right'].x = 0
        if entrances[room.x+1][room.y].entrance then
          entrances[room.x+1][room.y].exitloc = exits['right'].y
          entrances[room.x+1][room.y].exitdir = 'left'
        else
          entrances[room.x+1][room.y].entrance = exits['right']
          entrances[room.x+1][room.y].entranceSide = 'left'
        end
      end
    end
    if  rooms[room.x]
    and rooms[room.x][room.y-1]
    and #rooms[room.x][room.y-1].platforms == 0 then
      roomsToComplete[#roomsToComplete+1] = rooms[room.x][room.y-1]
      if exits['up'] then
        exits['up'].y = constants.HEIGHT/50
        if entrances[room.x][room.y-1].entrance then
          entrances[room.x][room.y-1].exitloc = exits['up'].x
          entrances[room.x][room.y-1].exitdir = 'down'
        else
          entrances[room.x][room.y-1].entrance = exits['up']
          entrances[room.x][room.y-1].entranceSide = 'down'
        end
      end
    end
    if  rooms[room.x]
    and rooms[room.x][room.y+1]
    and #rooms[room.x][room.y+1].platforms == 0 then
      roomsToComplete[#roomsToComplete+1] = rooms[room.x][room.y+1]
      if exits['down'] then
        exits['down'].y = 0
        if entrances[room.x][room.y+1].entrance then
          entrances[room.x][room.y+1].exitloc = exits['down'].x
          entrances[room.x][room.y+1].exitdir = 'up'
        else
          entrances[room.x][room.y+1].entrance = exits['down']
          entrances[room.x][room.y+1].entranceSide = 'up'
        end
      end
    end
    if #roomsToComplete == 0 then
      room.powerups = {}
      room:addPowerup(self.bestHolder.powerup)
    end
    end
  end
  local lines = {}
  for j=0,maxY do
    for i=0, maxX do
      for k=0, constants.HEIGHT/50 do
        lines[j*(constants.HEIGHT/50+1)+k] = lines[j*(constants.HEIGHT/50+1)+k] or ''
        if self.textRooms[i] and self.textRooms[i][j] then
          lines[j*(constants.HEIGHT/50+1)+k] = lines[j*(constants.HEIGHT/50+1)+k]..self.textRooms[i][j][k]
        else
          lines[j*(constants.HEIGHT/50+1)+k] = lines[j*(constants.HEIGHT/50+1)+k]..'| | | | | | | | | | | | | | | | | '
        end
      end
    end
  end
  for i=0,#lines do
    print(lines[i])
  end
end

-- takes a blueprint and compiles it into a list of platforms
function generator:createPlatformsFromBlueprint(blueprint)
  local platforms = {}
  for i=0, constants.WIDTH/50-1 do
    local colplats = {}
    for j=0, constants.HEIGHT/50-1 do
      if blueprint.full[i][j] then
        local attachedBlock = self:getAnyAbove(colplats, j, blueprint.full[i][j])
        if attachedBlock then
          attachedBlock.size = attachedBlock.size+1
        else
          table.insert(colplats, {start = j, size = 1, type = blueprint.full[i][j]})
        end
      else
        if blueprint.row[i][j] then
          table.insert(colplats, {start = j, size = 1, type = blueprint.row[i][j]})
        end
        if blueprint.col[i][j] then
          local attachedBlock = self:getAnyAbove(colplats, j, blueprint.col[i][j])
          if attachedBlock then
            attachedBlock.size = attachedBlock.size+1
          else
            table.insert(colplats, {start = j, size = 1, type = blueprint.col[i][j]})
          end
        end
      end
    end
    table.foreach(colplats, function (k, platform)
      if platform.type == 'left' or platform.type == 'right' then
        table.insert(platforms, {start = vector:new(i, platform.start), 
                                 size = vector:new(1, platform.size),
                                 type = platform.type})
      else
        local attachedBlock = self:getAnyLeft(platforms, vector:new(i, platform.start),
                                              vector:new(1, platform.size), platform.type)
        if attachedBlock then
          attachedBlock.size.x = attachedBlock.size.x + 1
        else
          table.insert(platforms, {start = vector:new(i, platform.start), 
                                   size = vector:new(1, platform.size),
                                   type = platform.type})
        end
      end
    end)
  end
  return platforms
end

function generator:CreatePlatformsInRoom(platforms, room)
  table.foreach(platforms, function(i, platform)
    if platform.type == 'left' then
      room:setPlatform(vector:new(platform.start.x*50+10, platform.start.y*50+platform.size.y*25),
                       vector:new(20, platform.size.y*50), {100, 150, 180})
    elseif platform.type == 'right' then
      room:setPlatform(vector:new(platform.start.x*50+40, platform.start.y*50+platform.size.y*25),
                       vector:new(20, platform.size.y*50), {100, 150, 180})
    elseif platform.type == 'top' then
      room:setPlatform(vector:new(platform.start.x*50+platform.size.x*25, platform.start.y*50+10),
                       vector:new(platform.size.x*50, 20), {50, 200, 200})
    elseif platform.type == 'bottom' then
      room:setPlatform(vector:new(platform.start.x*50+platform.size.x*25, platform.start.y*50+40),
                       vector:new(platform.size.x*50, 20), {50, 200, 200})
    elseif platform.type == 'full' then
      room:setPlatform(vector:new(platform.start.x*50+platform.size.x*25, 
                                  platform.start.y*50+platform.size.y*25),
                       vector:new(platform.size.x*50, platform.size.y*50), {0, 150, 150})
    end
  end)
end

function generator:getAnyAbove(col, loc, type)
  local attachblock = nil
  table.foreach(col, function(i, block)
    if block.start + block.size == loc
    and block.type == type then
      attachblock = block
    end
  end)
  return attachblock
end

function generator:getAnyLeft(plats, loc, size, type)
  local attachblock = nil
  table.foreach(plats, function(i, block)    
    local saize = size
    local loac = loc
    if  block.start.x + block.size.x == loc.x
    and block.start.y == loc.y and block.size.y == size.y
    and block.type == type then
      attachblock = block
    end
  end)
  return attachblock
end

-- makes the regular, traversible room.
-- what it does:
-- sets platforms to jump to the left and the right
-- sets 3 platforms to jump through the top
-- sets a platform to stop from falling to the bottom
function generator:makePlatsForRoom(room)
  -- if this only has one door and powerups remain, add a powerup]]
  local blueprint = {row = {}, col = {}, full = {}}
  for i=0,constants.WIDTH/50-1 do
    blueprint.row[i] = {}
    blueprint.col[i] = {}
    blueprint.full[i] = {}
  end
  for i=0, constants.WIDTH/50-1 do
    blueprint.row[i][0] = 'top'
    blueprint.row[i][constants.HEIGHT/50-1] = 'bottom'
  end
  for i=0, constants.HEIGHT/50-1 do
    blueprint.col[0][i] = 'left'
    blueprint.col[constants.WIDTH/50-1][i] = 'right'
  end
  if room.hasTopDoor then
    blueprint.row[math.floor(constants.WIDTH/100)][2] = 'bottom'
    blueprint.row[math.floor(constants.WIDTH/100)+1][5] = 'bottom'
    blueprint.row[math.floor(constants.WIDTH/100)+2][8] = 'bottom'
    blueprint.row[math.floor(constants.WIDTH/100)][0] = nil
    blueprint.row[math.floor(constants.WIDTH/100)+1][0] = nil
  end
  if room.hasBottomDoor then
    blueprint.row[math.floor(constants.WIDTH/100)][constants.HEIGHT/50-1] = nil
    blueprint.row[math.floor(constants.WIDTH/100)+1][constants.HEIGHT/50-1] = nil
  end
  if room.hasLeftDoor then
    blueprint.col[0][constants.HEIGHT/50] = nil
    blueprint.col[0][constants.HEIGHT/50-1] = nil
    blueprint.col[0][constants.HEIGHT/50-2] = nil
  end
  if room.hasRightDoor then
    blueprint.col[constants.WIDTH/50-1][constants.HEIGHT/50] = nil
    blueprint.col[constants.WIDTH/50-1][constants.HEIGHT/50-1] = nil
    blueprint.col[constants.WIDTH/50-1][constants.HEIGHT/50-2] = nil
  end
  local plats = self:createPlatformsFromBlueprint(blueprint)
  generator:CreatePlatformsInRoom(plats, room)
  
  if room.numberDoors == 1 and #self.powerups > 0 then
    room:setPlatform(vector:new(constants.WIDTH/2, constants.HEIGHT*3/4), vector:new(200, 50), {255, 0, 0})
    room.hasPowerup = true
    powerupNum = math.random(#self.powerups)
    room:addPowerup(self.powerups[powerupNum].powerup)
    -- add the powerup's functions to the active functions
    table.foreach(self.powerups[powerupNum].potentialRooms, function (i, pr)
      table.insert(self.activeFunctions, pr)
    end)
    table.remove(self.powerups, powerupNum)
  end
end

function generator:makePlatsFromSolver(room, entrance, entranceSide, endDir)
  local requirements = {startSide = entranceSide, start = entrance, endDir = endDir}
  local blueprint, exits, lines = false, false, false
  if #endDir > 0 then
    if room.challenge1 then
      blueprint, exits, lines = solver:buildChallenge1(requirements)
    else
      blueprint, exits, lines = solver:buildTunnel(requirements)
    end
    if #self.messages > 0 then
      room:addMessage(message:new(self.messages[1], vector:new(constants.WIDTH/4, constants.HEIGHT/2), constants.WIDTH/2, {r=0, g=0, b=0}))
      table.remove(self.messages, 1)
    end
  else
    blueprint, exits, lines = solver:buildRoom(requirements)
    if #self.powerups > 0 then
      room.hasPowerup = true
      powerupNum = math.random(#self.powerups)
      room:addPowerup(self.powerups[powerupNum].powerup)
      if self.powerups[powerupNum].powerup.name == 'Double Jump' then
        solver.maxJumpDist = 6
      end
      for i,feature in ipairs(self.powerups[powerupNum].features) do
        solver:enableFeature(feature)
      end
      table.remove(self.powerups, powerupNum)
    end
  end
  local plats = self:createPlatformsFromBlueprint(blueprint)
  generator:CreatePlatformsInRoom(plats, room)
  if lines then
    self.textRooms[room.x] = self.textRooms[room.x] or {}
    self.textRooms[room.x][room.y] = lines
  end
  return exits
end
-- looks through a list of room is one exists at the given X Y
function roomExists(rooms, x ,y)
  table.foreach(rooms, function (i, r) if r.x == x and r.y == y then return true end end)
  return false
end

-- the super jump barrier layout
-- all this does is place a bunch of platforms, you can see it in the video
function SuperJumpRoom(room)
  --[[if true then --room.hasTopDoor then
    room:setPlatform(vector:new(constants.WIDTH/2, constants.HEIGHT*1/2), vector:new(constants.WIDTH/3-60, 10), {0, 255, 0}, "bottomless")
    room:setPlatform(vector:new(constants.WIDTH/2, constants.HEIGHT*2/5), vector:new(50, 10), {0, 255, 0}, "bottomless")
    room:setPlatform(vector:new(constants.WIDTH/2, constants.HEIGHT*1/5), vector:new(50, 10), {0, 255, 0}, "bottomless")
    room:setPlatform(vector:new(constants.WIDTH/3 + 30, constants.HEIGHT*1/4+50), vector:new(10, constants.HEIGHT/2-100), {0, 255, 0})
    room:setPlatform(vector:new(constants.WIDTH*2/3 - 30, constants.HEIGHT*1/4+50), vector:new(10, constants.HEIGHT/2-100), {0, 255, 0})
    room:setPlatform(vector:new(constants.WIDTH/2 - 25, constants.HEIGHT*3/10), vector:new(10, constants.HEIGHT/5), {0, 255, 0})
    room:setPlatform(vector:new(constants.WIDTH/2 + 25, constants.HEIGHT*3/10), vector:new(10, constants.HEIGHT/5), {0, 255, 0})
  end
  if room.hasBottomDoor then
    room:setPlatform(vector:new(constants.WIDTH/2, constants.HEIGHT-30), vector:new(constants.WIDTH/6, 10), {0, 255, 0}, "bottomless")
  end
  if room.hasLeftDoor then
    room:setPlatform(vector:new(constants.WIDTH/8+50, constants.HEIGHT*1/2+15), vector:new(constants.WIDTH/4, 10), {0, 255, 0}, "bottomless")
    room:setPlatform(vector:new(constants.WIDTH/8, constants.HEIGHT*1/2+15), vector:new(constants.WIDTH/4, 10), {0, 255, 0})
    room:setPlatform(vector:new(constants.WIDTH/3 - 20, constants.HEIGHT*1/4+65), vector:new(10, constants.HEIGHT/2-100), {0, 255, 0})
  end
  if room.hasRightDoor then
    room:setPlatform(vector:new(constants.WIDTH*7/8-50, constants.HEIGHT*1/2+15), vector:new(constants.WIDTH/4, 10), {0, 255, 0}, "bottomless")
    room:setPlatform(vector:new(constants.WIDTH*7/8, constants.HEIGHT*1/2+15), vector:new(constants.WIDTH/4, 10), {0, 255, 0})
    room:setPlatform(vector:new(constants.WIDTH*2/3 + 20, constants.HEIGHT*1/4+65), vector:new(10, constants.HEIGHT/2-100), {0, 255, 0})
  end]]
  
end

-- makes some powerup holders and puts them in the list of powerups
local SJHolder = powerupHolder:new(superJump:new(vector:new(constants.WIDTH/2, constants.HEIGHT/2)))
local mapHolder = powerupHolder:new(map:new(vector:new(constants.WIDTH/2, constants.HEIGHT/2)))
local compassHolder = powerupHolder:new(compass:new(vector:new(constants.WIDTH/2, constants.HEIGHT/2)))
local dashHolder = powerupHolder:new(dash:new(vector:new(constants.WIDTH/2, constants.HEIGHT/2)))
generator.powerups[#generator.powerups+1] = SJHolder
SJHolder:addLinkedFeature('walls')
generator.powerups[#generator.powerups+1] = compassHolder
generator.powerups[#generator.powerups+1] = mapHolder
generator.powerups[#generator.powerups+1] = dashHolder
dashHolder:addLinkedFeature('pits')

return generator
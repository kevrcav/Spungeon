local Room = require'room'
local constants = require'constants'
local Vector = require'vector'

local testgenerator = {}

function testgenerator:GenerateWorld()
  rooms = {}
  room1 = Room:new(0, 2)
  setPlatform(room1, constants.WIDTH*3/4, constants.HEIGHT*3/4, 100, 10)
  rooms[1] = room1
  room2 = Room:new(1, 2)
  rooms[2] = room2
  setPlatform(room2, 100, constants.HEIGHT/4, 100, 10)
  setPlatform(room2, 150, constants.HEIGHT/2, 10, constants.HEIGHT/2)
  setPlatform(room2, constants.WIDTH/2, constants.HEIGHT*3/4, constants.WIDTH-300, 10)
  setPlatform(room2, constants.WIDTH-150, constants.HEIGHT*3/4-50, 10, 100)
  setPlatform(room2, constants.WIDTH/2, constants.HEIGHT/2, 100, 10, "bottomless")
  setPlatform(room2, constants.WIDTH/2, constants.HEIGHT/4, 100, 10, "bottomless")
  setPlatform(room2, constants.WIDTH-100, constants.HEIGHT*3/4, 100, 10, "bottomless")
  room3 = Room:new(1, 1)
  rooms[3] = room3
  setPlatform(room3, constants.WIDTH/2, constants.HEIGHT, constants.WIDTH/3, 10, "bottomless")
  setPlatform(room3, constants.WIDTH*3/8, constants.HEIGHT*3/4, constants.WIDTH*3/4, 10)
  setPlatform(room3, constants.WIDTH*5/8, constants.HEIGHT/2, constants.WIDTH*3/4, 10)
  setPlatform(room3, constants.WIDTH*3/8, constants.HEIGHT/4, constants.WIDTH*3/4, 10)
  setPlatform(room3, constants.WIDTH/2, constants.HEIGHT/2-40, 10, 80)
  room4 = Room:new(1, 0)
  rooms[4] = room4
  setPlatform(room4, constants.WIDTH/2, constants.HEIGHT, constants.WIDTH/3, 10, "bottomless")
  setPlatform(room4, constants.WIDTH/2, constants.HEIGHT*3/4, constants.WIDTH/3, 10)
  setPlatform(room4, constants.WIDTH*2/3, constants.HEIGHT*7/8, 10, constants.HEIGHT/4)
  setPlatform(room4, constants.WIDTH/3-35, constants.HEIGHT/2, 70, constants.HEIGHT/2)
  setPlatform(room4, constants.WIDTH*2/3+35, constants.HEIGHT/3, 70, constants.HEIGHT*2/3)
  room5 = Room:new(2, 0)
  rooms[5] = room5
  setPlatform(room5, constants.WIDTH-150, constants.HEIGHT/2, 200, 10)
  setPlatform(room5, constants.WIDTH/2-50, constants.HEIGHT/2-30, 10, constants.HEIGHT/4)
  setPlatform(room5, 200, constants.HEIGHT*2/3, 100, 10)
  setPlatform(room5, 100, constants.HEIGHT*2/3, 100, 10, "bottomless")
  setPlatform(room5, constants.WIDTH/3-50, constants.HEIGHT/3, 10, constants.HEIGHT/4)
  room6 = Room:new(3, 0)
  rooms[6] = room6
  
  return rooms, 0, 2
end

function setPlatform(room, x, y, width, height, type)
  type = type or "solid"
  room:setPlatform(Vector:new(x, y), Vector:new(width, height), {0, 255, 0}, type)
end

return testgenerator
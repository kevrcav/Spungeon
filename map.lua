local map = {rooms = {}}

function map:loadData(rooms, activex, activey)
  self.rooms = {}
  for i,col in ipairs(rooms) do
    self.rooms[i] = {}
    for j,room in ipairs(col) do
      self.rooms[i][j] = {}
      self.rooms[i][j] = room.hasPowerup
      self.rooms[i][j] = room.visited
      self.rooms[i][j] = room.active
    end
  end
end

function map:draw()
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

return map

local Vector = {x = 0, y = 0}

function Vector:new(newx, newy)
  o = {x = newx, y = newy}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Vector:vect0() return Vector:new(0, 0) end

function Vector:addm(vector)
  self.x = self.x + vector.x
  self.y = self.y + vector.y
end  

function Vector:add(vector1, vector2)
  return Vector:new(vector1.x + vector2.x, 
                    vector1.y + vector2.y)
end

function Vector:subm(vector)
  self.x = self.x - vector.x
  self.y = self.y - vector.y
end  

function Vector:sub(vector1, vector2)
  return Vector:new(vector1.x - vector2.x, 
                    vector1.y - vector2.y)
end

function Vector:multm(vector)
  self.x = self.x * vector.x
  self.y = self.y * vector.y
end  

function Vector:multc(vector, c)
  newVector =  Vector:new(vector.x*c, vector.y*c)
  love.graphics.print(tostring(newVector), 300, 25)
  return newVector
end
  
function Vector:mult(vector1, vector2)
  return Vector:new(vector1.x * vector2.x, 
                    vector1.y * vector2.y)
end

function Vector:divm(vector)
  self.x = self.x / vector.x
  self.y = self.y / vector.y
end  

function Vector:div(vector1, vector2)
  return Vector:new(vector1.x / vector2.x, 
                    vector1.y / vector2.y)
end

function Vector:size()
  return math.sqrt(math.pow(self.x, 2) + math.pow(self.y, 2))
end

function Vector:dot(vector)
  return self.x*vector.x + self.y*vector.y
end

function Vector:distance(vector)
  return math.sqrt(math.pow(self.x-vector.x, 2)
                 + math.pow(self.y-vector.y, 2))
end
-- determine if the given line points in the same direction
-- as the given direction vector. 
-- -1 for opposite, +1 for same, 0 for a right angle.
function Vector:determineDir(vect, dir)
  direction = dir:dot(vect)
  if direction == 0 then
    return 0
  else
    return math.abs(direction) / direction
  end
end

function Vector:set(vector)
  self.x = vector.x
  self.y = vector.y
end

Vector.__eq = function (a, b) 
  return a.x == b.x and a.y == b.y 
end

Vector.__tostring = function(v)
  return v.x..","..v.y
end

Vector.__add = function(v1, v2)
  return Vector:add(v1, v2)
end

Vector.__sub = function(v1, v2)
  return Vector:sub(v1, v2)
end

Vector.__mul = function(v1, v2)
  return Vector:mul(v1, v2)
end

Vector.__div = function(v1, v2)
  return Vector:div(v1, v2)
end

return Vector
local Vector = require'engine/vector'

vect0 = Vector.vect0

-- a Hit Triangle is defined by 3 points
-- This is not currently instantiated, but instead used as a singleton to calculate triangle collisions
local HitTri = {point1 = vect0, point2 = vect0, point3 = vect0}

-- Create a new HitTry
function HitTri:new(vec1, vec2, vec3)
  o = {point1 = vec1, point2 = vec2, point3 = vec3}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- Detect if a point is within this
function HitTri:detectPointm(point)
  return HitTri:detectPoint(self.point1, self.point2, self.point3, point)
end

-- Detect if a point is within some arbitrary triangle
function HitTri:detectPoint(pointA, pointB, pointC, point)
  atob = Vector:sub(pointB, pointA)
  atoc = Vector:sub(pointC, pointA)
  atop = Vector:sub(point, pointA)
  
  bdotb = atob:dot(atob)
  cdotc = atoc:dot(atoc)
  bdotc = atob:dot(atoc)
  bdotp = atob:dot(atop)
  cdotp = atoc:dot(atop)
  
  denom = bdotb * cdotc - bdotc * bdotc
  alpha = (bdotb * cdotp - bdotc * bdotp) / denom
  beta = (cdotc * bdotp - bdotc * cdotp) / denom
  return alpha >= 0 and beta >= 0 and alpha + beta <= 1
end

-- print this triangle
HitTri.__tostring = function(t) return t.point1.x.." "..t.point1.y..
                                    " ".. t.point2.x.." "..t.point2.y..
                                    " ".. t.point3.x.." "..t.point3.y
end

return HitTri
local Vector = require'vector'

vect0 = Vector.vect0

local HitTri = {point1 = vect0, point2 = vect0, point3 = vect0}

function HitTri:new(vec1, vec2, vec3)
  o = {point1 = vec1, point2 = vec2, point3 = vec3}
  setmetatable(o, self)
  self.__index = self
  return o
end

function HitTri:detectPointm(point)
  return HitTri:detectPoint(self.point1, self.point2, self.point3, point)
end

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

HitTri.__tostring = function(t) return t.point1.x.." "..t.point1.y..
                                    " ".. t.point2.x.." "..t.point2.y..
                                    " ".. t.point3.x.." "..t.point3.y
end

return HitTri
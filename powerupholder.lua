local Powerup = require'powerup'

--a powerup holder has a powerup and potential rooms using that powerup

local powerupHolder = {powerup = Powerup, potentialRooms = {}}

-- make a new powerup holder
function powerupHolder:new(pup)
  local o = {powerup = pup, features = {}}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- adds the given function to this
function powerupHolder:addLinkedFeature(feature)
  self.features[#self.potentialRooms+1] = feature
end

return powerupHolder
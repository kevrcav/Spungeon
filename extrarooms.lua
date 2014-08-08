local pathSection = require 'path'
local constants = require 'constants'
local maxWidth, maxHeight = constants.WIDTH/50, constants.HEIGHT/50
local extrarooms = {}

function extrarooms.zigzag(solver, entrance)
  local firstPath = pathSection:new(entrance, maxHeight, 2, 'up')
  local nextpath = pathSection:new(entrance, maxHeight-4, maxWidth-3-entrance, 'right')
  nextpath:setPrevious(path)
  firstPath:setNext(nextpath)
  local path = nextpath
  nextpath = pathSection:new(maxWidth-4, maxHeight-3, 5, 'up')
  nextpath:setPrevious(path)
  path:setNext(nextpath)
  path = nextpath
  nextpath = pathSection:new(maxWidth-4, maxHeight-8, 10, 'left')
  nextpath:setPrevious(path)
  path:setNext(nextpath)
  local lastPath = pathSection:new(2, maxHeight-8, 4, 'up')
  nextpath:setNext(lastPath)
  lastPath:setPrevious(nextpath)
  return firstPath, {lastPath}
end


return extrarooms

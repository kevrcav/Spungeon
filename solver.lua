local pathSection = require 'path'
local extrarooms = require 'extrarooms'
local pit = require 'pit'
local wallhall = require 'wallhall'
local pathanalyzer = require 'pathanalyzer'
local vector = require 'engine/vector'
local constants = require 'constants'
local solver = {
horzMinLen = 4,
horzMaxLen = 7,
vertMinLen = 3,
vertMaxLen = 5,
maxJumpDist = 3,
minTunHeight = 2,
maxTunHeight = 6,
minShaftWidth = 3,
CeilChangeRate = 0.1,
features = {walls = wallhall.makeWallSection,
            pits = pit.makePitSection},
enabledfeatures = {}
}

local maxHeight = constants.HEIGHT/50
local maxWidth = constants.WIDTH/50
solver.directions = {'left', 'up', 'right', 'down'}
solver.directionsOp = {left = 1, up = 2, right = 3, down = 4}
solver.dirRequirements = {left = -1, up = -1, right = maxWidth, down = maxHeight}
solver.dirAxis = {left = 'x', up = 'y', right = 'x', down = 'y'}
solver.pathEnds = {left =  function(path) return vector:new(path.start.x - path.size, path.start.y) end,
                  up =    function(path) return vector:new(path.start.x, path.start.y - path.size) end,
                  right = function(path) return vector:new(path.start.x + path.size, path.start.y) end,
                  down =  function(path) return vector:new(path.start.x, path.start.y + path.size) end}
solver.relevantEnd = {left = function(path) return solver.pathEnds[path.type](path).x end,
                     up   = function(path) return solver.pathEnds[path.type](path).y end,
                     right = function(path) return solver.pathEnds[path.type](path).x end,
                     down = function(path) return solver.pathEnds[path.type](path).y end}
solver.otherEnd = {left = function(path) return solver.pathEnds[path.type](path).y end,
                  up   = function(path) return solver.pathEnds[path.type](path).x end,
                  right = function(path) return solver.pathEnds[path.type](path).y end,
                  down = function(path) return solver.pathEnds[path.type](path).x end}

function solver:enableFeature(featurename)
  if self.features[featurename] then
    table.insert(self.enabledfeatures, self.features[featurename])
    self.features[featurename] = nil
  end
end

function solver:Done(path, requireddir)
  if requireddir == 'left' or requireddir == 'up' then
    return solver.relevantEnd[path.type](path) <= solver.dirRequirements[requireddir]
  else
    return solver.relevantEnd[path.type](path) >= solver.dirRequirements[requireddir]
  end
end

function solver:buildTunnel(requirements)
  local path = {}
  if not requirements.start then
    return false
  end
  if requirements.requiredPath then
    if requirements.requiredPath.type == 'horizontal' then
      local type = 'left'
      if requirements.startSide == 'left' then
        type = 'right'
      end
      path = pathSection:new(math.random(3)-1+requirements.start.x, math.random(maxHeight-2)+1,
                             requirements.requiredPath.size, type)  
    elseif requirements.requiredPath.type == 'vertical' then
      local type = 'up'
      if requirements.startSide == 'up' then
        type = 'down'
      end
      path = pathSection:new(math.random(maxWidth-2)+1, math.random(3)-1+requirements.start.y,
                             requirements.requiredPath.size, type)
    end
  else
    print('start side '..requirements.startSide)
    path = self:buildPath(requirements.start.x, requirements.start.y, requirements.startSide, 2)
  end
  local firstPath = path
  local exitPaths = {}
  if #requirements.endDir > 1 then
    print('multiple exits!')
  end
  for i, goal in ipairs(requirements.endDir) do
    path = firstPath
    local towardsGoal = goal.dir
    if goal.endloc then
      print('this has a requirement!')
    end
    local goalvec = self:determineEndLoc(towardsGoal, goal.endloc or math.random(maxHeight/3)+maxHeight/3)
    local newpath, adjust, nextpath = {}, {}, {}
    local start = self.pathEnds[path.type](path)
    print(start, goalvec)
    print(path.type)
    if path.type == 'left' or path.type == 'right' then
      newpath = self:buildPath(start.x, start.y, path.type, 0, math.floor(math.abs(goalvec.x-start.x)/2))
    else
      newpath = self:buildPath(start.x, start.y, path.type, 0, math.floor(math.abs(goalvec.y-start.y)/2))
    end
    start = self.pathEnds[newpath.type](newpath)
    if towardsGoal == 'left' or towardsGoal == 'right' then
      if start.y ~= goalvec.y then
        adjust = self:buildPath(start.x, start.y, towardsGoal, 
                -(self.directionsOp[towardsGoal]-2)*(start.y-goalvec.y)/math.abs(start.y-goalvec.y), 
                math.abs(start.y-goalvec.y))
      else
        adjust = self:buildPath(start.x, start.y, towardsGoal, 0, math.abs(start.y-goalvec.y))
      end
      start = self.pathEnds[adjust.type](adjust)
      nextpath = self:buildPath(start.x, start.y, towardsGoal, 0, math.abs(goalvec.x-start.x))
    else
      if start.x ~= goalvec.x then
        adjust = self:buildPath(start.x, start.y, towardsGoal, 
                (self.directionsOp[towardsGoal]-3)*(start.x-goalvec.x)/math.abs(start.x-goalvec.x), 
                 math.abs(start.x-goalvec.x))
      else
        adjust = self:buildPath(start.x, start.y, towardsGoal, 0, math.abs(start.x-goalvec.x))
      end
      start = self.pathEnds[adjust.type](adjust)
      nextpath = self:buildPath(start.x, start.y, towardsGoal, 0, math.abs(goalvec.y-start.y))
    end
    path:setNext(newpath)
    newpath:setNext(adjust)
    adjust:setNext(nextpath)
    adjust:setPrevious(newpath)
    nextpath:setPrevious(adjust)
    newpath:setPrevious(path)
    print(newpath)
    print(nextpath)
    nextpath.endPath = true
    table.insert(exitPaths, nextpath)
  end
  local blueprint = {row = {}, col = {}, full = {}}
  for i=0, maxWidth do
    blueprint.full[i] = {}
    blueprint.row[i] = {}
    blueprint.col[i] = {}
    for j=0, maxHeight do
      blueprint.full[i][j] = 'full'
    end
  end
  self:addFeatures(firstPath)
  firstPath:clearPath(blueprint)
  self:closeWalls(blueprint, firstPath)
  lines = pathanalyzer.findUnreachablePlatforms(blueprint)
  local returnLocs = {}
  for i,exitpath in ipairs(exitPaths) do
    returnLocs[exitpath.type] = self.pathEnds[exitpath.type](exitpath)
  end
  return blueprint, returnLocs, lines
end

function solver:addFeatures(firstPath)
  local pathQueue = {}
  local usableFeatures = {}
  for i,feature in ipairs(self.enabledfeatures) do
    table.insert(usableFeatures, feature)
  end
  for i,npath in ipairs(firstPath.next) do
    table.insert(pathQueue, npath)
  end
  local path = {}
  if #pathQueue > 0 then
    path = pathQueue[1]
  end
  while #pathQueue > 0 do
    if --[[math.random(2) == 1 and]] #usableFeatures > 0 then
      local featureNumber = math.random(#usableFeatures)
      if usableFeatures[featureNumber](self, path) then
        table.remove(usableFeatures, featureNumber)
      end
    end
    table.remove(pathQueue, 1)
    for i,npath in ipairs(path.next) do
      table.insert(pathQueue, npath)
    end
    if #pathQueue > 0 then
      path = pathQueue[1]
    end
  end
  return
end

function solver:determineEndLoc(dir, sideloc)
  if dir == 'left' then
    return vector:new(0, sideloc)
  elseif dir == 'right' then
    return vector:new(maxWidth, sideloc)
  elseif dir == 'up' then
    return vector:new(sideloc, 0)
  elseif dir == 'down' then
    return vector:new(sideloc, maxHeight)
  end
end

function solver:buildRoom(requirements)
  local blueprint = {row = {}, col = {}, full = {}}
  for i=0, maxWidth do
    blueprint.full[i] = {}
    blueprint.row[i] = {}
    blueprint.col[i] = {}
  end
  for i=0,maxWidth do
    blueprint.row[i][0] = 'top'
    blueprint.row[i][maxHeight-1] = 'bottom'
  end
  for i=0,maxHeight do
    blueprint.col[0][i] = 'left'
    blueprint.col[maxWidth-1][i] = 'right'
  end
  if requirements.startSide == 'left' then
    for i=requirements.start.y-2,requirements.start.y+1 do
      blueprint.col[0][i] = nil
    end
  end
  if requirements.startSide == 'right' then
    for i=requirements.start.y-2,requirements.start.y+1 do
      blueprint.col[maxWidth-1][i] = nil
    end
  end
  if requirements.startSide == 'up' then
    for i=requirements.start.x-1,requirements.start.x+2 do
      if blueprint.row[i] then
        blueprint.row[i][0] = nil
      end
    end
    for i=4,maxWidth do
      blueprint.row[i][3] = 'bottom'
    end
    blueprint.row[requirements.start.x+2][1] = 'bottom'
    blueprint.row[3][4] = 'bottom'
  end
  if requirements.startSide == 'down' then
    for i=requirements.start.x-1,requirements.start.x+2 do
      if blueprint.row[i] then
        blueprint.row[i][maxHeight-1] = nil
      end
    end
  end
  for i=math.floor(maxWidth/3)-1,math.floor(maxWidth*2/3) do
    for j=math.floor(maxHeight*2/3), maxHeight-3 do
      blueprint.full[i][j] = 'full'
    end
  end
  return blueprint, {}
end

function solver:closeWalls(blueprint, path)
  local paths = {path}
  local pathsToClearAgain = {}
  local pit, pathonbottom = false, false
  while #paths > 0 do
    local npath = paths[1]
    if npath.is == 'pit' then
      pit = true
    end
    if npath.type == 'down' and npath.start.y+npath.size >= maxHeight or
       npath.type == 'up'   and npath.start.y >= maxHeight then
         pathonbottom = true
         table.insert(pathsToClearAgain, npath)
    end
    table.remove(paths, 1)
    for i,opath in ipairs(npath.next) do
      table.insert(paths, opath)
    end
  end
  if pit and pathonbottom then
    for i=0,maxWidth do
      blueprint.full[i][maxHeight] = 'full'
      blueprint.full[i][maxHeight-1] = 'full'
    end
    for i,npath in ipairs(pathsToClearAgain) do
      npath:clearOnlyThisPath(blueprint)
    end
  end
end

function solver:buildChallenge1(requirements)
  local firstPath, exitPaths = extrarooms.zigzag(self, requirements.start.x)
  local blueprint = {row = {}, col = {}, full = {}}
  for i=0, maxWidth do
    blueprint.full[i] = {}
    blueprint.row[i] = {}
    blueprint.col[i] = {}
    for j=0, maxHeight do
      blueprint.full[i][j] = 'full'
    end
  end
  self:addFeatures(firstPath)
  firstPath:clearPath(blueprint)
  self:closeWalls(blueprint, firstPath)
  lines = pathanalyzer.findUnreachablePlatforms(blueprint)
  local returnLocs = {}
  for i,exitpath in ipairs(exitPaths) do
    returnLocs[exitpath.type] = self.pathEnds[exitpath.type](exitpath)
  end
  return blueprint, returnLocs, lines
end

function solver:buildPath(x, y, dir, rotAmount, distance)
  local dirnum = 0
  local size = 0
  if not distance then
    if (dirnum+rotAmount)%2 == 1 then
      size = math.random(self.horzMinLen, self.horzMaxLen)
    else
      size = math.random(self.vertMinLen, self.vertMaxLen)
    end
  else
    size = distance
  end
  for num, type in ipairs(self.directions) do
    if type == dir then
      dirnum = num
      break
    end
  end
  local newdir = self.directions[(rotAmount+dirnum-1)%4+1]
  if not newdir then
    print('not right!')
  end
  return pathSection:new(x, y, size, newdir)
end

function solver:getOppositeDirection(dir)
  local dirnum = 0
  for num, type in ipairs(directions) do
    if type == dir then
      dirnum = num
      break
    end
  end
  if dirnum==0 then return 'ValidDirectionNotGiven' end
  return directions[dirnum+2%4]
end

return solver

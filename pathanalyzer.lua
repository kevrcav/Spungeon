local listfunctions = require 'listfunctions'
local sortedlist = require 'sortedlist'
local constants = require 'constants'
local pathanalyzer = {}
local maxHeight = constants.HEIGHT/50
local maxWidth = constants.WIDTH/50

local ops = {left='right', right='left', up='down', down='up'}

function pathanalyzer.findUnreachablePlatforms(blueprint)
  local startLoc = {x = 0, y = 0}
  for i=0,maxWidth do
    for j=0,maxHeight do
      if  (blueprint.full[i] and not blueprint.full[i][j]) 
      and (blueprint.row[i] and not blueprint.row[i][j]) then
        startLoc = {x = i, y = j}
        break
      end
    end
  end
  local openNodes = {startLoc}
  local searchedNodes = {}
  while #openNodes > 0 do
    local currentNode = openNodes[1]
    pathanalyzer.connectNode(blueprint, openNodes, searchedNodes, currentNode, 'right', currentNode.x+1, currentNode.y)
    pathanalyzer.connectNode(blueprint, openNodes, searchedNodes, currentNode, 'left', currentNode.x-1, currentNode.y)
    pathanalyzer.connectNode(blueprint, openNodes, searchedNodes, currentNode, 'down', currentNode.x, currentNode.y+1)
    pathanalyzer.connectNode(blueprint, openNodes, searchedNodes, currentNode, 'up', currentNode.x, currentNode.y-1)
    table.remove(openNodes, 1)
    table.insert(searchedNodes, currentNode)
  end
  local platforms = pathanalyzer.findPlatforms(searchedNodes)
  local entrances = pathanalyzer.findEntrances(searchedNodes)
  if pathanalyzer.connectEntrancesToPlatforms(platforms, entrances, searchedNodes) then
    for i,platform in ipairs(platforms) do
      if blueprint.full[platform.start.x] 
 and not blueprint.full[platform.start.x][platform.start.y] then
        blueprint.row[platform.start.x][platform.start.y] = 'bottom'
      end
    end
  end
  --connectPlatforms(platforms, searchedNodes)
  return pathanalyzer.printBlueprintInfo(searchedNodes)
end

function pathanalyzer.connectEntrancesToPlatforms(platforms, entrances, searchedNodes)
  local lenPlats = #platforms
  table.foreach(entrances, function(i, entrance)
    local closestplatform = {}
    local closestDistance = math.huge
    local closestNode = {}
    local closestPath = {}
    for i, platform in ipairs(platforms) do
      local dist, cnode, path = pathanalyzer.platformDistance(entrance, platform)
      if  dist < closestDistance then
        closestPlatform = platform
        closestDistance = dist
        closestNode = cnode
        closestPath = path
      end
    end
    if closestDistance > 2 then
      pathanalyzer.connectPlatformAndEntrance(platforms, closestPath)
    end
  end)
  local newLenPlats = #platforms
  return newLenPlats > lenPlats 
end

function pathanalyzer.connectPlatformAndEntrance(platforms, path)
  local numberToAdd = math.floor(#path / 3)
  for i=1,numberToAdd do
    local placeToPlace = path[#path+1-i*3]
    local leftNoise, rightNoise = 0, 0
    if placeToPlace.left then leftNoise = -1 end
    if placeToPlace.right then rightNoise = 1 end
    local noise = math.random(1+rightNoise-leftNoise)-1+leftNoise
    table.insert(platforms, {start = {x = placeToPlace.x+noise, y = placeToPlace.y}, size = 1})
  end
end

function pathanalyzer.platformDistance(entrance, platform)
  local closestDistance = math.huge
  local closestNode = {}
  local pathToPlat = {}
  table.foreach(entrance, function(i, node) 
    local dist, path = pathanalyzer.searchForPlatform(node, platform)
    if dist < closestDistance then
      closestDistance = dist
      closestNode = node
      pathToPlat = path
    end
  end)
  return closestDistance, closestNode, pathToPlat
end

function pathanalyzer.searchForPlatform(node, platform)
  local searchedNodes = {}
  local distance = math.huge
  local nodesToSearch = sortedlist:new()
  local currentNode = node
  local path = {}
  currentNode.distanceTravelled = 0
  local searching = true
  while searching do
    if currentNode.y + 1 == platform.start.y 
   and currentNode.x >= platform.start.x 
   and currentNode.x <= platform.start.x+platform.size then
      distance = currentNode.distanceTravelled
      currentNode.distanceTravelled = nil
      searching = false
      path = {}
      local lastNode = currentNode
      local stillLooking = true
      while lastNode do
        table.insert(path, 1, lastNode)
        local nextLastNode = lastNode.lastNodeInPath
        lastNode.lastNodeInPath = nil
        lastNode = nextLastNode
      end
    else
      if currentNode.down 
     and not listfunctions.contains(searchedNodes, currentNode.down) 
     and not nodesToSearch:contains(currentNode.down) then
        currentNode.down.distanceTravelled = currentNode.distanceTravelled+1
        nodesToSearch:insert(currentNode.down.distanceTravelled
                           + pathanalyzer.distancetToPlat(currentNode.down, platform), currentNode.down)
        currentNode.down.lastNodeInPath = currentNode
      end
      if currentNode.up 
 and not listfunctions.contains(searchedNodes, currentNode.up)
 and not nodesToSearch:contains(currentNode.up) then
        currentNode.up.distanceTravelled = currentNode.distanceTravelled+1
        nodesToSearch:insert(currentNode.up.distanceTravelled
                           + pathanalyzer.distancetToPlat(currentNode.up, platform), currentNode.up)
        currentNode.up.lastNodeInPath = currentNode
      end
      if currentNode.left 
 and not listfunctions.contains(searchedNodes, currentNode.left)
 and not nodesToSearch:contains(currentNode.left) then
        currentNode.left.distanceTravelled = currentNode.distanceTravelled+1
        nodesToSearch:insert(currentNode.left.distanceTravelled
                           + pathanalyzer.distancetToPlat(currentNode.left, platform), currentNode.left)
        currentNode.left.lastNodeInPath = currentNode
      end
      if currentNode.right 
 and not listfunctions.contains(searchedNodes, currentNode.right)
 and not nodesToSearch:contains(currentNode.right) then
        currentNode.right.distanceTravelled = currentNode.distanceTravelled+1
        nodesToSearch:insert(currentNode.right.distanceTravelled
                           + pathanalyzer.distancetToPlat(currentNode.right, platform), currentNode.right)
        currentNode.right.lastNodeInPath = currentNode
      end
      table.insert(searchedNodes, currentNode)
      if nodesToSearch:__len() == 0 then
        searching = false
      else
        currentNode = nodesToSearch:pop(1)
      end
    end
  end
  for i,snode in ipairs(searchedNodes) do
    snode.distanceTravelled = nil
    snode.lastNodeInPath = nil
  end
  for i,snode in ipairs(nodesToSearch.list) do
    snode.distanceTravelled = nil
    snode.lastNodeInPath = nil
  end
  return distance, path
end

function pathanalyzer.distancetToPlat(node, platform)
  local y = math.abs(node.y-platform.start.y)
  local x = 0
  if node.x < platform.start.x then
    x = platform.start.x - node.x
  elseif node.x > platform.start.x+platform.size then
    x = node.x - platform.start.x-platform.size
  end
  return x+y
end

--gives the platforms in the given graph
function pathanalyzer.findPlatforms(nodes)
  local platformChunks = {}
  table.foreach(nodes, function(i, node)
    if not node.down and node.y < maxHeight then
      platformChunks[node.y+1] = platformChunks[node.y+1] or {}
      table.insert(platformChunks[node.y+1], node.x)
    end
  end)
  local platforms = {}
  for y, row in pairs(platformChunks) do
    local platformsInRow = {}
    for i,x in ipairs(row) do
      local platExists = false
      table.foreach(platformsInRow, function(j, plat)
        if x+1 == plat.start then
          plat.start=plat.start-1
          plat.size=plat.size+1
          platExists = true
        elseif plat.start+plat.size == x then
          plat.size=plat.size+1
          platExists = true
        end
      end)
      if not platExists then
        table.insert(platformsInRow, {start = x, size = 1})
      end
    end
    for i,platform in ipairs(platformsInRow) do
      table.insert(platforms, {start = {x = platform.start, y = y}, size = platform.size})
    end
  end
  return platforms
end

function pathanalyzer.findEntrances(nodes)
  local entrance = {}
  table.foreach(nodes, function(i, node)
    if node.entrance and not node.entranceAdded then
      table.insert(entrance, pathanalyzer.searchForEntrance(node))
    end
  end)
  return entrance
end

function pathanalyzer.searchForEntrance(node)
  node.entranceAdded = true
  local entrance = {node}
  if node.down and node.down.entrance and not node.down.entranceAdded then
    for i, dnode in ipairs(pathanalyzer.searchForEntrance(node.down)) do
      table.insert(entrance, dnode)
    end
  end
  if node.up and node.up.entrance and not node.up.entranceAdded then
    for i, unode in ipairs(pathanalyzer.searchForEntrance(node.up)) do
      table.insert(entrance, unode)
    end
  end
  if node.left and node.left.entrance and not node.left.entranceAdded then
    for i, lnode in ipairs(pathanalyzer.searchForEntrance(node.left)) do
      table.insert(entrance, lnode)
    end
  end
  if node.right and node.right.entrance and not node.right.entranceAdded then
    for i, rnode in ipairs(pathanalyzer.searchForEntrance(node.right)) do
      table.insert(entrance, rnode)
    end
  end
  return entrance
end

function pathanalyzer.connectNode(blueprint, openNodes, searchedNodes, baseNode, direction, searchX, searchY)
  if searchX > maxWidth or searchX < 0 or searchY > maxHeight or searchY < 0 then
    baseNode.entrance = true
    return
  end
  if blueprint.full[searchX] and not blueprint.full[searchX][searchY] then
    local alreadySearched = pathanalyzer.getNode(searchX, searchY, openNodes)
                         or pathanalyzer.getNode(searchX, searchY, searchedNodes)
    if alreadySearched then
      baseNode[direction] = alreadySearched
      alreadySearched[ops[direction]] = baseNode
    else
      table.insert(openNodes, {x = searchX, y = searchY})
    end
  elseif blueprint.full[searchX] and blueprint.full[searchX][searchY] and direction == 'down' then
    baseNode.ground = true
  end
end

function pathanalyzer.getNode(x, y, nodes)
  for i,node in ipairs(nodes) do
    if node.x == x and node.y == y then
      return node
    end
  end
  return nil
end

function pathanalyzer.printBlueprintInfo(nodes)
  local lines = {}
  for j=0,maxHeight do
    lines[j] = ''
    for i=0, maxWidth do
      local node = pathanalyzer.getNode(i, j, nodes)
      if node then
        if node.entrance then
          lines[j] = lines[j]..'='
        elseif node.ground then
          lines[j] = lines[j]..'~'
        else
          lines[j] = lines[j]..'+'
        end
      else
        lines[j] = lines[j]..'#'
      end
    end
  end
  return lines
end

return pathanalyzer

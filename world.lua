local tile = require 'tile'
local backgroundgen = require 'backgroundgen'
local event = require 'engine/event'
local Socket = require'socket'
local Player = require'player'
local Vector = require'engine/vector'
local Level = require'level'
local constants = require'constants'
local Adjuster = require'varadjuster'
local Generator = require'generator'
local TestGenerator = require'testgenerator'
local listener = require'engine/listener'
local eventmanager = require'engine/eventmanager'

local World = {
  entities = {},
  sliders = {},
  player,
  level = Level:newEmpty(),
  textOpacity = 0,
  showMap = false,
  toDelete = {}
}
local t = socket.gettime()
local gameTime = 0
local curTime = 0
local bigFont
local smallFont

function World:load() 
  love.window.setMode(constants.WIDTH,constants.HEIGHT)
  love.graphics.setBackgroundColor(150, 180, 180)
  bigFont = love.graphics.newFont(50)
  smallFont = love.graphics.newFont(12)
  Player:load()
  self.player = Player:new(Vector:new(constants.WIDTH/2, constants.HEIGHT/2), {1, 2, 1, 8})
  --[[ONLY IMPORTANT THING ABOUT THE WORLD FOR THE GAME AI ASSIGNMENT:
      change os.time() to change the seed]]
  Generator:Init(os.time())
  self.background = backgroundgen:makeStars()
  generatedLevel, offsetX, offsetY = Generator:GenerateWorld(20)
  self.level = Level:new(generatedLevel, Vector:new(offsetX, offsetY))
  Generator:makePlatforms(self.level.rooms, offsetX, offsetY)
  self.level:RegisterHitboxes()
  --[[jumpSlider = Adjuster:new(constants.WIDTH/8, 50, 50, "Jump Height", constants.INIT_JUMP_HEIGHT)
  table.insert(World.sliders, jumpSlider)
  speedSlider = Adjuster:new(constants.WIDTH/8, 100, 50, "Speed", constants.INIT_MAX_SPEED)
  table.insert(World.sliders, speedSlider)
  accelSlider = Adjuster:new(constants.WIDTH/8, 150, 50, "Acceleration", constants.INIT_ACCELERATION)
  table.insert(World.sliders, accelSlider)
  frictionSlider = Adjuster:new(constants.WIDTH/8, 200, 50, "Friction", constants.INIT_FRICTION)
  table.insert(World.sliders, frictionSlider)
  angleSlider = Adjuster:new(constants.WIDTH/8, 250, 50, "Wall Jump Angle", constants.INIT_WALL_JUMP_ANGLE)
  table.insert(World.sliders, angleSlider)]]
  eventmanager:registerListener("ControllerStartEvent", 
                                listener:new(self, self.switchMap))
  eventmanager:registerListener("TransitionPlayerEvent", 
                                listener:new(self, self.transitionPlayer))
  eventmanager:registerListener("DeleteEntityEvent",
                                listener:new(self, self.entityToDelete))
  return
end

function World:switchMap(event)
  self.showMap = not self.showMap  
end

function World:transitionPlayer(event)
  self.level:switchRooms(self.player)
end

function World:entityToDelete(event)
  table.insert(self.toDelete(event.itemToDelete))
end

function World:update(dt)
  UEvent = event:new("UpdateEvent")
  UEvent.dt = dt
  eventmanager:sendEvent(UEvent)
  --[[
  newT = socket.gettime()
  deltaT = newT-t
  t = newT
  gameTime = gameTime + deltaT
  for i, e in ipairs(self.entities) do
    if e.isActive then
      e:update(self.level.currentRoom.platforms, self.entities, deltaT)
    end
  end
  self.player:update(self.level.currentRoom.platforms, self.entities, deltaT)
  self.player:checkPowerups(self.level.currentRoom.powerups)
  local i = 1
  while i <= #self.entities do
    if self.entities[i].toDelete then
      table.remove(self.entities, i)
    else
      i = i+1
    end
  end
  self.level:update()]]
  --[[constants.JUMP_HEIGHT = jumpSlider:update()
  constants.MAX_SPEED = speedSlider:update()
  constants.FRICTION = frictionSlider:update()
  constants.ACCELERATION = accelSlider:update()
  constants.WALL_JUMP_ANGLE = angleSlider:update()]]
end

function World:draw()
  love.graphics.draw(self.background)
  self.level:draw()
  self.player:draw()
  self.level:drawMap()
end

function World:quit()
  love.filesystem.setIdentity("METUROIDO")
  --[[
  if love.filesystem.exists("data.txt") then
    curData = love.filesystem.read("data.txt")
    file = love.filesystem.newFile("data.txt")
    file:open("w")
    file:write(curData)
    file:write(tostring(constants.JUMP_HEIGHT)..";"..
               tostring(constants.MAX_SPEED)..";"..
               tostring(constants.FRICTION)..";"..
               tostring(constants.ACCELERATION)..";"..
               tostring(constants.WALL_JUMP_ANGLE)..";".."\r\n")
    file:close()
  else
    saveData = jumpSlider.name..";"..speedSlider.name..";"..frictionSlider.name..";"..accelSlider.name..";"..angleSlider.name.."\r\n"..
               tostring(constants.JUMP_HEIGHT)..";"..
               tostring(constants.MAX_SPEED)..";"..
               tostring(constants.FRICTION)..";"..
               tostring(constants.ACCELERATION)..";"..
               tostring(constants.WALL_JUMP_ANGLE)..";".."\r\n"
    fileTime = os.date("%Y-%m-%d-%H-%M-%S")
    name = "data"..fileTime....".txt"
    file = love.filesystem.newFile(name)
    file:open("w")
    file:write(saveData)
    file:close()
  end]]
end

return World
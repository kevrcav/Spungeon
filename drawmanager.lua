local drawmanager = {layers = {}}

-- registers an object with a draw method that takes no arguments on the given layer
function drawmanager:registerdrawable(layer, drawable)
  if layer < 10 then
    self.layers[self.activeroom][layer] = self.layers[self.activeroom][layer] or {}
    table.insert(self.layers[layer], drawable)
  else
    self.layers[self.activeroom].foreground = self.layers[self.activeroom].foreground or {}
    table.insert(self.layers[self.activeroom].foreground[layer-10], drawable)
  end
end

function drawmanager:setdefaultbackground(background)
  self.dbackground = background
end

function drawmanager:registerplayerdrawable(layer, player)
  self.player = {model = player, layer = layer}
end

function drawmanager:switchroom(x, y)
  self.activeroom = 2^x*3^y
end

function drawmanager:draw()
  self.dbackground:draw()
  for i, layer in ipairs(self.layers[self.activeroom]) do
    for j,drawable in ipairs(layer) do
      drawable:draw()
    end
  end
  self.player.model:draw()
  if self.layers[self.activeroom].foreground then
    for i,layer in ipairs(self.layers[self.activeroom].foreground) do
      for j,drawable in ipairs(layer) do
        drawable:draw()
      end
    end
  end
end

return drawmanager
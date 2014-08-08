--local constants = require 'constants'
function love.conf(t)
	t.window.width = 800
	t.window.height = 600
	t.window.title = "Space Dungeon"
	t.window.vsync = true
	t.window.fullscreen= false
	t.window.fsaa = 0
	t.console = false
	t.release = false
end

local gui = require 'Quickie'

Gui = {}

function Gui:load()
	self.parametrables = {}
	gui.group.default.size = {150,10}
	gui.group.default.spacing = 3
end

function Gui:title(text)
	love.graphics.setFont(MediumFont)
	gui.group.push{grow = "down", spacing=10}
	gui.Label{text = ""}
	gui.Label{text = text}
	gui.group.pop{}
	gui.Label{text = ""}
end

function Gui:update(dt)
	gui.group.push{grow = "down", pos = {5,5}}
	love.graphics.setFont(SmallFont)
	gui.Label{text = "Press left control to open and close this GUI"}
	gui.Label{text = "FPS : "..tostring(love.timer.getFPS())}
	
	gui.Checkbox{info=GlobalParameters.autoReload}
	if not GlobalParameters.autoReload.checked then
		gui.group.push{grow = "down", size = {200,20}}
		if gui.Button{text = "Reload"} then
			currFractal:reload()
		end
		gui.group.pop{}
	end
	
	for _,parametrable in pairs(self.parametrables) do
		if parametrable.title then Gui:title(parametrable.title) end
		love.graphics.setFont(SmallFont)
		for _,parameter in pairs(parametrable.parameters) do
			parameter:quickieUpdate(gui,true)
		end
	end

	gui.group.pop{}
end

function Gui:draw()
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle("fill",0,0,260,Height)
	gui.core.draw()
end

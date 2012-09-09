local gui = require 'Quickie'

Gui = {}

function Gui:load()
	self.parametrables = {}
	gui.group.default.size = {150,10}
	gui.group.default.spacing = 3
end

function Gui:drawParameter(parameter)
	gui.group.push{grow = "right"}
	gui.Slider{info = parameter}
	gui.Label{text = string.format("%.2f",parameter.value), size = {50,10}}
	gui.group.pop{}
end

function Gui:title(text)
	gui.group.push{grow = "down", spacing=10}
	gui.Label{text = ""}
	gui.Label{text = text}
	gui.group.pop{}
	gui.Label{text = ""}
end

function Gui:update(dt)
	gui.group.push{grow = "down", pos = {5,5}}
	
	for _,parametrable in pairs(self.parametrables) do
		Gui:title(parametrable.title)
		for _,parameter in pairs(parametrable.parameters) do
			parameter:quickieUpdate(gui,true)
		end
	end
end

function Gui:draw()
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle("fill",0,0,260,Height)
	gui.core.draw()
end

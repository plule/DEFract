require "hump.class"
local gui = require 'Quickie'

Gui = Class{
	function(self)
		self.parameters = {}
		self.dimensions = {150,10}
		gui.group.default.size = self.dimensions
		gui.group.default.spacing = 3
	end}

function Gui:drawParameter(parameter)
	gui.group.push{grow = "right"}
	gui.Slider{info = parameter}
	gui.Label{text = string.format("%.2f",parameter.value), size = {50,10}}
	gui.group.pop{}
end	

function Gui:update(dt)
	gui.group.push{grow = "down", pos = {5,5}}
	for name,parameter in pairs(self.parameters) do
		if parameter.type == "float" then
			gui.Label{text = name}
			self:drawParameter(parameter)
		elseif parameter.type == "vec3" then
			gui.Label{text = name}
			for _,param in ipairs(parameter.values) do
				self:drawParameter(param)
			end
		end
	end
	gui.group.pop{}
end

function Gui:draw()
	love.graphics.setColor(0,0,0,200)
	love.graphics.rectangle("fill",0,0,260,Height)
	gui.core.draw()
end

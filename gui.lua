require "hump.class"
local gui = require 'Quickie'

Gui = Class{
	function(self)
		self.parameters = {}
		self.camera = {}
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

function no()
	Gui:title("Parameters of the Fractal")
	for _,parameter in pairs(self.fractal) do end

	-- Camera parameters
	if self.camera then
		Gui:title("Parameters of the Camera")

		gui.Label{text = "Speed"}
		self:drawParameter(self.camera.speed)

		gui.Label{text = "SpeedMultiplier"}
		self:drawParameter(self.camera.speedMultiplier)

		gui.Label{text = "SpeedMultiplier2"}
		self:drawParameter(self.camera.speedMultiplier2)

		gui.Label{text = "Projection Distance"}
		self:drawParameter(self.camera.projDist)

		Gui:title("Rendering parameters")

		gui.Label{text = "Max number of iterations"}
		self:drawParameter(self.camera.maxIterations)

		gui.Label{text = "Threshold"}
		self:drawParameter(self.camera.threshold)

		gui.Label{text = "ThresholdMultiplier"}
		self:drawParameter(self.camera.thresholdMultiplier)

		gui.Label{text = "Color mode"}
		gui.group.push{grow = "down", size = {150,20}}
		for name,colorChoice in pairs(self.camera.coloring.choices) do
			if gui.Button{text = name} then
				self.camera:setColorMode(colorChoice)
			end
		end
		gui.group.pop{}

	end

	-- Fractal parameters
	Gui:title("Parameters of the Fractal")
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
	--]]
	gui.group.pop{}
end

function Gui:draw()
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle("fill",0,0,260,Height)
	gui.core.draw()
end

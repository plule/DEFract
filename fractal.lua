Class = require "hump.class"
require "parser"
require "camera"
require "parameter"

Fractal = Class{
	function(self, path)
		self.path = path
		self.lastModif = love.filesystem.getLastModified(self.path)
		self.lastCheckAge = 0
		self.time = 0
		self.error = "No shader generated"
		self.title = "Parameters of the Fractal"
		self.parameters = {}
		self:load()
	end}

function Fractal:load()
	local fractal = Parser.computeFractalCode(self.path, Camera.parameters.coloring:getValue())
	self.shader = love.graphics.newPixelEffect(fractal.code)
	self.error = nil
	self.animated = fractal.animated
	self.parameters = fractal.parameters
	self.name = fractal.name
	self.description = fractal.description
	Camera:update(unpack(fractal.positions[1]))
	self.error = nil
end

function Fractal:reload()
	local fractal = Parser.computeFractalCode(self.path, Camera.parameters.coloring:getValue())
	self.shader = love.graphics.newPixelEffect(fractal.code)
	self.error = nil
	self.animated = fractal.animated
	self.name = fractal.name
	self.description = fractal.description
	for _,newParameter in pairs(fractal.parameters) do
		for _,oldParameter in pairs(self.parameters) do
			if newParameter.shader and newParameter.kname == oldParameter.kname and newParameter.type == oldParameter.type then
				newParameter:setValue(oldParameter:getValue(true))
			end
		end
	end
	
	self.parameters = fractal.parameters
	self.error = nil
end

function Fractal:update(dt)
	self.time = self.time+dt
	
	if GlobalParameters.autoReload.checked then
		self.lastCheckAge = self.lastCheckAge+dt
		if self.lastCheckAge >= 0.5 then
			self.lastCheckAge = 0
			if self.lastModif ~= love.filesystem.getLastModified(self.path) then
				lastModif = love.filesystem.getLastModified(self.path)
				self:reload()
			end
		end
	end
end

function Fractal:send(parameters)
	local shader = self.shader
	for _,parameter in pairs(parameters) do
		if parameter.kname then
			debug("sending "..parameter:to_s())
			shader:send(parameter.kname, parameter:getValue())
		end
	end
end

function Fractal:draw()
	debug("==================== DRAWING FRACTAL ========================")
	debug("=============================================================")
	if not self.error then
		local shader = self.shader
		local camera = Camera
		debug("Sending fractal parameters")
		self:send(self.parameters)
		debug("Sending camera parameters")
		self:send(camera.parameters)
		shader:send("position", camera:getPosition():table())
		shader:send("origin", camera:getOrigin():table())
		shader:send("planex", camera:getPlaneX():table())
		shader:send("planey", camera:getPlaneY():table())
		if self.animated then
			shader:send("time", self.time)
		end

		love.graphics.setPixelEffect(self.shader)
		love.graphics.setColor(0,0,0,255)
		love.graphics.rectangle("fill",0,0,Width,Height)		
		love.graphics.setPixelEffect()
--		camera:draw()
	else
		love.graphics.setPixelEffect()
		love.graphics.setColor(255,255,255)
		love.graphics.print("Error in fractal code",0,0)
		love.graphics.print(self.error,0,15)
	end
end

function Fractal:to_s()
	print(self.name)
	print(self.description)
	print("Parameters :")
	for name,desc in pairs(self.parameters) do
		print(name.." : "..desc.type)
	end
	print("Code :")
	print(self.code)
end

function string:split(sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

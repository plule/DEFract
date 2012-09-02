require "hump.class"
require "render"
require "camera"

Fractal = Class{
	function(self, path)
		self.path = path
		self.lastModif = love.filesystem.getLastModified(self.path)
		self.lastCheckAge = 0
		self.time = 0
		self.error = "No shader generated"
		self:parse()
		self:generateShader()
		self.camera = Camera(unpack(self.positions[1]))
	end}

function Fractal:generateShader()
	self.animated = false
	local shaderCode = render.computeFractalCode(self.code, Width, Height, false)
	self.shader = love.graphics.newPixelEffect(shaderCode)
	self.error = nil
--todo
end

function Fractal:parse()
	local file = love.filesystem.newFile(self.path)
	file:open('r')
	local code = ""
	local parameters = {}
	local positions = {}
	self.animated = false
	for line in file:lines() do
		local key,value = string.match(line, "#(%w+)%s(.+)")
		if key == "name" then
			self.name = value
		elseif key == "description" then
			self.description = value
		elseif key == "extern" then
			local splitValue = value:split(";")
			parameters[splitValue[1]] = {
				value = tonumber(splitValue[2]),
				min = tonumber(splitValue[3]),
				max = tonumber(splitValue[4]),
				step = tonumber(splitValue[5])
			}
			code = code.."extern float "..splitValue[1]..";\n"
		elseif key == "view" then
			local splitValue = value:split(";")
			local position = {
				tonumber(splitValue[1]), -- x
				tonumber(splitValue[2]), -- y
				tonumber(splitValue[3]), -- z
				tonumber(splitValue[4]), -- speed
				tonumber(splitValue[5]), -- theta
				tonumber(splitValue[6]), -- phi
				tonumber(splitValue[7]), -- projDist
				tonumber(splitValue[8]), -- threshold
				tonumber(splitValue[9])  -- maxIterations
			}
			table.insert(positions, position)
		elseif key == "threshold" then
			self.threshold = tonumber(value)
		else
			code = code..line.."\n"
		end
	end
	file:close()

	self.code = code
	self.parameters = parameters
	self.positions = positions
end

function Fractal:update(dt)
	self.lastCheckAge = self.lastCheckAge+dt
	self.time = self.time+dt
	if self.lastCheckAge >= 0.5 then
		self.lastCheckAge = 0
		if self.lastModif ~= love.filesystem.getLastModified(self.path) then
			lastModif = love.filesystem.getLastModified(self.path)
			self:parse()
			self:generateShader()
		end
	end
end

function Fractal:draw(camera)
	if not self.error then
		local shader = self.shader
		local camera = self.camera
		for name,desc in pairs(self.parameters) do
			shader:send(name, desc.value)
		end
		shader:send("maxIterations", camera:getMaxIterations())
		shader:send("threshold", camera:getThreshold())
		shader:send("position", camera:getPosition():table())
		shader:send("origin", camera:getOrigin():table())
		shader:send("planey", camera:getPlaneY():table())
		shader:send("planex", camera:getPlaneX():table())
		if self.animated then
			shader:send("time", self.time)
		end
		
		love.graphics.setPixelEffect(self.shader)
		love.graphics.setColor(0,0,0,255)
		love.graphics.rectangle("fill",0,0,Width,Height)
		love.graphics.setPixelEffect()
		self.camera:draw()
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
		print(name.." :")
		print(desc.value,desc.min,desc.max,desc.step)
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

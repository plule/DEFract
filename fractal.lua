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
	local shaderCode = render.computeFractalCode(self.code, Width, Height, self.animated)
	print(shaderCode)
	self.shader = love.graphics.newPixelEffect(shaderCode)
	self.error = nil
end

local function getParameter(string)
	params = string:split(";")
	return {	
		value	= tonumber(params[1]),
		min		= tonumber(params[2]),
		max		= tonumber(params[3]),
		step	= tonumber(params[4])
		   }
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
		elseif key == "animated" and value == "true" then
			self.animated = true
		elseif key == "extern" then
			local type,name,params = string.match(value, "(%w+)%s(%w+)%s(.+)")
			if type == "float" then
				parameters[name] = getParameter(params)
			else
				local normalized = false
				params = params:split(" ")
				values = {}
				for _,param in ipairs(params) do
					if param == "normalized" then
						normalized = true
						print("yaiea")
					end
					table.insert(values,getParameter(param))
				end
				parameters[name] = values
				parameters[name].normalized = normalized
			end
			parameters[name].type = type
			code = code.."extern "..type.." "..name..";\n"
		elseif key == "view" then
			print(value)
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

function Fractal:draw()
	if not self.error then
		local shader = self.shader
		local camera = self.camera
		for name,desc in pairs(self.parameters) do
			if desc.type == "float" then
				shader:send(name, desc.value)
			elseif desc.type == "vec3" then
				local vec = vector(desc[1].value,desc[2].value,desc[3].value)
				if desc.normalized then
					vec:normalize_inplace()
				end
				shader:send(name,vec:table())
			end
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

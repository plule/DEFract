Class = require "hump.class"
vector = require "vector3d"

local function debugOptions(options)
	d = "{"
	for k,v in pairs(options) do
		d = d..k..":"..tostring(v)..", "
	end
	d = d.."}"
	debug(d)
end

Parameter = Class{
	function(self, options)
		assert(type(options) == 'table', "Parameter is constructed with a table")
		debugOptions(options)
		assert(options.type, "A parameter must have a type")
		assert(options.name or options.subparameter, "A parameter must have a name")
		if(options.shader) then
			assert(options.kname, "A shader parameter must have a key name")
		end
		assert(options.value or options.type == "select" or options.type == "vec3", "A parameter must have a initial value")

		if options.type == "float" then
			assert(options.min and options.max, "A float parameter must have min and max values")

		elseif options.type == "int" then
			assert(options.min and options.max, "A float parameter must have min and max values")
			options.step = 1

		elseif options.type == "select" then
			assert(options.choices and type(options.choices) == 'table', "A select parameter must have the list of choices")
			assert(options.action and type(options.action) == 'function', "A select parameter must have an action associated")
			self.value = options.choices[1]

		elseif options.type == "vec3" then
			assert(options.values and type(options.values) == 'table' and table.getn(options.values) == 3, "A vec3 parameter must have a list of 3 parameters")
		end

		debug("========== new Parameter :")
		for key,value in pairs(options) do
			debug(key,value)
			self[key] = value
		end
	end}

function Parameter:to_s()
	return "Parameter : "..self.name.." type : "..tostring(self.type).." value : "..tostring(self:getValue())
end

function Parameter:quickieUpdate(gui,showName)
	if showName then
		gui.Label{text = self.name}
	end
	local type = self.type
	if type == "float" then
		gui.group.push{grow = "right"}
		gui.Slider{info = self}
		gui.Label{text = string.format("%.2f",self.value), size = {50,10}}
		gui.group.pop{}
	elseif type == "int" then
		gui.group.push{grow = "right"}
		gui.Slider{info = self}
		gui.Label{text = string.format("%.2f",self.value), size = {50,10}}
		gui.group.pop{}
	elseif type == "vec3" then
		for _,param in ipairs(self.values) do
			param:quickieUpdate(gui,false)
		end
	elseif type == "select" then
		gui.group.push{grow = "down", size = {200,20}}
		for _,choice in ipairs(self.choices) do
			if gui.Button{text = choice.name} then
				self.value = choice
				self.action(choice)
			end
		end
		gui.group.pop{}
	end
end

function Parameter:getValue(raw)
	local type = self.type
	if type == "float" or type == "select" then
		return self.value
	elseif type == "int" then
		if raw then return self.value end
		return math.floor(self.value)
	elseif type == "vec3" then
		local vec = vector(self.values[1].value,self.values[2].value,self.values[3].value)
		if self.normalized and not raw then
			vec:normalize_inplace()
		end
		return vec:table()
	end
end

function Parameter:setValue(value)
	local type = self.type
	if type == "float" or type == "select" then
		self.value = value
	elseif type == "int" then
		self.value = math.floor(value)
	elseif type == "vec3" then
		self.values[1].value = value[1]
		self.values[2].value = value[2]
		self.values[3].value = value[3]
	end
end

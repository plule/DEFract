require "parameter"

Parser = {}

-- KEEP IT STATELESS
function Parser.load()
	debug("========== Init parser")
	Parser.colorModes = {}
	for _,colorModePath in ipairs(love.filesystem.enumerate('glsl/color/')) do
		table.insert(Parser.colorModes, Parser.parse('glsl/color/'..colorModePath))
	end
	Parser.codeEffect = love.filesystem.read('glsl/effect.frag')
	Parser.codeHeader = love.filesystem.read('glsl/codeHeader.frag')
	Parser.animationHeader = love.filesystem.read('glsl/animationHeader.frag')
end

local function getParameterOptions(string)
	params = string:split(";")
	return {	
		value	= tonumber(params[1]),
		min		= tonumber(params[2]),
		max		= tonumber(params[3]),
		step	= tonumber(params[4])
		   }
end

local function getParameter(string)
	debug("Parsing param : ")
	debug(string)
	local type,name,params = string.match(string, "(%w+)%s(%w+)%s(.+)")
	local parameter = {}
	if type == "float" then
		parameter = getParameterOptions(params)
	else
		local normalized = false
		params = params:split(" ")
		values = {}
		for _,param in ipairs(params) do
			if param == "normalized" then
				normalized = true
			else
				local options = getParameterOptions(param)
				options.type = "float"
				options.subparameter = true
				table.insert(values,Parameter(options))
			end
		end
		parameter = {
			values = values,
			normalized = normalized
		}
	end
	parameter.type = type
	parameter.name = name
	parameter.kname = name
	parameter.shader = true
	return Parameter(parameter)
end

function Parser.parse(path)
	local file = love.filesystem.newFile(path)
	local ret = {
		code = "",
		name = path,
		description = "",
		animated = false,
		parameters = {},
		positions = {},
		path = path
	}
	file:open('r')

	for line in file:lines() do
		if line:sub(1,1) == "#" then
			local key,value = string.match(line, "#(%w+)%s(.+)")
			if key == "name" then
				ret.name = value
			elseif key == "description" then
				ret.description = value
			elseif key == "animated" and value == "true" then
				ret.animated = true
			elseif key == "extern" then
				local parameter = getParameter(value)
				table.insert(ret.parameters, parameter)
				ret.code = ret.code.."extern "..parameter.type.." "..parameter.name..";\n"
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
				table.insert(ret.positions, position)
			else
				ret.code = ret.code..line.."\n"
			end
		else
			ret.code = ret.code..line.."\n"
		end
	end
	file:close()
	return ret
end

function Parser.computeFractalCode(fractalPath, coloringCode)
	local finalCode = (Parser.codeHeader):format(Width, Height)
	local fractalCode = Parser.parse(fractalPath)
	fractalCode.animated = fractalCode.animated or coloringCode.animated
	if fractalCode.animated then
		finalCode = finalCode..Parser.animationHeader
	end
	finalCode = finalCode..fractalCode.code..coloringCode.code..Parser.codeEffect
	fractalCode.code = finalCode
	debug("Final shader code :\n"..finalCode)
	return fractalCode
end

-- vector = require("vector3d")

-- render = {}

-- function render.load()
-- 	render.threshold=0.02
-- 	render.maxIterations=100
-- 	render.dim = love
-- 	render.codeEffect = love.filesystem.read('glsl/effect.frag')
-- 	render.animationHeader = love.filesystem.read('glsl/animationHeader.frag')
-- 	render.coloringCodes = {
-- 		vrldColor = love.filesystem.read('glsl/vrldColor.frag'),
-- 		blackAndWhite = love.filesystem.read('glsl/simpleColor.frag')
-- 	}
-- 	render.codeColor = render.coloringCodes.vrldColor
-- 	render.codeVrldColor = love.filesystem.read('glsl/vrldColor.frag')
-- 	render.codeHeader = love.filesystem.read('glsl/codeHeader.frag')
-- 	render.shader = nil
-- 	render.animated = false
-- end

--[[
function render.updateShader(fractal)
	fractal.code = love.filesystem.load(fractal.path)().code
	render.lastFractal = nil
	render.shader = nil
end

function render.renderTo(fractal, canvas)
	if render.lastFractal ~= fractal then
		render.lastFractal = fractal
		render.shader = nil
	end
	if not render.shader then
		render.shader = render.getPixelEffect(fractal.code, unpack(render.dim))
	end
	local shader = render.shader
	canvas:clear()
	love.graphics.setCanvas(canvas)
	if type(shader) == "string" then
		love.graphics.setPixelEffect()
		love.graphics.setColor(255,255,255)
		love.graphics.print("Error in fractal code",0,0)
		love.graphics.print(shader,0,15)
		focus = false
	else
		local width,height = unpack(render.dim)
		local preset = fractal.quality or {}
		love.graphics.setPixelEffect(shader)
		
		local maxIterations = preset.maxIterations or render.maxIterations
		local threshold = preset.threshold or render.threshold
		shader:send("maxIterations", maxIterations*maxIterationsMulti)
		shader:send("threshold",threshold*thresholdMulti)
		
		love.graphics.setPixelEffect(shader)
		local normalizedDir = vectorFromSpherical(1,direction.theta,direction.phi)
		ratio = height/render.dim[2]
		
		local origin = position+normalizedDir*projDist*ratio*zoom
		shader:send("position", {position:unpack()})
		shader:send("origin", {origin:unpack()})
		
		local planey = vectorFromSpherical(height/1000,direction.theta-math.pi/2, direction.phi)
		shader:send("planey", {planey:unpack()})
		
		local planex = vectorFromSpherical(width/1000,math.pi/2, direction.phi+math.pi/2)
		shader:send("planex", {planex:unpack()})
		if animatedFractal then shader:send("time", currTime) end
		love.graphics.setColor(0,0,0,255)
		love.graphics.rectangle("fill",0,0,width,height)
		love.graphics.setColor(255,255,255,255)
		love.graphics.setPixelEffect()
	end
	love.graphics.setCanvas()
	end
]]

--[[function render.getPixelEffect(code, width, height)
	-- Try to build animated code
	state, ret = pcall(function()
		return love.graphics.newPixelEffect(
			render.computeFractalCode(code, width, height, true))
		end
	)
	-- Failed to build
	if not state then
		print("Failed to build")
		return ret
	end
	
	-- Try to send time
	if pcall(function() ret:send("time", currTime) end) then
		animatedFractal = true
		return ret
	else
		-- Time sending failed, generate a still fractal
		animatedFractal = false
		state,ret = pcall(function()
			return love.graphics.newPixelEffect(
				render.computeFractalCode(code, width, height, false))
			end
		)
	end
	return ret
	end]]

-- function render.computeFractalCode(code, width, height, animated, coloring)
-- 	local finalCode = (render.codeHeader):format(width, height)
-- 	if(animated) then
-- 		finalCode = finalCode..render.animationHeader
-- 	end
-- 	finalCode = finalCode..code..coloring..render.codeEffect
-- 	return finalCode
-- end

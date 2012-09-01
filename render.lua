vector = require("vector3d")

render = {}

function render.load()
	render.rt = { dim = {love.graphics.getWidth(), love.graphics.getHeight()}}
	render.hq = { dim = {love.graphics.getWidth(), love.graphics.getHeight()},
		threshold=0.02,maxIterations=100}
	render.hd = { dim = {1024,1024}, threshold=0.02,maxIterations=100}
	render.codeEffect = love.filesystem.read('glsl/effect.frag')
	render.animationHeader = love.filesystem.read('glsl/animationHeader.frag')
	render.codeColor = love.filesystem.read('glsl/simpleColor.frag')
	render.codeHeader = love.filesystem.read('glsl/codeHeader.frag')
	render.shaders = {}
end

function render.updateShader(fractal)
	fractal.code = love.filesystem.load(fractal.path)().code
	render.lastFractal = nil
	render.shaders = {}
end

function render.renderTo(fractal, canvas, quality, maxIterations, threshold)
	if render.lastFractal ~= fractal then
		render.lastFractal = fractal
		render.shaders = {}
	end
	if not render.shaders[quality] then
		render.shaders[quality] = render.getPixelEffect(fractal.code, unpack(render[quality].dim))
	end
	local shader = render.shaders[quality]
	canvas:clear()
	love.graphics.setCanvas(canvas)
	if type(shader) == "string" then
		love.graphics.setPixelEffect()
		love.graphics.setColor(255,255,255)
		love.graphics.print("Error in fractal code",0,0)
		love.graphics.print(shader,0,15)
		focus = false
	else
		local width,height = unpack(render[quality].dim)
		local preset = fractal[quality] or {}
		love.graphics.setPixelEffect(shader)
		
		local maxIterations = maxIterations or preset.maxIterations or render[quality].maxIterations
		local threshold = threshold or preset.threshold or render[quality].threshold
		shader:send("maxIterations", maxIterations*maxIterationsMulti)
		shader:send("threshold",threshold*thresholdMulti)
		
		love.graphics.setPixelEffect(shader)
		local normalizedDir = vectorFromSpherical(1,direction.theta,direction.phi)
		ratio = height/render.rt.dim[2]
		
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

function render.getPixelEffect(code, width, height)
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
end

function render.computeFractalCode(code, width, height, animated)
	local finalCode = render.codeHeader:format(width, height)
	if(animated) then
		finalCode = finalCode..render.animationHeader
	end
	finalCode = finalCode..code..render.codeColor..render.codeEffect
	return finalCode
end
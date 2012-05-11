vector = require("vector3d")

render = {
	rt = { dim = {love.graphics.getWidth(), love.graphics.getHeight()}},
	hq = { dim = {love.graphics.getWidth(), love.graphics.getHeight()},
		threshold=0.02,maxIterations=100},
	hd = { dim = {1280,1024},
		threshold=0.02,maxIterations=100},
	codeHeader = [[
extern vec3 position; // Position of the Eye
extern vec3 origin; // origin of the projection plane
extern vec3 planex;  // definition of the projection plane
extern vec3 planey;
float w = %f;     // Size of the window
float h = %f;
extern float maxIterations; // Max number of rendering step
extern float threshold;// Limit to estimate that we touch the object
]],
	codeRenderer = [[
vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc)
{
	pc.x = pc.x/w-0.5;
	pc.y = pc.y/h-0.5;
	vec3 p = origin + planex*pc.x + planey*pc.y;
	vec3 d = (p-position) / length(p-position);
	//p=position;
	float distance = DE(p);
	int i;
	while((distance > threshold) && (i < maxIterations))
	{
		p = p+distance*d;
		distance = DE(p);
		i++;
	}
	float j = i;
	float co = 1-j/maxIterations;
	return vec4(co);
}
]]
}

function render.updateShader(fractal)
	fractal.shaders = {}
end

function render.renderTo(fractal, canvas, quality, maxIterations, threshold)
	fractal.shaders = fractal.shaders or {}
	fractal.shaders[quality] = fractal.shaders[quality] or render.getPixelEffect(fractal.code, unpack(render[quality].dim))
	local shader = fractal.shaders[quality]
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
		shader:send("maxIterations", maxIterations)
		shader:send("threshold",threshold)
		
		love.graphics.setPixelEffect(shader)
		local normalizedDir = vectorFromSpherical(1,direction.theta,direction.phi)
		local ratio = height/render.rt.dim[2]
		local origin = position+normalizedDir*projDist*ratio
		shader:send("position", {position:unpack()})
		shader:send("origin", {origin:unpack()})
		
		local planey = vectorFromSpherical(height/1000,direction.theta-math.pi/2, direction.phi)
		shader:send("planey", {planey:unpack()})
		
		local planex = vectorFromSpherical(width/1000,math.pi/2, direction.phi+math.pi/2)
		shader:send("planex", {planex:unpack()})
		love.graphics.setColor(0,0,0,255)
		love.graphics.rectangle("fill",0,0,width,height)
		love.graphics.setColor(255,255,255,255)
		love.graphics.setPixelEffect()
	end
	love.graphics.setCanvas()
end

function render.getPixelEffect(code, width, height)
	state, ret = pcall(function()
		return love.graphics.newPixelEffect((render.codeHeader):format(width,height)..code..render.codeRenderer)
		end
	)
	return ret
end

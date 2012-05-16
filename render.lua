vector = require("vector3d")

render = {
	rt = { dim = {love.graphics.getWidth(), love.graphics.getHeight()}},
	hq = { dim = {love.graphics.getWidth(), love.graphics.getHeight()},
		threshold=0.02,maxIterations=100},
	hd = { dim = {1024,1024},
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
int maxIt; // maxIterations converted to int
float PI = 3.141592654;
]],
	codeRenderer = [[
number _hue(number s, number t, number h)
{
	h = mod(h, 1.);
	number six_h = 6.0 * h;
	if (six_h < 1.) return (t-s) * six_h + s;
	if (six_h < 3.) return t;
	if (six_h < 4.) return (t-s) * (4.-six_h) + s;
	return s;
}

vec4 hsl(vec4 c)
{
	if (c.y == 0.0) return vec4(vec3(c.z), c.a);
	number t = (c.z < .5) ? c.y*c.z + c.z : -c.y*c.z + (c.y+c.z);
	number s = 2.0 * c.z - t;
	number q = 1.0/3.0;
	return vec4(_hue(s,t,c.x+q), _hue(s,t,c.x), _hue(s,t,c.x-q), c.w);
}

// periodic triangle function in the range [0:1]:
// 1--   .       .   :   .       .
//   :  / \     / \  :  / \     / \
//   : '   \   /   \ : /   \   /   '
//   :      \ /     \:/     \ /
// 0-- ------'-------+-------'------
//          -1       0       1
number wrap(number x)
{
	x = mod(x, 1.);
	return 2. * min(x, 1.-x);
}

vec3 wrap(vec3 x)
{
	x = mod(x, vec3(1.));
	return 2. * min(x, vec3(1.)-x);
}

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc)
{
	pc.x = pc.x/w-0.5;
	pc.y = pc.y/h-0.5;
	vec3 p = origin + planex*pc.x + planey*pc.y;
	vec3 d = (p-position) / length(p-position);
	maxIt = int(maxIterations);
	p=position;
	float distance = DE(p);
	int i=0;
	while((distance > threshold) && (i < maxIt))
	{
		p = p+distance*d;
		distance = DE(p);
		i++;
	}
	//float co = 1.0-(float(i)+distance/threshold)/maxIterations;
	//return vec4(co);
	
	color.a = 1. - float(i)/maxIterations;
	color.xyz = wrap(p / length(p));
	color.x = dot(color.xzy, color.zyx) * .1 + .9 * wrap(time * .05);
	color.y = color.y + .3;
	color.z = (color.z * .3 + .5) * color.a;

	return hsl(color);
}
]],
	codeAnimation = [[
extern float time;
]],
	shaders = {}
}

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
			(render.codeHeader):format(width,height)..render.codeAnimation..code..render.codeRenderer)
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
				(render.codeHeader):format(width,height)..code..render.codeRenderer)
			end
		)
	end
	return ret
end

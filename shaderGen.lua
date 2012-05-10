shaderGen = {
	codeHeader = [[
extern vec3 position; // Position of the Eye
extern vec3 origin; // origin of the projection plane
extern vec3 planex;  // definition of the projection plane
extern vec3 planey;
float w = 800.0;     // Size of the window
float h = 600.0;
int maxIteration = 50; // Max number of rendering step
float threshold = 0.001;// Limit to estimate that we touch the object
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
	while((distance > threshold) && (i < maxIteration))
	{
		p = p+distance*d;
		distance = DE(p);
		i++;
	}
	float j = i;
	float co = 1-j/maxIteration;
	return vec4(co);
}
]]
}

function shaderGen.getPixelEffect(code)
	state, ret = pcall(function()
		return love.graphics.newPixelEffect(shaderGen.codeHeader..code..shaderGen.codeRenderer)
		end
	)
	return ret
end

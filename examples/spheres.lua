return {
	name="Spheres",
	description="Taken from http://blog.hvidtfeldts.net/index.php/2011/08/distance-estimated-3d-fractals-iii-folding-space/",
	views = {
		{position=vector(-15, -15, 5), direction = {speed=2, phi=math.pi/6, theta=math.pi/2}},
		{position=vector(2200,1000,35000), direction = {speed=2, phi=math.pi/6, theta=math.pi/2}},
	},
	rt = {maxIterations = 100, threshold = 0.001},
	hq = {maxIterations = 100, threshold = 0.001},
	hd = {maxIterations = 100, threshold = 0.001},
	code=[[
float DE(vec3 z)
{
	z.xy = mod((z.xy),1.0)-vec2(0.5);
	return min(length(z)-0.4, z.z+0.3);
}
]]
}

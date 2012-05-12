return {
	name="Spheres",
	description="Taken from http://blog.hvidtfeldts.net/index.php/2011/08/distance-estimated-3d-fractals-iii-folding-space/",
	views = {
		{position=vector(-8.2438372072926,31.797857134219,10.148725520207), direction = {speed=2.000000, phi=29.673599, theta=2.111593}},
	},
	rt = {maxIterations = 100, threshold = 0.001},
	hq = {maxIterations = 100, threshold = 0.001},
	hd = {maxIterations = 100, threshold = 0.001},
	code=[[
float DE(vec3 z)
{
	float radius = 0.5;
	float spacing = 2.5+sin(time/3);
	z.z = z.z-sin(length(z)-time)/4;
	z.z = z.z-sin(length(z+vec3(20,0,0))-time)/4;
	z.xy = mod((z.xy), spacing) - vec2(spacing/2);
	return min(length(z)-radius, z.z+0.3);
}
]]
}

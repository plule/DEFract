return {
	name="Mandelbox",
	description="The Mandelbox (taken from http://blog.hvidtfeldts.net/index.php/2011/11/distance-estimated-3d-fractals-vi-the-mandelbox/)",
	views = {
		{position = vector(-12, -28, 10), direction = {speed=2, phi=1, theta=2}},
		{position = vector(-1.359,-8.363,5.480), direction = {speed=2, phi=1.55, theta=2.14}},
		{position=vector(0.0031743541978261,-9.4093969864814,0.013476554949394), direction = {speed=2.000000, phi=1.520000, theta=1.640000}},
	},
	rt = {threshold=0.01,maxIterations=58},
	hd = {threshold=0.005,maxIterations=70},
	hq = {threshold=0.005,maxIterations=70},
	code = [[
float Scale=2;
int Iterations = 10;    // Max iteration of the fractal generation
int Power=8;
float Bailout=5;
float minRadius2 = 0.9;
float fixedRadius2 = 5.;
float fixedRadius = 1.;
float foldingLimit = 2.;

void sphereFold(inout vec3 z, inout float dz) {
	float r2 = dot(z,z);
	if (r2<minRadius2) {
		// linear inner scaling
		float temp = (fixedRadius2/minRadius2);
		z *= temp;
		dz*= temp;
	} else if (r2<fixedRadius2) {
		// this is the actual sphere inversion
		float temp =(fixedRadius2/r2);
		z *= temp;
		dz*= temp;
	}
}

void boxFold(inout vec3 z, inout float dz) {
	z = clamp(z, -foldingLimit, foldingLimit) * 2.0 - z;
}

float DE(vec3 z)
{
	vec3 offset = z;
	float dr = 1.0;
	for (int n = 0; n < Iterations; n++) {
		boxFold(z,dr);       // Reflect
		sphereFold(z,dr);    // Sphere Inversion

		z=Scale*z + offset;  // Scale & Translate
		dr = dr*abs(Scale)+1.0;
	}
	float r = length(z);
	return r/abs(dr);
}
]]
}

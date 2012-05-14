return {
	name="Animated Menger Sponge",
	description="Totally copied from fragmentarium code.",
	views = {
		{position=vector(0.59331311484092,14.584418769937,4.093253024104), direction = {speed=1.495483, phi=-1.610000, theta=1.861593}},
		{position=vector(0,0,0), direction = {speed = 1.5, phi=0, theta=0}},
	},
	rt = {maxIterations = 100, threshold = 0.005},
	hd = {maxIterations = 200, threshold = 0.001},
	hq = {maxIterations = 200, threshold = 0.001},
	code=[[
mat3 rot;
float Scale = 3.;
vec3 Offset = vec3(1.,1.,1.)*5.;
vec3 RotVector = vec3(1.,1.,1.);
float RotAngle = mod(time*10.,360.0);
int Iterations = 10;
mat3 rotationMatrix3(vec3 v, float angle)
{
	float c = cos(radians(angle));
	float s = sin(radians(angle));

	return mat3(c + (1.0 - c) * v.x * v.x, (1.0 - c) * v.x * v.y - s * v.z, (1.0 - c) * v.x * v.z + s * v.y,
		(1.0 - c) * v.x * v.y + s * v.z, c + (1.0 - c) * v.y * v.y, (1.0 - c) * v.y * v.z - s * v.x,
		(1.0 - c) * v.x * v.z - s * v.y, (1.0 - c) * v.y * v.z + s * v.x, c + (1.0 - c) * v.z * v.z
	);
}

float DE(vec3 z)
{
	int n = 0;
	rot = rotationMatrix3(normalize(RotVector), RotAngle);
	while (n < Iterations) {
		z = rot*z;
		z = abs(z);
		if (z.x<z.y){ z.xy = z.yx;} 
		if (z.x< z.z){ z.xz = z.zx;}
		if (z.y<z.z){ z.yz = z.zy;}
		z = Scale*z-Offset*(Scale-1.0);
		
		if( z.z<-0.5*Offset.z*(Scale-1.0)) z.z+=Offset.z*(Scale-1.0);

		n++;
	}

	return abs(length(z)) * pow(Scale, float(-n));
}
]]
}

return {
	name="Rotated Menger Sponge",
	description="Totally copied from fragmentarium code.",
	views = {
		{position=vector(-1.5371718654061,2.1532370586601,1.1774294611279), direction = {speed=70, phi=-7.230000, theta=2.040000}},
		{position=vector(-341.00724398697,273.39373038008,465.15740521731), direction = {speed=69.499161, phi=-6.970000, theta=2.350000}},
	},
	maxIterations = 40,
	threshold = 0.5,
	code=[[
mat3 rot;
float Scale = 3.;
vec3 Offset = vec3(1.2,1.,1.)*200.;
vec3 RotVector = vec3(1.,1.,1.);
float RotAngle = 180.;
int Iterations = 20;
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

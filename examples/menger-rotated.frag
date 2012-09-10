#name Rotated Menger Sponge
#description Copied from Fragmentarium code

#view -1.5371;2.15;1.177;70;0;1.6;1;0.001;40

mat3 rot;
#extern float Iterations 20;5;100
#extern float Scale 2.34;0.1;10
#extern vec3 Offset 253.3;-500;500 293.3;-500;500 20;-500;500
#extern vec3 RotVector 0;0;1 0;0;1 1;0;1 normalized
#extern float RotAngle 60;0;360

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
	rot = rotationMatrix3(RotVector, RotAngle);
	int it = int(Iterations);
	while (n < it) {
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

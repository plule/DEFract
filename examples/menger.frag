#name Menger Sponge
#description Copied from Fragmentarium code

#view -1.5371;2.15;1.177;70;1.57;1.58;1;0.001;40

#extern float Scale 3;0;5
#extern vec3 Offset 240;-500;500 200;-500;500 200;-500;500
#extern float Iterations 20;5;100

float DE(vec3 z)
{
	int n = 0;
	int it = int(Iterations);
	while (n < it) {   
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

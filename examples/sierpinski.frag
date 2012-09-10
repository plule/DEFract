#name 3D Sierpiński triangle
#description 3D variation of the Sierpiński. Taken from http://blog.hvidtfeldts.net/index.php/2011/08/distance-estimated-3d-fractals-iii-folding-space/

#view -20;13;-1.4;2;5.7;1.5;1;0.01;30

#extern float Iterations 30;5;100;
#extern float Scale 2;1;20
#extern float Offset 10;0;100
float DE(vec3 z)
{
	int n = 0;
	int it = int(Iterations);
	while (n < it) {
		if(z.x+z.y<0) z.xy = -z.yx; // fold 1
		if(z.x+z.z<0) z.xz = -z.zx; // fold 2
		if(z.y+z.z<0) z.zy = -z.yz; // fold 3
		z = z*Scale - Offset*(Scale-1.0);
		n++;
	}
	return (length(z) ) * pow(Scale, -float(n));
}

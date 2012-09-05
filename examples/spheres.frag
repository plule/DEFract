#name Spheres
#description Inspired by http://blog.hvidtfeldts.net/index.php/2011/08/distance-estimated-3d-fractals-iii-folding-space/

#view -8.24;31.79;10.14;2;0;1.57;1;0.0002;100

#animated true

#extern float radius 0.5;0;2
#extern float spacing 2.5;0;10
#extern float floor 0.3;-5;5

float DE(vec3 z)
{
	float spacing2 = spacing+sin(time/3.);
	z.z = z.z-sin(length(z)-time)/4.;
	z.z = z.z-sin(length(z+vec3(20.,0.,0.))-time)/4.;
	z.xy = mod((z.xy), spacing2) - vec2(spacing2/2.);

	return min(length(z)-radius, z.z+floor);
}

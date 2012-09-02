#name Mandelbox
#description The Mandelbox (taken from http://blog.hvidtfeldts.net/index.php/2011/11/distance-estimated-3d-fractals-vi-the-mandelbox/)
#view -28;-28;12;2;0;1.57;1;0.005;58

#extern Iterations;10;5;100;1
#extern Scale;2;0.5;5
#extern minRadius2;0.9;0.5;10
#extern fixedRadius2;5;0.1;10
#extern foldingLimit;2;1;5

//#define minRadius2 (minRadius*minRadius)
//#define fixedRadius2 (fixedRadius*fixedRadius)

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

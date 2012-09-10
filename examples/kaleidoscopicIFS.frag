#name Kaleidoscopic IFS
#description Taken from http://www.fractalforums.com/3d-fractal-generation/kaleidoscopic-%28escape-time-ifs%29/

#view 6.2;4.8;7.2;2;3.79;2.3;1;0.001;90

#extern float Iterations 10;5;100;1
#extern float scale 2;0.1;10
#extern vec3 offset 1.1;0;10 0.61803399;0;10 0;0;10 normalized
#extern vec3 n1 -1.61803399;-5;5 0.61803399;-5;5 1;-5;5 normalized
#extern vec3 n2 1;-5;5 -1.61803399;-5;5 2.61803399;-5;5 normalized
#extern float bailoutSquared 1000000000.0;100000000.0;10000000000.0

// Return reflection matrix for plane with normal 'n'
mat3 reflectionMatrix(vec3 n)
{
	return mat3( 1.0 - 2.0*n.x*n.x,     - 2.0*n.y*n.x ,     - 2.0*n.z*n.x,
			      - 2.0*n.x*n.y, 1.0 - 2.0*n.y*n.y ,     - 2.0*n.z*n.y,
			      - 2.0*n.x*n.z,     - 2.0*n.y*n.z , 1.0 - 2.0*n.z*n.z );
}

float DE(vec3 p)
{
	mat3 n1Mat = reflectionMatrix(n1);
	mat3 n2Mat = reflectionMatrix(n2);
	p = p/5.0;
	int n;
	for(n=0; n<Iterations; n++) {
		p.y = abs(p.y); 
		p.z = abs(p.z);
		if (dot(p, n2)>0.5) { p *= n2Mat; }
		p.x = abs(p.x); 
		p.z = abs(p.z);
		if (dot(p, n1)>0.) { p *= n1Mat; }        
		p = p*scale - offset*(scale-1.);
		if (dot(p,p)> bailoutSquared) break;
	}
	return (length(p) ) * pow(scale, -float(n));
}

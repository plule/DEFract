return {
	name="Kaleidoscopic IFS",
	description="Taken from http://www.fractalforums.com/3d-fractal-generation/kaleidoscopic-%28escape-time-ifs%29/",
	views = {
		{position=vector(6.1812847226932,4.8685069372872,7.2079703755023), direction = {speed=2.000000, phi=-2.360000, theta=2.301500}},
		{position=vector(3.2972297054397,-0.012429725521014,5.3079703755023), direction = {speed=2.000000, phi=-3.150000, theta=2.211593}},
	},
	rt = {threshold = 0.005, maxIterations = 100},
	hd = {threshold = 0.001, maxIterations = 300},
	hq = {threshold = 0.001, maxIterations = 300},
	code=[[
int Iterations = 10;

float phi = 1.61803399; // golden ratio.
float scale = 2.;
vec3 offset = normalize(vec3(1.1,phi-1.0,0.0));
vec3 n1 = normalize(vec3(-phi,phi-1.0,1.0));
vec3 n2 = normalize(vec3(1.0,-phi,phi+1.0));
float bailoutSquared = 1000000000;
      
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
]]
}

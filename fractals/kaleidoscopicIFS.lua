return {
	name="Kaleidoscopic IFS",
	description="Taken from http://www.fractalforums.com/3d-fractal-generation/kaleidoscopic-%28escape-time-ifs%29/",
	position=vector(1.64, 0.8, -0.3),
	direction = {speed=2, phi=-2.66, theta=1.38},
	code=[[
int Iterations = 10;

float phi = 1.61803399; // golden ratio.
float scale = 2.1;
vec3 offset = normalize(vec3(1.0,phi-1.0,0.0));
vec3 n1 = normalize(vec3(-phi,phi-1.0,1.0));
vec3 n2 = normalize(vec3(1.0,-phi,phi+1.0));
float bailoutSquared = 1000000.;
      
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
	float n;
	for(n=0; n<Iterations; n++) {
		p.y = abs(p.y); 
		p.z = abs(p.z);
		if (dot(p, n2)>0.0) { p *= n2Mat; }
		p.x = abs(p.x); 
		p.z = abs(p.z);
		if (dot(p, n1)>0.0) { p *= n1Mat; }        
		p = p*scale - offset*(scale-p.z);
		if (dot(p,p)> bailoutSquared) break;
	}
	return (length(p) ) * pow(scale, -float(n));
}
		
		/*
float scale = 2;
float bailout = 1000;
float CX=0.5;
float CY=0.5;
float CZ=0.5;
float DE(vec3 pos)
{
	float x = pos.x;
	float y = pos.y;
	float z = pos.z;
	float r=x*x+y*y+z*z;
	int i;
	for(i=0;i<10 && r<bailout;i++){
		//rotate1(x,y,z);
		x=abs(2*x);y=abs(2*y);z=abs(2*z);
		float x1,y1;
		if(x+y<0){x1=-y;y=-x;x=x1;}
		if(x+z<0){x1=-z;z=-x;x=x1;}
		if(y+z<0){y1=-z;z=-y;y=y1;}
		
		//rotate2(x,y,z);

		x=scale*x-CX*(scale-1);
		y=scale*y-CY*(scale-1);
		z=scale*z-CZ*(scale-1);
		r=x*x+y*y+z*z;
	}
	return (sqrt(r)-2)*pow(scale,(-i));//the estimated distance
}*/
]]
}

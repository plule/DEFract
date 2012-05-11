return {
	name="Menger Sponge",
	description="Taken from http://snipplr.com/view/33781/",
	views = {
		{position=vector(3, -2.5, 2.2), direction = {speed=2, phi=-3.94, theta=2.28}},
	},
	rt = {maxIterations = 200, threshold = 0.001},
	hd = {maxIterations = 600, threshold = 0.00001},
	hq = {maxIterations = 600, threshold = 0.00001},
	code=[[
float DE(vec3 z0)
{
	float r = length(z0);
	float scale = 3.1;
	float CX = 2.0;
	float CY = 1.0;
	float CZ = 1.0;
	float t = 0.0;
	int i = 0;
	int Iterations = 5;
	for (i=0;i<Iterations && r<60.0;i++){
 
		// Rotation around z-axis
		float angle = -0.08;
		float x2 = cos(angle)*z0.x + sin(angle)*z0.y;
		float y2 = -sin(angle)*z0.x + cos(angle)*z0.y;
		z0.x = x2; z0.y = y2;
		
		
		z0.x=abs( z0.x); z0.y=abs( z0.y); z0.z=abs( z0.z);
		if( z0.x- z0.y<0.0){t= z0.y; z0.y= z0.x; z0.x=t;}
		if( z0.x- z0.z<0.0){t= z0.z; z0.z= z0.x; z0.x=t;}
		if( z0.y- z0.z<0.0){t= z0.z; z0.z= z0.y; z0.y=t;}
		
		// Reverse rotation around z-axis
		angle = -angle*5;
		x2 = cos(angle)*z0.x + sin(angle)*z0.y;
		y2 = -sin(angle)*z0.x + cos(angle)*z0.y;
		z0.x = x2; z0.y = y2;
		
		z0.x=scale* z0.x-CX*(scale-1.0);
		z0.y=scale* z0.y-CY*(scale-1.0);
		z0.z=scale* z0.z;
		if( z0.z>0.5*CZ*(scale-1.0)) z0.z-=CZ*(scale-1.0);
		
		
		// Extra folding step
		if(z0.x+z0.y<1.0){t=-z0.y;z0.y=-z0.x;z0.x=t;}
		if(z0.x+z0.z<0.0){t=-z0.z;z0.z=-z0.x;z0.x=t;}
		if(z0.y+z0.z<0.0){t=-z0.z;z0.z=-z0.y;z0.y=t;}
		
		
		r=length(z0);
	}
	return (sqrt(r)-2.0)*pow(scale,float(-i));//the estimated distance
}
]]
}

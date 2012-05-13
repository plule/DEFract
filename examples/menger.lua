return {
	name="Menger Sponge",
	description="Totally copied from fragmentarium code.",
	views = {
		{position=vector(-1.5371718654061,2.1532370586601,1.1774294611279), direction = {speed=30, phi=-7.230000, theta=2.040000}},
		{position=vector(-788.83254935972,-1.741453859346,-548.80977315143), direction = {speed=1.385461, phi=-13.400000, theta=1.220000}},
	},
	rt = {maxIterations = 50, threshold = 0.1},
	hd = {maxIterations = 50, threshold = 0.1},
	hq = {maxIterations = 50, threshold = 0.1},
	code=[[
float Scale = 3.;
vec3 Offset = vec3(1.,1.,1.)*1000.;
int Iterations = 20;

float DE(vec3 z)
{
	int n = 0;
	while (n < Iterations) {   
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

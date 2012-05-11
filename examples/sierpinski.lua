return {
	name="3D Sierpiński triangle",
	description="3D variation of the Sierpiński. Taken from http://blog.hvidtfeldts.net/index.php/2011/08/distance-estimated-3d-fractals-iii-folding-space/",
	views = {
		{position=vector(-20, 13, -1.4),direction = {speed=2, phi=-0.62, theta=math.pi/2}},
	},
	rt = {maxIterations = 30, threshold = 0.02},
	hq = {maxIterations = 30, threshold = 0.02},
	hd = {maxIterations = 30, threshold = 0.02},
	code=[[
int Iterations = 10;
float Scale = 2.;
float Offset = 10.;
float DE(vec3 z)
{
    float r;
    int n = 0;
    while (n < Iterations) {
       if(z.x+z.y<0) z.xy = -z.yx; // fold 1
       if(z.x+z.z<0) z.xz = -z.zx; // fold 2
       if(z.y+z.z<0) z.zy = -z.yz; // fold 3
       z = z*Scale - Offset*(Scale-1.0);
       r = dot(z, z);
       n++;
    }
    return (length(z) ) * pow(Scale, -float(n));
}
]]
}

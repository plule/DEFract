#name Psychedelic colors by vrld
#animated true

number _hue(number s, number t, number h)
{
	h = mod(h, 1.);
	number six_h = 6.0 * h;
	if (six_h < 1.) return (t-s) * six_h + s;
	if (six_h < 3.) return t;
	if (six_h < 4.) return (t-s) * (4.-six_h) + s;
	return s;
}

vec4 hsl(vec4 c)
{
	if (c.y == 0.0) return vec4(vec3(c.z), c.a);
	number t = (c.z < .5) ? c.y*c.z + c.z : -c.y*c.z + (c.y+c.z);
	number s = 2.0 * c.z - t;
	number q = 1.0/3.0;
	return vec4(_hue(s,t,c.x+q), _hue(s,t,c.x), _hue(s,t,c.x-q), c.w);
}

// periodic triangle function in the range [0:1]:
// 1--   .       .   :   .       .
//   :  / \     / \  :  / \     / \
//   : '   \   /   \ : /   \   /   '
//   :      \ /     \:/     \ /
// 0-- ------'-------+-------'------
//          -1       0       1
number wrap(number x)
{
	x = mod(x, 1.);
	return 2. * min(x, 1.-x);
}

vec3 wrap(vec3 x)
{
	x = mod(x, vec3(1.));
	return 2. * min(x, vec3(1.)-x);
}

vec4 getColor(float distance, int numberOfIterations, int maxIterations, vec3 pointInSpace) {
	vec4 color;
	color.a = 1. - float(numberOfIterations)/float(maxIterations);
	color.xyz = wrap(pointInSpace / length(pointInSpace));
	color.x = dot(color.xzy, color.zyx) * .1 + .9 * wrap(time * .05);
	color.y = color.y + .3;
	color.z = (color.z * .3 + .5) * color.a;

	return hsl(color);
}

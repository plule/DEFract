#name Simple black and white shading

vec4 getColor(float distance, int numberOfIterations, int maxIterations, vec3 pointInSpace) {
//	return vec4(1.0-(float(numberOfIterations)+distance/threshold)/float(maxIterations));
	return vec4(1.0-float(numberOfIterations)/float(maxIterations));
}

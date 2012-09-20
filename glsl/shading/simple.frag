#name Approximated shadows

float getLuminosity(float distance, int numberOfIterations, int maxIterations, vec3 pointInSpace) {
	return 1.-float(numberOfIterations)/float(maxIterations);
}

#name Simple fog

float start = 0.;
float end = 10;
float max = 0.5;
float min = 0.;
float density = 0.003;

const float LOG2 = 1.442695;
float getFogIntensity(float distance, vec3 pointInSpace) {
	return clamp(exp2(-density*density*distance*distance*LOG2),0.,0.7);
//	return 1.;
	/*if (distance <= start) return min;
	if (distance >= end) return max;
	float a = distance - start;
	float b = end - start;
	float c = max - min;
	return a * c / b + min;*/
}

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
	return vec4(_hue(s,t,c.x+q), _hue(s,t,c.x), _hue(s,t,c.x-q), c.a);
}

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc)
{
	pc.x = pc.x/w-0.5;
	pc.y = pc.y/h-0.5;
	vec3 pointOnPlane = origin + planex*pc.x + planey*pc.y;
	

	vec3 direction = (pointOnPlane-position) / length(pointOnPlane-position);
	maxIt = int(maxIterations);
	vec3 calculationPoint = position;
	float distance = DE(calculationPoint);
	int i=0;
	float totalDistance = distance;

	float planeDistance = length(pointOnPlane-position);
	float pixelSize = length(planex)/w;//min(length(planex)/w, length(planey)/h);
	float threshold = thresholdFactor * pixelSize * totalDistance / planeDistance;
	while((distance > threshold) && (i < maxIt))
	{
		// We move as far as we are sure not to hit a surface
		calculationPoint = calculationPoint+distance*direction;
		// We search the nearest point of the surface
		distance = DE(calculationPoint);
		totalDistance += distance;
		threshold = thresholdFactor * pixelSize * totalDistance / planeDistance;
		i++;
		//if(distance > 100000000000000000.)
		//	return getBgColor();
	}
	if(distance > threshold)
		return getBgColor();
//	return mix(getBgColor(), getColor(distance, i, maxIt, calculationPoint),getFogIntensity(totalDistance,calculationPoint));
	float luminosity = getLuminosity(totalDistance, i, maxIt, calculationPoint);
	float hue = getColor(i, maxIt);
	float saturation = .5;//getFogIntensity(totalDistance, calculationPoint);
	vec4 fractalColor = hsl(vec4(hue, saturation, luminosity, 1.));
	return mix(getBgColor(), fractalColor, getFogIntensity(totalDistance, calculationPoint));
}

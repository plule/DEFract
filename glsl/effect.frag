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
	if(distance > threshold*10)
		return getBgColor();
	return mix(getBgColor(), getColor(distance, i, maxIt, calculationPoint),getFogIntensity(totalDistance,calculationPoint));
}

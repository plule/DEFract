vector = require("vector3d")

function love.load()
	position = vector(15, 15, 5)
	dir = {speed=2, phi=0, theta=math.pi/2}
	mouse = {x=love.mouse.getX(), y=love.mouse.getY()}
	projDist=0.4
	height = love.graphics.getHeight()
	width = love.graphics.getWidth()
	love.mouse.setGrab(true)
	love.mouse.setVisible(false)
	fractal = love.graphics.newPixelEffect [[
		extern vec3 position;
		extern vec3 direction;
		extern vec3 origin; // origin of the projection plane
		extern vec3 planex;  // definition of the projection
		extern vec3 planey;  // plane
		float w = 800.0;
		float h = 600.0;
		float foc = 4;
		int maxIteration = 200;
		int Iterations = 15;
		float threshold = 0.005;
		float Scale=2;
		int Power=8;
		float Bailout=5;
		float minRadius2 = 0.9;
		float fixedRadius2 = 5.;
		float fixedRadius = 1.;
		float foldingLimit = 2.;
/*
		void sphereFold(inout vec3 z, inout float dz) {
			float r2 = dot(z,z);
			if (r2<minRadius2) {
				// linear inner scaling
				float temp = (fixedRadius2/minRadius2);
				z *= temp;
				dz*= temp;
			} else if (r2<fixedRadius2) {
				// this is the actual sphere inversion
				float temp =(fixedRadius2/r2);
				z *= temp;
				dz*= temp;
			}
		}

		void boxFold(inout vec3 z, inout float dz) {
			z = clamp(z, -foldingLimit, foldingLimit) * 2.0 - z;
		}
		
		float DE(vec3 z)
		{
			vec3 offset = z;
			float dr = 1.0;
			for (int n = 0; n < Iterations; n++) {
				boxFold(z,dr);       // Reflect
				sphereFold(z,dr);    // Sphere Inversion

				z=Scale*z + offset;  // Scale & Translate
				dr = dr*abs(Scale)+1.0;
			}
			float r = length(z);
			return r/abs(dr);
		}*/
		
		float DE(vec3 z)
		{
			z.xy = mod((z.xy),1.0)-vec2(0.5);
			return length(z)-0.3;
		}
/*
float DE(vec3 pos) {
	vec3 z = pos;
	float dr = 1.0;
	float r = 0.0;
	for (int i = 0; i < Iterations ; i++) {
		r = length(z);
		if (r>Bailout) break;

		// convert to polar coordinates
		float theta = acos(z.z/r);
		float phi = atan(z.y,z.x);
		dr =  pow( r, Power-1.0)*Power*dr + 1.0;

		// scale and rotate the point
		float zr = pow( r,Power);
		theta = theta*Power;
		phi = phi*Power;

		// convert back to cartesian coordinates
		z = zr*vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
		z+=pos;
	}
	return 0.5*log(r)*r/dr;
}*/

		
		vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc)
		{
			pc.x = pc.x/w-0.5;
			pc.y = pc.y/h-0.5;
			vec3 p = origin + planex*pc.x + planey*pc.y;
			vec3 d = (p-position) / length(p-position);
			//p=position;
			float distance = DE(p);
			int i;
			while((distance > threshold) && (i < maxIteration))
			{
				p = p+distance*d;
				distance = DE(p);
				i++;
			}
			float j = i;
			float co = 1-j/maxIteration;
			return vec4(co);
		}
	]]
	love.graphics.setPixelEffect(fractal)
end

function love.draw()
	normalizedDir = vectorFromSpherical(1,dir.theta,dir.phi)
	origin = position+normalizedDir*projDist
	fractal:send("position", {position:unpack()})
	fractal:send("origin", {origin:unpack()})
	
	planey = vectorFromSpherical(height/1000,dir.theta-math.pi/2, dir.phi)
	fractal:send("planey", {planey:unpack()})
	
	planex = vectorFromSpherical(width/1000,math.pi/2, dir.phi+math.pi/2)
	fractal:send("planex", {planex:unpack()})
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill",0,0,width,height)
	love.graphics.setColor(255,255,255)
	--[[
	love.graphics.print("position : "..tostring(position),0,0)
	love.graphics.print("direction : "..tostring(direction),0,15)
	love.graphics.print("mouse : "..love.mouse.getY().." "..love.mouse.getX(), 0, 30)
	love.graphics.setLineWidth(1)
	love.graphics.line(position.x, position.y, position.x+direction.x*100, position.y+direction.y*100)]]
end

function love.update(dt)
	direction = vectorFromSpherical(dir.speed, dir.theta, dir.phi)
	if(love.keyboard.isDown("up")) then
		position = position + direction*dt
	end
	if(love.keyboard.isDown("u")) then
		position = position - direction*dt
	end
	if(love.keyboard.isDown("pageup")) then
		position.z = position.z + dir.speed*dt
	end
	if(love.keyboard.isDown("pagedown")) then
		position.z = position.z - dir.speed*dt
	end
	if(love.keyboard.isDown("left")) then
		direction = position + vectorFromSpherical(dir.speed, dir.theta, dir.phi-math.pi/2)
		position = position + (direction:rotated(-math.pi/2))*dt
	end
	if(love.keyboard.isDown("right")) then
		direction = position + vectorFromSpherical(dir.speed, dir.theta, dir.phi+math.pi/2)
		position = position + (direction:rotated(math.pi/2))*dt
	end
	dir.phi = dir.phi+(love.mouse.getX()-mouse.x)/100
	dir.theta = dir.theta+(love.mouse.getY()-mouse.y)/100

	mouse = {x=love.mouse.getX(), y=love.mouse.getY()}
	if mouse.x == 0 then mouse.x = width-2 end
	if mouse.x == width-1 then mouse.x = 1 end
	if mouse.y == 0 then mouse.y = height-2 end
	if mouse.y == height-1 then mouse.y = 1 end
	love.mouse.setPosition(mouse.x, mouse.y)
end

function love.keypressed(k,u)
	if k == 'escape' then
		love.event.quit()
	end
end

function vectorFromSpherical(r, theta, phi)
	return vector(	r*math.cos(phi)*math.sin(theta),
			r*math.sin(phi)*math.sin(theta),
			r*math.cos(theta))
end

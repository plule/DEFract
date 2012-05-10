vector = require("vector3d")
require("shaderGen")

function love.load()
	position = vector(-15, -15, 5)
	direction = {speed=2, phi=math.pi/6, theta=math.pi/2}
	mouse = {x=love.mouse.getX(), y=love.mouse.getY()}
	projDist=0.4
	height = love.graphics.getHeight()
	width = love.graphics.getWidth()
	love.mouse.setGrab(true)
	love.mouse.setVisible(false)
	fractFiles = {}
	for _,file in ipairs(love.filesystem.enumerate("fractals")) do
		if file:sub(-4) == ".lua" then
			table.insert(fractFiles,file)
		end
	end
	love.graphics.setBackgroundColor(0,0,0)
	loadFract(fractFiles[1])
	loadedFract = 0
	focus = true
end

function loadFract(fileName, dontChangeParams)
	fract = love.filesystem.load("fractals/"..fileName)()
	local code = fract.code
	if not code then return end
	fractal = shaderGen.getPixelEffect(code)
	if(fract.name) then
		love.graphics.setCaption("DEFract : "..fract.name)
	else
		love.graphics.setCaption("DEFract")
	end
	if(fract.position) then position = fract.position end
	if(fract.direction) then direction = fract.direction end
end

function reloadFract()
	fract = love.filesystem.load("fractals/"..fractFiles[loadedFract+1])()
	local code = fract.code
	if not code then return end
	fractal = shaderGen.getPixelEffect(code)
end

function love.draw()
	if type(fractal) == "string" then
		love.graphics.setPixelEffect()
		love.graphics.setColor(255,255,255)
		love.graphics.print("Error in fractal code",0,0)
		love.graphics.print(fractal,0,15)
		focus = false
	else
		love.graphics.setPixelEffect(fractal)
		normalizedDir = vectorFromSpherical(1,direction.theta,direction.phi)
		origin = position+normalizedDir*projDist
		fractal:send("position", {position:unpack()})
		fractal:send("origin", {origin:unpack()})
		
		planey = vectorFromSpherical(height/1000,direction.theta-math.pi/2, direction.phi)
		fractal:send("planey", {planey:unpack()})
		
		planex = vectorFromSpherical(width/1000,math.pi/2, direction.phi+math.pi/2)
		fractal:send("planex", {planex:unpack()})
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("fill",0,0,width,height)
		love.graphics.setColor(255,255,255)
	end
end

function love.update(dt)
	if(love.keyboard.isDown("up")) then
		dir = vectorFromSpherical(direction.speed, direction.theta, direction.phi)
		position = position + dir*dt
	end
	if(love.keyboard.isDown("down")) then
		dir = vectorFromSpherical(direction.speed, direction.theta, direction.phi)
		position = position - dir*dt
	end
	if(love.keyboard.isDown("pageup")) then
		position.z = position.z + direction.speed*dt
	end
	if(love.keyboard.isDown("pagedown")) then
		position.z = position.z - direction.speed*dt
	end
	if(love.keyboard.isDown("left")) then
		position = position + vectorFromSpherical(direction.speed, math.pi/2, direction.phi-math.pi/2)*dt
	end
	if(love.keyboard.isDown("right")) then
		position = position + vectorFromSpherical(direction.speed, math.pi/2, direction.phi+math.pi/2)*dt
	end
	
	if focus then
		direction.phi = direction.phi+(love.mouse.getX()-mouse.x)/100
		direction.theta = direction.theta+(love.mouse.getY()-mouse.y)/100

		mouse.x,mouse.y = love.mouse.getX(),love.mouse.getY()
		if mouse.x == 0 then mouse.x = width-2 end
		if mouse.x == width-1 then mouse.x = 1 end
		if mouse.y == 0 then mouse.y = height-2 end
		if mouse.y == height-1 then mouse.y = 1 end
		love.mouse.setPosition(mouse.x, mouse.y)
	end
end

function love.keypressed(k,u)
	if k == 'tab' then
		loadedFract = (loadedFract+1)%(#fractFiles)
		loadFract(fractFiles[loadedFract+1])
	end
	if k == 'f5' then
		reloadFract()
	end
	if k == 'escape' then
		love.mouse.setGrab(false)
		love.mouse.setVisible(true)
		focus = false
	end
end

function vectorFromSpherical(r, theta, phi)
	return vector(	r*math.cos(phi)*math.sin(theta),
			r*math.sin(phi)*math.sin(theta),
			r*math.cos(theta))
end

function love.mousepressed(x,y,button)
	mouse.x,mouse.y = love.mouse.getX(),love.mouse.getY()
	focus = true
	love.mouse.setGrab(true)
	love.mouse.setVisible(false)
	reloadFract()
end

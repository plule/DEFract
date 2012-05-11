vector = require("vector3d")
require("render")

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
	rtcanvas = love.graphics.newCanvas()
	mustRedraw = true
	love.graphics.setBackgroundColor(0,0,0)
	loadFract(fractFiles[1])
	loadedFract = 0
	focus = true
	printInfos = false

	maxIterations = 50
	threshold = 0.01
	timeCheck = 0
	lastModif = 0
end

function loadFract(fileName)
	fract = love.filesystem.load("fractals/"..fileName)()
	local code = fract.code
	lastModif = love.filesystem.getLastModified("fractals/"..fileName)
	if not code then return end
	fractal = render.getPixelEffect(code)
	if(fract.name) then
		love.graphics.setCaption("DEFract : "..fract.name)
	else
		love.graphics.setCaption("DEFract")
	end
	if(fract.position) then position = fract.position end
	if(fract.direction) then direction = fract.direction end
	if(fract.threshold) then threshold = fract.threshold end
	if(fract.maxIterations) then maxIterations = fract.maxIterations end
	mustRedraw = true
end

function reloadFract()
	fract = love.filesystem.load("fractals/"..fractFiles[loadedFract+1])()
	lastModif = love.filesystem.getLastModified("fractals/"..fractFiles[loadedFract+1])
	local code = fract.code
	if not code then return end
	fractal = render.getPixelEffect(code)
	mustRedraw = true
end

function love.draw()
	if type(fractal) == "string" then
		love.graphics.setPixelEffect()
		love.graphics.setColor(255,255,255)
		love.graphics.print("Error in fractal code",0,0)
		love.graphics.print(fractal,0,15)
		focus = false
	else
		if mustRedraw then
			rtcanvas:clear()
			rtcanvas:renderTo(drawer)
		end
		love.graphics.setColor(255,255,255)
		love.graphics.draw(rtcanvas,0,0)
		if printInfos then
			love.graphics.setPixelEffect()
			love.graphics.setColor(255,0,0)
			love.graphics.print("position "..tostring(position),0,0)
			love.graphics.print("direction : speed "..direction.speed.." phi "..direction.phi.." theta "..direction.theta,0,15)
			love.graphics.print("maxIterations : "..maxIterations.." threshold "..threshold,0,30)
		end
	end
end

function drawer()
	fractal:send("maxIterations", maxIterations)
	fractal:send("threshold",threshold)
	
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
	mustRedraw = false
	love.graphics.setPixelEffect()
end

function love.update(dt)
	timeCheck = timeCheck+dt
	if(timeCheck >= 0.5) then
		timeCheck = 0
		if(lastModif ~= love.filesystem.getLastModified("fractals/"..fractFiles[loadedFract+1])) then
			reloadFract()
		end
	end

	if(love.keyboard.isDown("up")) then
		dir = vectorFromSpherical(direction.speed, direction.theta, direction.phi)
		position = position + dir*dt
		mustRedraw = true
	end
	if(love.keyboard.isDown("down")) then
		dir = vectorFromSpherical(direction.speed, direction.theta, direction.phi)
		position = position - dir*dt
		mustRedraw = true
	end
	if(love.keyboard.isDown("pageup")) then
		position.z = position.z + direction.speed*dt
		mustRedraw = true
	end
	if(love.keyboard.isDown("pagedown")) then
		position.z = position.z - direction.speed*dt
		mustRedraw = true
	end
	if(love.keyboard.isDown("left")) then
		position = position + vectorFromSpherical(direction.speed, math.pi/2, direction.phi-math.pi/2)*dt
		mustRedraw = true
	end
	if(love.keyboard.isDown("right")) then
		position = position + vectorFromSpherical(direction.speed, math.pi/2, direction.phi+math.pi/2)*dt
		mustRedraw = true
	end
	if(love.keyboard.isDown("home")) then
		projDist = projDist+dt
		mustRedraw = true
	end
	if(love.keyboard.isDown("end")) then
		projDist = projDist-dt
		mustRedraw = true
	end
	
	if focus and (mouse.x ~= love.mouse.getX() or mouse.y ~= love.mouse.getY()) then
		mustRedraw = true
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
	if k == 'f2' then
		screenshot = love.graphics.newScreenshot()
		out = love.filesystem.newFile("out.png")
		if out:open('w') then
			if screenshot:encode(out) then
				print("screenshot saved")
			else
				print("failed to write to screenshot file")
			end
			out:close()
		else
			print("failed to open screenshot file")
		end
	end
	if k == 'escape' then
		love.event.quit()
	end
	if k== ' ' then
		printInfos = not printInfos
		mustRedraw = true
	end
end

function vectorFromSpherical(r, theta, phi)
	return vector(	r*math.cos(phi)*math.sin(theta),
			r*math.sin(phi)*math.sin(theta),
			r*math.cos(theta))
end

function love.mousepressed(x,y,button)
	if button == "wu" then
		maxIterations = maxIterations+4
		mustRedraw = true
	elseif button == "wd" then
		maxIterations = maxIterations-4
		mustRedraw = true
	else
		focus = not focus
		if focus then
			mouse.x,mouse.y = love.mouse.getX(),love.mouse.getY()
			love.mouse.setGrab(true)
			love.mouse.setVisible(false)
			reloadFract()
		else
			love.mouse.setGrab(false)
			love.mouse.setVisible(true)
		end
	end
end

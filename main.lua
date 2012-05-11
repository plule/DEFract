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
	fractals = {}
	for _,file in ipairs(love.filesystem.enumerate("fractals")) do
		if file:sub(-4) == ".lua" then
			local fractal = love.filesystem.load("fractals/"..file)() -- TODO check errors
			fractal.path = "fractals/"..file
			table.insert(fractals,fractal)
		end
	end
	rtcanvas = love.graphics.newCanvas()
	screenshotcanvas = love.graphics.newCanvas(unpack(render.hd.dim))
	mustRedraw = true
	mustRedrawHQ = true
	love.graphics.setBackgroundColor(0,0,0)
	currFractNb = 1
	currView = 1
	currFract = fractals[currFractNb]
	focus = true
	printInfos = false
	timeCheck = 0
	lastModif = 0
	maxIterations = 50
	threshold = 0.01
	
	loadParameters(currFract)
end

function loadParameters(fract)
	currView = 1
	if(fract.views[1].position) then position = fract.views[1].position end
	if(fract.views[1].direction) then direction = fract.views[1].direction end
	if(fract.rt.threshold) then threshold = fract.rt.threshold end
	if(fract.rt.maxIterations) then maxIterations = fract.rt.maxIterations end
	mustRedraw = true
end

function nextView()
	currView = ((currView)%(#(currFract.views)))+1
	local view = currFract.views[currView]
	if(view.position) then position = view.position end
	if(view.direction) then direction = view.direction end
	mustRedraw = true
end

function love.draw()
	if mustRedraw then
		render.renderTo(currFract, rtcanvas, "rt", maxIterations, threshold)
		mustRedraw = false
		mustRedrawHQ = true
	elseif mustRedrawHQ then
		render.renderTo(currFract, rtcanvas, "hq")
		mustRedrawHQ = false
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

function love.update(dt)
	timeCheck = timeCheck+dt
	if(timeCheck >= 0.5) then
		timeCheck = 0
		if lastModif ~= love.filesystem.getLastModified(currFract.path) then
			lastModif = love.filesystem.getLastModified(currFract.path)
			render.updateShader(currFract)
			mustRedraw = true
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
		if(direction.theta > math.pi) then direction.theta = math.pi end
		if(direction.theta < 0) then direction.theta = 0 end
		mouse.x,mouse.y = love.mouse.getX(),love.mouse.getY()
		if mouse.x == 0 then mouse.x = width-2 end
		if mouse.x == width-1 then mouse.x = 1 end
		if mouse.y == 0 then mouse.y = height-2 end
		if mouse.y == height-1 then mouse.y = 1 end
		love.mouse.setPosition(mouse.x, mouse.y)
	end
end
--[[
function getScreenShotIndex()
	i = 1
	while love.filesystem.exists("DEFract_"..i..".jpg") do
		i = i+1
	end
	return i
end

function storeScreenShot(index)
	render.renderTo
end

]]
function love.keypressed(k,u)
	if k == 'tab' then
		currFractNb = ((currFractNb)%(#fractals))+1
		currFract = fractals[currFractNb]
		loadParameters(currFract)
	end
	if k == 'f2' then
		render.renderTo(currFract, screenshotcanvas, "hd")
		screenshotcanvas:getImageData():encode("out.jpg")
	end
	if k == 'escape' then
		love.event.quit()
	end
	if k == 'return' then
		nextView()
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
			render.updateShader(currFract)
		else
			love.mouse.setGrab(false)
			love.mouse.setVisible(true)
		end
	end
end

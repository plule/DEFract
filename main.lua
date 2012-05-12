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
	love.filesystem.mkdir("fractals")
	examples = love.filesystem.enumerate("examples")
	for _,file in ipairs(love.filesystem.enumerate("fractals")) do
		for i,example in ipairs(examples) do
			if file == example then examples[i] = nil end
		end
		if file:sub(-4) == ".lua" then
			table.insert(fractals, parseFile("fractals/"..file))
		end
	end
	for _,file in ipairs(examples) do
		if file:sub(-4) == ".lua" then
	--		if not love.filesystem.exists("fractals/"..file) then
				src = love.filesystem.newFile("examples/"..file)
				src:open('r')
				dest = love.filesystem.newFile("fractals/"..file)
				dest:open('w')
				dest:write(src:read())
	--		end
			local fractal = parseFile("fractals/"..file)
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
	timeCheck = 0
	lastModif = 0
	animatedFractal = false
	currTime = 0
	thresholdMulti = 1
	maxIterationsMulti = 1
	zoom = 1
	loadParameters(currFract)
end

function parseFile(file, outputfract)
	outputfract = outputfract or {}
	local newFractal = love.filesystem.load(file)() -- TODO check errors
	for k,v in pairs(newFractal) do
		outputfract[k] = v
	end
	outputfract.path = file
	return outputfract
end

function loadParameters(fract)
	currView = 1
	if(fract.views[1].position) then position = fract.views[1].position:clone() end
	if(fract.views[1].direction) then
		direction.speed = fract.views[1].direction.speed
		direction.phi = fract.views[1].direction.phi
		direction.theta = fract.views[1].direction.theta
	end
	love.graphics.setCaption("DEFract : "..fract.path)
	mustRedraw = true
end

function nextView()
	currView = ((currView)%(#(currFract.views)))+1
	local view = currFract.views[currView]
	if(view.position) then position = view.position:clone() end
	if(view.direction) then
		direction.speed = view.direction.speed
		direction.phi = view.direction.phi
		direction.theta = view.direction.theta
	end
	mustRedraw = true
end

function love.draw()
	if mustRedraw or animatedFractal then
		render.renderTo(currFract, rtcanvas, "rt")
		mustRedraw = false
		mustRedrawHQ = true
	elseif mustRedrawHQ then
		render.renderTo(currFract, rtcanvas, "hq")
		mustRedrawHQ = false
	end
	love.graphics.setColor(255,255,255)
	love.graphics.draw(rtcanvas,0,0)
	if love.keyboard.isDown(' ') then
		love.graphics.setPixelEffect()
		love.graphics.setColor(0,255,0)
		love.graphics.print("position "..tostring(position),0,0)
		love.graphics.print(("direction : speed %04f phi %04f theta %04f"):format(direction.speed,direction.phi,direction.theta),0,15)
		love.graphics.print(("maxIterations : %d threshold : %04f"):format(currFract.rt.maxIterations*maxIterationsMulti, currFract.rt.threshold*thresholdMulti),0,30)
		love.graphics.print(love.filesystem.getSaveDirectory().."/"..currFract.path,0,45)
	elseif love.keyboard.isDown('pageup') or love.keyboard.isDown('pagedown') then
		love.graphics.setPixelEffect()
		love.graphics.setColor(0,255,0)
		love.graphics.print(("speed : %04f"):format(direction.speed),0,0)
	end
end

function love.update(dt)
	currTime = currTime+dt
	timeCheck = timeCheck+dt
	if(timeCheck >= 0.5) then
		timeCheck = 0
		if lastModif ~= love.filesystem.getLastModified(currFract.path) then
			lastModif = love.filesystem.getLastModified(currFract.path)
			parseFile(currFract.path, currFract)
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
		direction.speed = direction.speed+direction.speed*dt*3
	end
	if(love.keyboard.isDown("pagedown")) then
		direction.speed = direction.speed-direction.speed*dt*3
	end
	if(love.keyboard.isDown("left")) then
		position = position + vectorFromSpherical(direction.speed, math.pi/2, direction.phi-math.pi/2)*dt
		mustRedraw = true
	end
	if(love.keyboard.isDown("right")) then
		position = position + vectorFromSpherical(direction.speed, math.pi/2, direction.phi+math.pi/2)*dt
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

function storeScreenShot()
	local i = 1
	while love.filesystem.exists("DEFract_"..i..".jpg") do
		i = i+1
	end
	local name = "DEFract_"..i
	render.renderTo(currFract, screenshotcanvas, "hd")
	screenshotcanvas:getImageData():encode(name..".jpg")
	local description = love.filesystem.newFile(name..".txt")
	description:open('w')
	content = [[
{position=vector%s, direction = {speed=%f, phi=%f, theta=%f}},
-------------
filename : %s
threshold : %f
maxIterations : %i

code :
%s
	]]
	content = content:format(tostring(position), direction.speed,
			direction.phi, direction.theta, currFract.path,
			currFract.hd.threshold*thresholdMulti,
			currFract.hd.maxIterations*maxIterationsMulti,
			currFract.code)
	description:write(content)
	description:close()
end
function love.keyreleased(k,u)
	if k == 'lctrl' then
		zoom = 1
		mustRedraw = true
	end
end
function love.keypressed(k,u)
	if k == 'lctrl' then
		zoom = 10
		mustRedraw = true
	end
	if k == 'tab' then
		currFractNb = ((currFractNb)%(#fractals))+1
		currFract = fractals[currFractNb]
		maxIterationsMulti = 1
		thresholdMulti = 1
		loadParameters(currFract)
	end
	if k == 'f2' then
		storeScreenShot()
	end
	if k == 'escape' then
		love.event.quit()
	end
	if k == 'return' then
		nextView()
	end
end

function vectorFromSpherical(r, theta, phi)
	return vector(	r*math.cos(phi)*math.sin(theta),
			r*math.sin(phi)*math.sin(theta),
			r*math.cos(theta))
end

function love.mousepressed(x,y,button)
	if button == "wu" then
		maxIterationsMulti = maxIterationsMulti*1.2
		thresholdMulti = thresholdMulti/2
		mustRedraw = true
	elseif button == "wd" then
		maxIterationsMulti = maxIterationsMulti/1.2
		thresholdMulti = thresholdMulti*2
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

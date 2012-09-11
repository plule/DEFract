require "fractal"
require "parser"
require "gui"
Timer = require "hump.timer"
require "parameter"

function debug(...)
--	print("[debug]",...)
end

local function printTitle()
	titleAlpha = 255
	if titleTimer then Timer.cancel(titleTimer) end
	fader = nil
	titleTimer = Timer.add(2,
     function()
         titleTimer = Timer.add(1, function() titleAlpha = 0 end)
		 fader = Timer.Interpolator(1, function(frac) titleAlpha = 255*(1-frac) end)
	 end)
end

local function switchTo(fractal)
	fractal:load()
	currFractal = fractal
	printTitle()
end

GlobalParameters = {
	autoReload = {
		checked = false,
		label = "Automatic reload"
	}
}

function love.load()
	version = "0.5.3"
	love.filesystem.setIdentity("DEFract_"..version)

	Width = love.graphics.getWidth()
	Height = love.graphics.getHeight()
	BigFont = love.graphics.newFont('LinBiolinum_R.ttf', 40)
	SmallFont = love.graphics.newFont('Cantarell-Regular.otf',12)
	MediumFont = love.graphics.newFont('Cantarell-Regular.otf',17)
	Focus = false
	Parser.load()
	Camera:load()
	
	mouse = {}
	mouse.x,mouse.y = love.mouse.getPosition()

	love.filesystem.mkdir("fractals")
	love.filesystem.mkdir("records")
	fractals = {}
	
	examples = love.filesystem.enumerate("examples")
	users = love.filesystem.enumerate("fractals")
	-- Copy of all the fractals to user's dir
	for _,file in ipairs(examples) do
		if file:sub(-5) == ".frag" and not table.contains(users,file) then
			src = love.filesystem.newFile("examples/"..file)
			src:open('r')
			dest = love.filesystem.newFile("fractals/"..file)
			dest:open('w')
			dest:write(src:read())
		end
	end

	-- Load all this
	for _,file in ipairs(love.filesystem.enumerate("fractals")) do
		if file:sub(-5) == ".frag" then
			table.insert(fractals, Fractal("fractals/"..file))
		end
	end

	fractalSelect = Parameter
	{
		name = "Fractal Selection",
		type = "select",
		choices = fractals,
		action = switchTo
	}

	currFractIndex = 1
	currFractal = fractals[currFractIndex]
	currFractal:load()
	Gui:load()
	printTitle()
end

local function toggleFocus()
	Focus = not Focus
	mouse.x,mouse.y = love.mouse.getPosition()
end

local function setFocus()
	Focus = true
	mouse.x,mouse.y = love.mouse.getPosition()
end

local function releaseFocus()
	Focus = false
	mouse.x,mouse.y = love.mouse.getPosition()
end

function love.draw()
	currFractal:draw()
	if not Focus then
		Gui:draw()
	end
	love.graphics.setFont(BigFont)
	local whiteAlpha = 255 - (255-titleAlpha)*1.5
	if whiteAlpha < 0 then whiteAlpha = 0 end
	love.graphics.setColor(255,255,255, whiteAlpha)
	love.graphics.printf(currFractal.name, 0, Height-50, Width, 'center')
	love.graphics.setColor(0,0,0, titleAlpha)
	love.graphics.printf(currFractal.name, -1, Height-51, Width, 'center')
end

function vectorFromSpherical(r, theta, phi)
	return vector(	r*math.cos(theta)*math.sin(phi),
			r*math.sin(theta)*math.sin(phi),
			r*math.cos(phi))
end

function love.update(dt)
	Timer.update(dt)
	if fader then fader(dt) end
	love.mouse.setGrab(Focus)
	love.mouse.setVisible(not Focus)
	Gui.parametrables = {{parameters={fractalSelect}},Camera,currFractal}

	if not Focus then
		Gui:update(dt)
	end
	currFractal:update(dt)
	local camera = Camera

	if Focus and (mouse.x ~= love.mouse.getX() or mouse.y ~= love.mouse.getY()) then
		
		camera.phi = camera.phi+(love.mouse.getY()-mouse.y)/100
		camera.theta = camera.theta-(love.mouse.getX()-mouse.x)/100
		if(camera.phi > math.pi) then camera.phi = math.pi end
		if(camera.phi < 0) then camera.phi = 0 end
		if(camera.theta < 0) then camera.theta = 2*math.pi end
		if(camera.theta > 2*math.pi) then camera.theta = 0 end
		mouse.x,mouse.y = love.mouse.getPosition()
		if mouse.x == 0 then mouse.x = Width-2 end
		if mouse.x == Width-1 then mouse.x = 1 end
		if mouse.y == 0 then mouse.y = Height-2 end
		if mouse.y == Height-1 then mouse.y = 1 end
		love.mouse.setPosition(mouse.x, mouse.y)
	end
	if love.keyboard.isDown("up") or love.keyboard.isDown("z") or love.keyboard.isDown("w") then
		setFocus()
		camera:forward(dt)
	end
	if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
		setFocus()
		camera:forward(-dt)
	end
	if love.keyboard.isDown("left") or love.keyboard.isDown("a") or love.keyboard.isDown("q") then
		setFocus()
		camera:left(dt)
	end
	if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
		setFocus()
		camera:left(-dt)
	end
	if love.keyboard.isDown("pageup") then
		camera.parameters.projDist.value = camera.parameters.projDist.value + dt
	end
	if love.keyboard.isDown("pagedown") then
		camera.parameters.projDist.value = camera.parameters.projDist.value - dt
	end
end


function love.keypressed(k,u)
	if k == 'escape' then
		love.event.quit()
	end
	if k == 'tab' then
		currFractIndex = ((currFractIndex)%(#fractals))+1
		currFractal = fractals[currFractIndex]
		currFractal:load()
		printTitle()
	end
	if k == 'lctrl' then
		toggleFocus()
	end
	if k == 'f2' then
		storeScreenShot()
	end
end

function table.contains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end

function storeScreenShot()
	local i = 1
	while love.filesystem.exists("DEFract_"..i..".jpg") do
		i = i+1
	end
	local name = "DEFract_"..i
	love.graphics.newScreenshot():encode(name..".jpg")
end

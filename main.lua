require "fractal"
require "render"

function love.load()
	Width = love.graphics.getWidth()
	Height = love.graphics.getHeight()
	render.load()
	fractal = Fractal("examples/spheres.frag")
--	fractal = Fractal("examples/kaleidoscopicIFS.frag")
	--fractal = Fractal("mandelbox.frag")
	mouse = {}
	mouse.x,mouse.y = love.mouse.getPosition()
	love.mouse.setGrab(true)
	love.mouse.setVisible(false)
end

function love.draw()
	fractal:draw()
end

function vectorFromSpherical(r, theta, phi)
	return vector(	r*math.cos(theta)*math.sin(phi),
			r*math.sin(theta)*math.sin(phi),
			r*math.cos(phi))
end

function love.update(dt)
	fractal:update(dt)
	local camera = fractal.camera
	if love.keyboard.isDown("up") then
		camera:forward(dt)
	end
	if love.keyboard.isDown("down") then
		camera:forward(-dt)
	end
	if love.keyboard.isDown("pageup") then
		camera.projDist = camera.projDist + dt
	end
	if love.keyboard.isDown("pagedown") then
		camera.projDist = camera.projDist - dt
	end

	if (mouse.x ~= love.mouse.getX() or mouse.y ~= love.mouse.getY()) then
		
		camera.phi = camera.phi-(love.mouse.getY()-mouse.y)/100
		camera.theta = camera.theta-(love.mouse.getX()-mouse.x)/100
		if(camera.phi > math.pi) then camera.phi = math.pi end
		if(camera.phi < 0) then camera.phi = 0 end
		if(camera.theta < 0) then camera.theta = 2*math.pi end
		if(camera.theta > 2*math.pi) then camera.theta = 0 end
		mouse.x,mouse.y = love.mouse.getX(),love.mouse.getY()
		if mouse.x == 0 then mouse.x = Width-2 end
		if mouse.x == Width-1 then mouse.x = 1 end
		if mouse.y == 0 then mouse.y = Height-2 end
		if mouse.y == Height-1 then mouse.y = 1 end
		love.mouse.setPosition(mouse.x, mouse.y)
	end
end

function love.keypressed(k,u)
	if k == 'escape' then
		love.event.quit()
	end

end

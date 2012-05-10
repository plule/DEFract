vector = require("vector3d")

function love.load()
	position = vector(100, 100, 100)
	direction = vector(5, 0, 0):normalized()
	mouse = {x=love.mouse.getX(), y=love.mouse.getY()}
	speed = 100
	height = love.graphics.getHeight()
	width = love.graphics.getWidth()
	love.mouse.setGrab(true)
	love.mouse.setVisible(false)
end

function love.draw()
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill",0,0,height,width)
	love.graphics.setColor(255,255,255)
	love.graphics.print("position : "..tostring(position),0,0)
	love.graphics.print("direction : "..tostring(direction),0,15)
	love.graphics.print("mouse : "..love.mouse.getY().." "..love.mouse.getX(), 0, 30)
	s = {direction:spherical()}
	love.graphics.print("spherical : r "..s[1].. " phi "..s[2].." theta "..s[3], 0, 45)
	love.graphics.setLineWidth(1)
	love.graphics.line(position.x, position.z, position.x+direction.x*100, position.z+direction.z*100)
end

function love.update(dt)
	if(love.keyboard.isDown("up")) then
		position = position + direction*speed*dt
	end
	if(love.keyboard.isDown("down")) then
		position = position - direction*speed*dt
	end
	--direction:rotate_inplace((love.mouse.getX()-mouse.x)/100, (love.mouse.getY()-mouse.y)/100)
	direction:yaw_inplace((love.mouse.getX()-mouse.x)/100)
	direction:pitch_inplace((love.mouse.getY()-mouse.y)/100)
	mouse = {x=love.mouse.getX(), y=love.mouse.getY()}
	if mouse.x == 0 then mouse.x = width-2 end
	if mouse.x == width-1 then mouse.x = 1 end
	if mouse.y == 0 then mouse.y = height-2 end
	if mouse.y == height-1 then mouse.y = 1 end
	love.mouse.setPosition(mouse.x, mouse.y)
end

function love.keypressed(k)
   if k == 'escape' then
      love.event.quit()
   end
end

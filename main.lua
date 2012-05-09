function love.load()
	height = love.graphics.getHeight()
	width = love.graphics.getWidth()
end

function love.draw()
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill",0,0,height,width)
end

function love.keypressed(k)
   if k == 'escape' then
      love.event.quit()
   end
end

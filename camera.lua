Class = require "hump.class"
vector = require "vector3d"

Camera = Class{
	function(self, x,y,z, speed, theta, phi, projDist, threshold, maxIterations)
		self.position = vector(x,y,z)
		self.speed = speed
		self.theta = theta
		self.phi = phi
		self.projDist = projDist
		self.threshold = threshold
		self.maxIterations = maxIterations
	end}

function Camera:getMaxIterations()
	return self.maxIterations
end

function Camera:getThreshold()
	return self.threshold
end

-- Position of the camera
function Camera:getPosition()
	return self.position
end

-- X vector of the projection plane
function Camera:getPlaneX()
	return vectorFromSpherical(Height/1000, self.theta-math.pi/2, math.pi/2)
end

-- Y vector of the projection plane
function Camera:getPlaneY()
	return vectorFromSpherical(Width/1000, self.theta, self.phi-math.pi/2)
end

-- Origin of the projection plane
function Camera:getOrigin()
--	local origin = self.position + relativeCenter-- - self:getPlaneX()/2 - self:getPlaneY()/2
--	local ratio = Height/render.dim[2]
	local planeCenter = self.position + self:getDirection()*self.projDist
	return planeCenter-- - self:getPlaneX()/2 + self:getPlaneY()/2
end

function Camera:getDirection()
	return vectorFromSpherical(1,self.theta,self.phi)
end

function Camera:forward(dt)
	local direction =  vectorFromSpherical(self.speed, self.theta, self.phi)
	self.position = self.position + direction*dt
end

function Camera:draw()
	love.graphics.setColor(255,255,0)
	love.graphics.print("theta "..self.theta,10, 10)
	love.graphics.print("phi "..self.phi,10, 25)
	love.graphics.print("position"..self.position:to_s(),10,40)
	love.graphics.print("origin "..self:getOrigin():to_s(),10, 55)
	love.graphics.print("direction "..self:getDirection():to_s(), 10, 70)
	love.graphics.print("projDist "..self.projDist, 10, 85)
end

vector = require "vector3d"
require "parameter"

Camera = {}

function Camera.setColorMode(mode)
	currFractal:reload()
end

function Camera:load()
	debug("========== Init camera")
	self.parameters = {
		coloring = Parameter{name = "Coloring Mode",
							 type = "select",
							 choices = Parser.colorModes,
							 action = self.setColorMode}
	}
	self.title = "Parameters of the Camera"
end

function Camera:update(x,y,z, speed, theta, phi, projDist, threshold, maxIterations, fractal)
	self.position = vector(x,y,z)
	self.theta = theta
	self.phi = phi
	self.parameters.speed = Parameter{name="Speed", type="float", value=speed, min=0.0000001,max=10}
	self.parameters.projDist = Parameter{name="Projection Distance", type="float", value=projDist, min=0, max=2}							 
	self.parameters.threshold = Parameter{name="Threshold", kname="threshold", shader=true, type="float", value=threshold, min=0.00001, max=0.005}
	self.parameters.maxIterations = Parameter{name="Max iterations", kname="maxIterations", shader=true, type="int", value=maxIterations, min=5, max=200}
end

function Camera:getMaxIterations()
	return self.parameters.maxIterations:getValue()
end

function Camera:getThreshold()
	return self.parameters.threshold:getValue()
end

function Camera:getSpeed()
	return self.parameters.speed.value--*self.speedMultiplier.value*self.speedMultiplier2.value
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
	local planeCenter = self.position + self:getDirection()*self.parameters.projDist.value
	return planeCenter-- - self:getPlaneX()/2 + self:getPlaneY()/2
end

function Camera:getDirection()
	return vectorFromSpherical(1,self.theta,self.phi)
end

function Camera:forward(dt)
	local direction =  vectorFromSpherical(self:getSpeed(), self.theta, self.phi)
	self.position = self.position + direction*dt
end

function Camera:left(dt)
	local direction = vectorFromSpherical(self:getSpeed(), self.theta+math.pi/2,math.pi/2)
	self.position = self.position + direction*dt
end

function Camera:draw()
	love.graphics.setColor(255,255,0)
	love.graphics.print("theta "..self.theta,10, 10)
	love.graphics.print("phi "..self.phi,10, 25)
	love.graphics.print("position"..self.position:to_s(),10,40)
	love.graphics.print("origin "..self:getOrigin():to_s(),10, 55)
	love.graphics.print("direction "..self:getDirection():to_s(), 10, 70)
	love.graphics.print("projDist "..self.projDist.value, 10, 85)
	love.graphics.print("maxit "..self.maxIterations.value,10,100)
	love.graphics.print("speed "..self.speed.value,10,115)
end

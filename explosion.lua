require("lovepunk.entity")
require("helpfuldog")
require("hitsmoke")
Explosion = Entity.new(0, 0, 100, 100)
Explosion.__index = Explosion

function Explosion.new(x, y)
	local self = setmetatable({}, Explosion)
	self.type = "explosion"
	self.x = x - self.width/2
	self.y = y - self.height/2
	self.image = love.graphics.newImage("assets/img/explosion.png")

	local anim8 = require "libs.anim8"
	local grid = anim8.newGrid(100, 100, self.image:getWidth(), self.image:getHeight())
	self.lifetime = 0.44
	self.anim = anim8.newAnimation(grid('1-5', 1), {['1-2']=0.08, ['3-5']=0.1})

	self.timer= 0
	self.scale = 1

	return self
end
function Explosion:added()
	self.scene:shake(0.2)
	self.scene.bumpWorld:update(self, self.x, self.y, self.width, self.height)
	local _,_,cols,len = self.scene.bumpWorld:check(self, self.x, self.y, checkingFilter)
	for _, col in pairs(cols) do
		print(col.other.type)
		if (col.other.type == "enemy") then
			col.other:die()
		end
	end
end
function Explosion:update(dt)
	self.anim:update(dt)
	self.timer = self.timer + dt
	if (self.timer > self.lifetime) then
		self.scene:remove(self)
	end
end
function Explosion:draw()
	self.anim:draw(self.image, self.x, self.y, 0, self.scale, self.scale, self.originX, self.originY)
end

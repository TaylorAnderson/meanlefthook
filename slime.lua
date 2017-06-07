require("lovepunk.entity")
require("helpfuldog")
require("grapple")
Slime = Enemy.new(0, 0, 18, 18)
Slime.__index = Slime
function Slime.new(x, y)
	local self = setmetatable({}, Slime)
	self.x = x
	self.y = y
	self.originX = -16
	self.v = {x=0.5, y=0}
	local rand = randomRange(1, 2)
	print(rand)
	if (rand <= 1) then self.v.x = 0.5
	else self.v.x = -0.5 end
	self.type = "enemy"
	self.image = love.graphics.newImage("assets/img/enemy.png")
	self.collisionMap = {["level"]="touch"}

	local anim8 = require "libs.anim8"
	local grid = anim8.newGrid(24, 24, self.image:getWidth(), self.image:getHeight())
	self.anim = anim8.newAnimation(grid('1-2', 1, '1-2', 2), 0.1)
	self.currentAnim = self.anim
	return self
end
function Slime:update(dt)
	local distToAdd = 0
	if (self.v.x > 0) then distToAdd = distToAdd + self.width end

	local items, len = self.scene.bumpWorld:queryPoint(self.x + distToAdd, self.y + self.height + 1) -- 1 pixel below the left bottom corner of the object
	local foundLevel = false
	for i = 1, len do
		if (items[i].type == "level") then foundLevel = true end
	end
	if self:collide("level", self.x + self.v.x, self.y) then self.v.x = self.v.x * -1 end

	Enemy.update(self, dt)
	self:updateAnimation(dt)
end

function Slime:draw()
	Enemy.draw(self)
	self.currentAnim:draw(self.image, self.x, self.y - 6, 0, self.scaleX, self.scaleY, self.originX, self.originY)
end
function Slime:updateAnimation(dt)
	self.currentAnim:update(dt)
	if (isCloseTo(self.v.x, 0, 0.5)) then self.currentAnim:gotoFrame(1)
	else self.currentAnim:resume()
	end
	self:flip(self.v.x<0)
end

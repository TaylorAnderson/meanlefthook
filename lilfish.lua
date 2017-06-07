require("lovepunk.entity")
require("helpfuldog")
require("grapple")
LilFish = Enemy.new(0, 0, 16, 16)
LilFish.__index = LilFish
function LilFish.new(x, y)
	local self = setmetatable({}, LilFish)
	self.x = x
	self.y = y
	self.v = {x=0.3, y=0}
	self.type = "enemy"
	self.image = love.graphics.newImage("assets/img/lilfish-sheet.png")
	self.collisionMap = {["level"]="touch"}
	self.layer = 10
	local anim8 = require "libs.anim8"
	local grid = anim8.newGrid(16, 16, self.image:getWidth(), self.image:getHeight())
	self.anim = anim8.newAnimation(grid('1-4', 1), 0.1)
	self.currentAnim = self.anim
	return self
end
function LilFish:update(dt)
	Enemy.update(self, dt)

	local distToAdd = 0
	if (self.v.x > 0) then distToAdd = distToAdd + self.width end

	local items, len = self.scene.bumpWorld:queryPoint(self.x + distToAdd, self.y + self.height + 1) -- 1 pixel below the left bottom corner of the object
	local foundLevel = false
	for i = 1, len do
		if (items[i].type == "level") then foundLevel = true end
	end
	if not foundLevel or self:collide("level", self.x + self.v.x, self.y) then self.v.x = self.v.x * -1 end

	self:updateAnimation(dt)
end

function LilFish:draw()
	self.currentAnim:draw(self.image, self.x, self.y, 0, self.scaleX, self.scaleY, self.originX, self.originY)
end
function LilFish:updateAnimation(dt)
	self.currentAnim:update(dt)
	if (isCloseTo(self.v.x, 0, 0.3)) then self.currentAnim:gotoFrame(1)
	else self.currentAnim:resume()
	end
	self:flip(self.v.x<0)
end

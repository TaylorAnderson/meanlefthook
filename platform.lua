require("lovepunk.entity")
require("helpfuldog")
require("grapple")
Platform = Entity.new(0, 0, 80, 12)
Platform.__index = Platform
function Platform.new(x, y)
	local self = setmetatable({}, Platform)
	self.x = x
	self.y = y
	self.originX = 0
	self.speed = gs/1.7
	self.accel = self.speed / 10
	self.v = {x=1, y=0}
	self.type = "level"
	self.image = love.graphics.newImage("assets/img/platform.png")
	self.collisionMap = {["level"]="touch"}
	return self
end
function Platform:update(dt)

	self:move()
	local distToAdd = 0
	if (self.v.x > 0) then distToAdd = distToAdd + self.width end
	if self:collide("level", self.x + self.v.x, self.y) then self.v.x = self.v.x * -1 end

end
function Platform:draw()
	love.graphics.draw(self.image, self.x, self.y, 0, self.scaleX, self.scaleY, self.originX, self.originY)
end

function Platform:move()
	local _,_,cols = self.scene.bumpWorld:check(self, self.x + self.v.x, self.y + self.v.y-1, entityFilter)
	for _, c in pairs(cols) do
		if (c.other.type == "level") then
			self.v.x = self.v.x + c.normal.x*math.abs(self.v.x)
			self.v.y = self.v.y + c.normal.y*math.abs(self.v.y)
		end
		if (c.other.type == "player") then
			print ("occurring")
			if (sign(self.v.x) == sign(c.other.v.x) or isCloseTo(c.other.v.x, 0, 0.5)) then c.other.v.x = c.other.v.x + self.v.x/1.5 end
		end
	end
	self.x = self.x + self.v.x
	self.y = self.y + self.v.y
	self.scene.bumpWorld:update(self, self.x, self.y)
end

function Platform:flip(reverse)
	if (reverse) then
		self.originX = self.width
		self.scaleX = -1
	else
		self.originX = 0
		self.scaleX = 1
	end
end

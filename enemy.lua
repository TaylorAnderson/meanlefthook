require("lovepunk.entity")
require("helpfuldog")
require("grapple")
Enemy = Entity.new(0, 0, 18, 18)
Enemy.__index = Enemy
function Enemy.new(x, y, w, h)
	local self = setmetatable({}, Enemy)
	self.x = x
	self.y = y
	self.width = w
	self.height = h
	self.friction = 0.6
	self.gravity = 0.2
	self.normalGravity = 0.2
	self.speed = gs/1.7
	self.accel = self.speed / 10
	self.v = {x=0, y=0}
	self.grounded = false
	self.type = "enemy"
	self.collisionMap = {["level"]="touch"}

	return self
end
function Enemy:update(dt)
	self:move()
end

function Enemy:move()
	self.v.y = self.v.y + self.gravity
	local _,_,cols = self.scene.bumpWorld:check(self, self.x + self.v.x, self.y + self.v.y, entityFilter)
	for _, c in pairs(cols) do
		if (c.other.type == "level") then
			self.v.x = self.v.x + c.normal.x*math.abs(self.v.x)
			self.v.y = self.v.y + c.normal.y*math.abs(self.v.y)
		end
	end
	self.x = self.x + self.v.x
	self.y = self.y + self.v.y
	self.scene.bumpWorld:update(self, self.x, self.y)
end

function Enemy:die()
	self.scene:add(HitFx.new(self.x + self.width/2, self.y + self.height/2))
	self.scene:shake(0.2, 3)
	self.scene:remove(self)
end
function Enemy:flip(reverse)
	if (reverse) then
		self.originX = self.width + 4
		self.scaleX = -1
	else
		self.originX = 4
		self.scaleX = 1
	end
end

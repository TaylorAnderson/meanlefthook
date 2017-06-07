require("lovepunk.entity")
require("helpfuldog")
Carryable = Entity.new(0, 0, 10, 10)
Carryable.__index = Carryable
function Carryable.new(x, y, w, h)
	local self = setmetatable({}, Carryable)
	self.x = x
	self.y = y
	self.width = w;
	self.height = h
	self.rotation = 0
	self.gravity = 0.2
	self.friction = 0.98
	self.type="carryable"
	self.player = player
	self.layer = -4
	self.scale = 1
	self.collidable = true
	return self
end
function Carryable:added()

end
function Carryable:update(dt)
	if not self.beingCarried then
		self:move()
	end
end

function Carryable:draw()
end
function Carryable:move()
	self.v.y = self.v.y + self.gravity
	self.v.x = self.v.x * self.friction
	local _,_,cols = self.scene.bumpWorld:move(self, self.x + self.v.x, self.y + self.v.y, entityFilter)
	for _, c in pairs(cols) do
		if (c.other.type == "level") then
			local bounce = 1
			if not isCloseTo(self.v.x, 0, 0.7) and not isCloseTo(self.v.y, 0, 0.7) then bounce = 1.1
			else bounce = 1 end

			self.v.x = self.v.x + c.normal.x*math.abs(self.v.x)*bounce
			self.v.y = self.v.y + c.normal.y*math.abs(self.v.y)*bounce
			if (c.other.v) then
				if (sign(self.v.x) == sign(c.other.v.x) or isCloseTo(self.v.x, 0, 0.5)) then self.v.x = self.v.x + c.other.v.x/2.5 end
			end
		end
	end
	self.x = self.x + self.v.x
	self.y = self.y + self.v.y
	self.scene.bumpWorld:update(self, self.x, self.y)
end

function Carryable:throw(v)
	self.beingCarried = false
	self.collidable = true
	self.v = v
	self.thrown = true
end

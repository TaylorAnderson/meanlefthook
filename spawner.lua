require("lovepunk.entity")
require("helpfuldog")
require("grapple")
require("slime")
Spawner = Entity.new(0, 0, 18, 18)
Spawner.__index = Spawner
function Spawner.new(x, y)
	local self = setmetatable({}, Spawner)
	self.x = x
	self.y = y
	self.type = "spawner"
	self.timer = 0
	return self
end
function Spawner:update(dt)
	self.timer = self.timer + dt
	if self.timer > 5 then
		self.scene:add(Slime.new(self.x, self.y))
		self.timer=0
	end

end

function Spawner:die()
	self.scene:add(HitFx.new(self.x + self.width/2, self.y + self.height/2))
	self.scene:shake(0.2, 3)
	self.scene:remove(self)
end

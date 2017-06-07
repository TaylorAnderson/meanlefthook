
require("carryable")
require("explosion")
Bomb = Carryable.new(0, 0, 14, 15)
Bomb.__index = Bomb

function Bomb.new(x, y)
	local self = setmetatable({}, Bomb)
	self.x = x
	self.y = y
	self.image = love.graphics.newImage("assets/img/bomb.png")
	self.lifetime = 120
	self.ignited =false
	return self
end
function Bomb:update()
	Carryable.update(self)
	if (self.ignited) then self.lifetime = self.lifetime - 1 end
	if (self.lifetime < 0) then
		self.scene:add(Explosion.new(self.x + self.width/2, self.y + self.height/2))
		self.scene:remove(self)

	end
end
function Bomb:explode()

end
function Bomb:throw(v)
	Carryable.throw(self, v)
	self.ignited = true
end
function Bomb:draw()
	if (self.lifetime < 60) then love.graphics.setColor(200, 10, 10, 255) end
	love.graphics.draw(self.image, self.x, self.y, self.rotation, self.scaleX, self.scaleY, self.originX, self.originY)
end

require("lovepunk.entity")
require("helpfuldog")
HitSmoke = Entity.new(0, 0, 10, 10)
HitSmoke.__index = HitSmoke
function HitSmoke.new(x, y, v)
	local self = setmetatable({}, HitSmoke)
	self.x = x
	self.y = y
	self.v = v
	self.rotation = 0
	self.image = love.graphics.newImage("assets/img/hitsmoke.png")

	self.originX = self.image:getWidth()/2
	self.originY = self.image:getHeight()/2

	self.player = player
	self.setLength = false
	self.layer = 10
	self.lifetime = 0.5
	self.scale = 1
	return self
end
function HitSmoke:added()
	self.scene.tweener.to(self, self.lifetime, {scale = 0}):ease("expoin")
end
function HitSmoke:update(dt)
	self.x = self.x + self.v.x
	self.y = self.y + self.v.y
	self.rotation = self.rotation + 0.1
end
function HitSmoke:draw()
	love.graphics.draw(self.image, self.x, self.y, self.rotation, self.scale, self.scale, self.originX, self.originY)
end

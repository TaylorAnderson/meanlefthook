require("lovepunk.entity")
require("helpfuldog")
Grapple = Entity.new(0, 0, 10, 10)
Grapple.__index = Grapple
function Grapple.new(player, x, y, v)
	local self = setmetatable({}, Grapple)
	self.x = x
	self.y = y
	self.friction = 0.6
	self.gravity = 0.2
	self.v = v
	self.grounded = false
	self.rotation = 0
	self.originX = 0
	self.originY = 0
	self.type = "grapple"
	self.image = love.graphics.newImage("assets/img/grapple.png")
	self.length = 70
	self.player = player
	self.setLength = false
	self.layer = 10

	self.grabbedObject = false
	return self
end
function Grapple:update(dt)
	self.x = self.x + self.v.x
	self.y = self.y + self.v.y
	if self:collide("level", self.x, self.y) then
		self.stuck = self:collide("level", self.x, self.y)
	elseif self:collide("enemy", self.x, self.y) then
		if (not self.stuck) then self.scene.pauseTimer = 0.15 end
		self.stuck = self:collide("enemy", self.x, self.y)
	elseif self:collide("carryable", self.x, self.y) then
		self.stuck = self:collide("carryable", self.x, self.y)
	end

	if (self.stuck) then
		if (self.stuck.type == "enemy") then
			self.length = self.length - 1
		end
		if (self.stuck.type == "level") then
			self.v.x = self.stuck.v.x
			self.v.y = self.stuck.v.y
			if not self.setLength then
				self.length = distance(self.x, self.y, self.player.x, self.player.y)
				self.setLength = true
			end
		end
		if (self.stuck.type == "carryable") and self.stuck.collidable then
			local towardsPlayer = findVector({x=self.player.x + self.player.width/2, y=self.player.y + self.player.height/2}, {x=self.stuck.x+self.stuck.width/2, y=self.stuck.y+self.stuck.height/2}, 10, true)
			self.stuck.x = self.stuck.x + towardsPlayer.x
			self.stuck.y = self.stuck.y + towardsPlayer.y
			self.v = towardsPlayer
			self.grabbedObject = true
			self.stuck.thrown = false
			self.setLength = true
		end
	else self.setLength = false
	end
	if (self:collide("player", self.x, self.y) and self.grabbedObject) then
		self.stuck = nil
		self.setLength = false
		self.scene:remove(self)
	end

	if distance(self.x, self.y, self.player.x, self.player.y) > self.length*2 then
		self.scene:remove(self)
	end
end

function Grapple:draw()
	local xPos = self.x + self.width/2;
	local yPos = self.y + self.height/2;
	local pScreenX = self.player.x + self.player.width/2;
	local pScreenY = self.player.y + self.player.height/2;
	love.graphics.setColor(184, 103, 84)
	pixelLine(xPos, yPos, pScreenX, pScreenY)
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.image, self.x, self.y, self.rotation, self.scaleX, self.scaleY, self.originX, self.originY)

end

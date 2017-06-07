require("lovepunk.entity")
require("helpfuldog")
Reticule = Entity.new(0, 0, 18, 18)
Reticule.__index = Reticule
function Reticule.new(player)
	local self = setmetatable({}, Reticule)
	self.x = x
	self.y = y
	self.type = "reticule"
	self.image = love.graphics.newImage("assets/img/reticule-normal.png")
	self.locked = love.graphics.newImage("assets/img/reticule-locked.png")
	local anim8 = require "libs.anim8"
	local grid = anim8.newGrid(30, 30, self.locked:getWidth(), self.locked:getHeight())
	self.lockedAnim = anim8.newAnimation(grid('1-5', 1), 0.07)
	self.layer = -2
	love.mouse.setVisible(false)
	self.lockedOn = nil
	self.target = {x=0, y=0}
	self.player = player
	return self
end
function Reticule:update(dt)
	self.lockedOn = nil
	if (self:collide("enemy", self.x, self.y)) then
		self.lockedOn = self:collide("enemy", self.x, self.y)
	end
	if (self:collide("carryable", self.x, self.y)) then
		if (self:collide("carryable").collidable) then
			self.lockedOn = self:collide("carryable", self.x, self.y)
		end
	end


	self.x = love.mouse.getX()/4 - self.scene.camera.x - self.width/2
	self.y = love.mouse.getY()/4 - self.scene.camera.y - self.height/2
	if (self.lockedOn) then
		self.lockedAnim:update(dt)
	end
end

function Reticule:draw()
	local towardsPlayer = findVector({x=self.player.x + self.player.width/2, y=self.player.y + self.player.height/2}, {x=love.mouse.getX()/4 - self.scene.camera.x, y=love.mouse.getY()/4 - self.scene.camera.y}, 6, true)
	if (self.lockedOn == nil) then self.alpha = 1
	else self.alpha = 1 end
	love.graphics.setColor(255, 255, 255, self.alpha*255)

	if (self.lockedOn == nil) then
		self.target.x = love.mouse.getX()/4 - self.scene.camera.x + towardsPlayer.x
		self.target.y = love.mouse.getY()/4 - self.scene.camera.y + towardsPlayer.y
		love.graphics.draw(self.image, self.x + 5, self.y + 5, 0, self.scaleX, self.scaleY, self.originX, self.originY)
		dashedPixelLine(self.player.x + self.player.width/2, self.player.y + self.player.height/2, love.mouse.getX()/4 - self.scene.camera.x + towardsPlayer.x, love.mouse.getY()/4 - self.scene.camera.y + towardsPlayer.y, 10, 8)
	else
		local curWidth, curHeight = self.lockedAnim:getDimensions()

		local xPos = self.lockedOn.x + self.lockedOn.width/2-curWidth/2
		local yPos = self.lockedOn.y+self.lockedOn.height/2-curHeight/2

		local linePosX = self.lockedOn.x + self.lockedOn.width/2
		local linePosY = self.lockedOn.y + self.lockedOn.height/2
		self.target.x = linePosX
		self.target.y = linePosY
		local towardsPlayer = findVector({x=self.player.x + self.player.width/2, y=self.player.y + self.player.height/2}, {x=linePosX, y=linePosY}, 20, true)

		self.lockedAnim:draw(self.locked, xPos, yPos, 0, self.scaleX, self.scaleY, self.originX, self.originY)
		dashedPixelLine(self.player.x + self.player.width/2, self.player.y + self.player.height/2, linePosX + towardsPlayer.x, linePosY + towardsPlayer.y, 10, 8)
	end
	--love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

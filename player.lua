require("lovepunk.entity")
require("physicsobject")
require("helpfuldog")
require("grapple")
require("hiteffect")
Player = PhysicsObject.new(0, 0, gs, gs)
Player.__index = Player

S_GRAPPLING = "grappling"
 S_WALLCLIMBING = "wallclimbing"
S_DIVEKICKING = "divekicking"
S_INAIR = "inair"
S_ONGROUND = "onground"
S_NONE = "none"

function Player.new(x, y)
	local self = setmetatable({}, Player)
	self.x = x
	self.y = y
	self.keys= {
		left = moveLeft,
		right = moveRight,
		up = jump
	}
	self.friction = 0.6
	self.grappleFriction = 0.993
	self.normalFriction = 0.6
	self.gravity = 0.1
	
	self.normalGravity = 0.1
	self.wallGravity = 0.05
	self.speed = gs/2.5
	self.accel = self.speed / 10
	self.v = {x=0, y=0}
	self.jumpSpeed = self.gravity*20;
	self.grounded = false
	self.type = "player"
	self.image = love.graphics.newImage("assets/img/player.png")
	local anim8 = require "libs.anim8"
	local grid = anim8.newGrid(18, 17, self.image:getWidth(), self.image:getHeight())
	self.runAnim = anim8.newAnimation(grid('1-3', 1, '1-3', 2), 0.1)
	self.wallAnim = anim8.newAnimation(grid(1, 3), 0.1)
	self.diveAnim = anim8.newAnimation(grid(2, 3), 0.1)
	self.currentAnim = self.wallAnim
	self.collisionMap = {["level"]="slide", ["enemy"]="cross"}
	self.originY = 1
	self.grappleSet = false;
	self.carrying = nil
	self.diveTarget = nil

	self.carryingOffset = self.width/1.5
	self.layer = -3
	

	self.filters = {["level"]="slide"}
	self.collideTypes = {"level"}
	self.bounciness = 0.2;
	return self

end

function Player:update(dt)
	
	self.grounded = self:collide("level", self.x, self.y + 1) ~= nil
	self:checkState()
	self:stateUpdate()
	self:move()
	self:updateAnimation(dt)
	if (self.carrying) then
		self.carrying.x = self.x + self.carryingOffset
		self.carrying.y = self.y + self.height/2 - self.carrying.height/2
	end
	PhysicsObject.update(self);
end

function Player:move()
	self.x = self.x + self.v.x
	self.y = self.y + self.v.y
end

function Player:draw()
	self.currentAnim:draw(self.image, self.x, self.y, 0, self.scaleX, self.scaleY, self.originX, self.originY)
end

function Player:checkState()
	if (self.grapple ~= nil and self.grapple.scene ~= nil and self.grapple.stuck) then
		if (self.grapple.stuck.type == "level") then
			self.state = S_GRAPPLING
		elseif (self.grapple.stuck.type == "enemy") then
			local enemy = self.grapple.stuck
			if (enemy.y > self.y) then
				if (self.state ~= S_DIVEKICKING) then self.v = findVector({x=self.x + self.width/2, y=self.y + self.height/2}, {x=enemy.x, y=enemy.y}, 10) end
				self.state = S_DIVEKICKING
			end
			self.scene:remove(self.grapple)
		end
	--ie, if you're divekicking, continue to divekick until you hit the level.
	elseif (self.state == S_DIVEKICKING and not self:collide("level", self.x, self.y+1)) then
		self.state = S_DIVEKICKING
	elseif (self:collide("level", self.x+1, self.y) or self:collide("level", self.x-1, self.y)) and not self.grounded and self.v.y > 0 then
		self.state = S_WALLCLIMBING
	elseif self.grounded then
		self.state = S_ONGROUND
	else self.state = S_INAIR
	end

	if (self.state ~= S_DIVEKICKING) then self.diveTarget = nil end
end

function Player:stateUpdate()
	if (self.state == S_WALLCLIMBING) then
		if (self.gravity ~= self.wallGravity) then self.v.y = 0 end
		self.gravity = self.wallGravity
		if self:collide("level", self.x+1, self.y) then
			self:flip(true)
		else self:flip(false)
		end
	else self.gravity = self.normalGravity
	end

	if (self.state == S_GRAPPLING) then
		if (distance(self.x + self.v.x, self.y + self.v.y, self.grapple.x, self.grapple.y) > self.grapple.length) then
			--REMEMBER: this is happening when the player is ALREADY OUTSIDE THE RANGE OF THE GRAPPLE.
			local dir = findVector({x=self.grapple.x, y=self.grapple.y}, {x=self.x + self.v.x, y=self.y + self.v.y}, self.grapple.length)
			--the distance between the player and the closest point that the tether can reach her from.
			local dist = distance(self.grapple.x + dir.x, self.grapple.y + dir.y, self.x + self.v.x, self.y + self.v.y)
			local grappleV = findVector({x=self.x + self.width/2, y=self.y + self.height/2}, {x=self.grapple.x + self.grapple.width/2, y=self.grapple.y + self.grapple.height/2}, dist)
			self.v.x = self.v.x + grappleV.x;
			self.v.y = self.v.y + grappleV.y;
		end


		local towardsPlayer = findVector({x=self.x + self.width/2, y=self.y + self.height/2}, {x=self.grapple.x + self.grapple.width/2, y=self.grapple.y + self.grapple.height/2}, self.grapple.width)


		if (love.mouse.isDown(1) and self.grapple.length > 20 and not self:collide("level", self.x + self.v.x*2, self.y + self.v.y*2)) then
			self.grapple.length= self.grapple.length-2
		end

		self.friction = self.grappleFriction
	end

	if (self.state == S_DIVEKICKING) then
		self.collisionMap.enemy = "bounce"
		if (self:collide("enemy", self.x, self.y+1)) then
			local enemy = self:collide("enemy", self.x, self.y+1)
			enemy:die()
			self.state = S_INAIR
			self.v.y = self.v.y * -0.7

		end
	else self.collisionMap.enemy = "cross"
	end

	if (self.state ~= S_GRAPPLING and self.state ~= S_DIVEKICKING) then
		self:updateControls()
	end

	if (self.state ~= S_DIVEKICKING) then
		self.v.x = self.v.x * self.friction
		self.v.y = self.v.y + self.gravity
	end

	if (self.state == S_ONGROUND or self.state == S_INAIR) then
		self.friction = self.normalFriction
	end
end

function Player:updateControls()
	if pressing("left") then self:moveLeft() end
	if pressing("right") then self:moveRight() end
	if pressing("up") and (self.grounded or self.state == S_WALLCLIMBING) then self:jump() end
end

function Player:updateAnimation(dt)
	self.currentAnim:update(dt)
	if (self.state == S_WALLCLIMBING) then
		self.currentAnim = self.wallAnim

	elseif (self.state == S_DIVEKICKING) then
		self.currentAnim = self.diveAnim
		self:flip(self.v.x < 0)
	elseif (self.state ~= S_GRAPPLING) then
		self.currentAnim = self.runAnim
		if pressing("left") or pressing("right") then self.currentAnim:resume()
		else self.currentAnim:gotoFrame(1)
		end

		if not self.grounded then self.currentAnim:gotoFrame(2) end
	else
		--self.currentAnim:gotoFrame(2);
	end

	if (state ~= S_DIVEKICKING and state ~= S_WALLCLIMBING) then
		if (pressing("right")) then
			self:flip(false)
		end
		if pressing("left") then self:flip(true)
		end
	end
end

function Player:mousepressed(mouseX, mouseY, button, isTouch)
	if button == 1 then

		if (not self.grapple or not self.grapple.scene) and not self.carrying then
			self.grappleSet = false
			self.grapple = Grapple.new(self, self.x, self.y, findVector({x=self.x, y=self.y}, {x=self.reticule.target.x, y=self.reticule.target.y - 5}, 10, false))
			self.scene:add(self.grapple)
		end

		if (self.carrying) then
			self.carrying.x = self.x + self.width/2 - self.carrying.width/2
			self.carrying.y = self.y + self.height/2 - self.carrying.height/2
			self.carrying:throw(findVector({x=self.x, y=self.y}, {x=self.reticule.target.x, y=self.reticule.target.y-5}, 5))
			self.carrying = nil

		end
	end
end

function Player:mousereleased(mouseX, mouseY, button, isTouch)
	if (self.grapple ~= nil and self.grapple.scene ~= nil and self.grappleSet) then
		self.scene:remove(self.grapple)
		self.grappleSet = false
	end
	self.grappleSet = true
end

function Player:moveLeft()
	self.v.x = self.v.x - self.accel
end

function Player:moveRight()
	self.v.x = self.v.x + self.accel
end

function Player:jump()
	self.v.y = -self.jumpSpeed
	if (self.state == S_WALLCLIMBING) then
		if pressing("left") then
			self.v.x = 10
		end
		if pressing("right") then
			self.v.x = -10
		end
	end
end

function Player:flip(reverse)
	if (reverse) then
		self.originX = self.width
		self.scaleX = -1
		self.carryingOffset = -self.width/1.5
	else
		self.originX = 0
		self.scaleX = 1
		self.carryingOffset = self.width/1.5

	end
end

function pressing(key)
	if key == "left" then
		return love.keyboard.isDown("left") or love.keyboard.isDown("a")
	end
	if key == "right" then
		return love.keyboard.isDown("right") or love.keyboard.isDown("d")
	end
	if key == "up" then
		return love.keyboard.isDown("up") or love.keyboard.isDown("w")
	end
end

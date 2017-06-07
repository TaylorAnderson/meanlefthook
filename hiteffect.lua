require("lovepunk.entity")
require("helpfuldog")
require("hitsmoke")
HitFx = Entity.new(0, 0, 10, 10)
HitFx.__index = HitFx

function HitFx.new(x, y)
	local self = setmetatable({}, HitFx)
	self.type = "hitfx"
	self.rotation = 0

	self.image = love.graphics.newImage("assets/img/hiteffect.png")
	self.x = x
	self.y = y
	self.ox = x
	self.oy = y

	local anim8 = require "libs.anim8"
	local grid = anim8.newGrid(24, 24, self.image:getWidth(), self.image:getHeight())
	self.lifetime = 0.2
	self.anim = anim8.newAnimation(grid('1-2', 1), self.lifetime/8, 'pauseAtEnd')


	self.timer= 0
	self.scale = 2


	return self
end
function HitFx:added()
	self.scene:add(HitSmoke.new(self.x, self.y, {x=1, y=1}))
	self.scene:add(HitSmoke.new(self.x, self.y, {x=-1, y=1}))
	self.scene:add(HitSmoke.new(self.x, self.y, {x=1, y=-1}))
	self.scene:add(HitSmoke.new(self.x, self.y, {x=-1, y=-1}))
	self.scene.tweener.to(self, self.lifetime, {scale = 0}):ease("expoin")
end
function HitFx:update(dt)
	self.anim:update(dt)

	self.timer = self.timer + dt
	local curWidth, curHeight = self.anim:getDimensions()
	self.x = self.ox-(curWidth*self.scale)/2
	self.y =  self.oy-(curHeight*self.scale)/2

	if (self.timer > self.lifetime) then self.scene:remove(self) end

end

function HitFx:draw()
	self.anim:draw(self.image, self.x, self.y, 0, self.scale, self.scale, self.originX, self.originY)
end

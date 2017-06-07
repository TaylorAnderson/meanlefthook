Scene = {} --defining ourselves
Scene.__index = Scene --so when we reference a nil key, we just return ourselves.

function Scene.new()
	local self = setmetatable({}, Scene)
	self.entities = {}
	self.loaded = false
	self.bump = require "libs.bump"
	self.camera = {x=0, y=0}
	self.bounds = {x=0, y=0, width=0, height=0}
	self.tweener = require "libs.flux"
	self.debug = false
	self.pauseTimer = 0
	return self

end
function Scene:load()
	self.loaded = true
	self.bumpWorld = self.bump.newWorld(1)
end
function Scene:update(dt)
	self.tweener.update(dt)
	self.pauseTimer = self.pauseTimer - dt
	if not self.loaded or self.pauseTimer > 0 then return end
	for _, e in pairs(self.entities) do
		e:update(dt)
		if (self.bumpWorld:hasItem(e)) then
			self.bumpWorld:update(e, e.x, e.y, e.width, e.height)
		end
	end
end
function Scene:keyPressed(k)
	if not self.loaded then return end
	if (k == "`") then self.debug = not self.debug end
	for _, v in pairs(self.entities) do
		v:keyPressed(k)
	end
end
function Scene:mousepressed(x, y, button)
	if not self.loaded then return end
	for _, v in pairs(self.entities) do
		v:mousepressed(x, y, button)
	end
end
function Scene:mousereleased(x, y, button)
	if not self.loaded then return end
	for _, v in pairs(self.entities) do
		v:mousereleased(x, y, button)
	end
end
function Scene:draw()
	if not self.loaded then return end
	table.sort(self.entities, layerSort)
	if self.debug then
		 love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 5, 5)
	end
	love.graphics.translate(self.camera.x, self.camera.y)
	for _, v in pairs(self.entities) do
		if (v.visible) then
			v:draw()
		end
		love.graphics.setColor(255, 255, 255)
		if (self.debug) then
			local x,y,w,h = self.bumpWorld:getRect(v)
			love.graphics.rectangle("line", x, y, w, h)
		end
	end


end
function Scene:add(entity)
	if not self.loaded then return end
	table.insert(self.entities, entity)
	entity.scene = self;
	self.bumpWorld:add(entity, entity.x, entity.y, entity.width, entity.height)
	self.bumpWorld:update(entity, entity.x, entity.y)
	entity:added()
end

function Scene:remove(entity)
	if not entity then return end
	for i, v in pairs(self.entities) do
		if (v == entity) then
			table.remove(self.entities, i)
		end
	end
	self.bumpWorld:remove(entity)
	entity.scene = nil
	entity:removed()
	entity = nil
end
function Scene:collide(e, type, x, y)
	local _,_, cols, len = self.bumpWorld:check(e, x, y, checkingFilter)
	for _, v in pairs(cols) do
		if (v.other.type == type) then return v.other end
	end
	return nil
end
function Scene:hasEntity(entity)
	for _, e in pairs(self.entities) do
		if e == entity then return true end
	end
	return false
end

function layerSort(e1, e2)
	return e1.layer > e2.layer
end
function checkingFilter()
	return "cross"
end

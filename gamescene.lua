require("lovepunk.scene")
require("player")
require("tile")
require("enemy")
require("reticule")
require("platform")
require("bomb")
require("helpfuldog")
require("fish")
require("slime")
require("spawner")
dofile("libs/LuaXML-master/xml.lua")
dofile("libs/LuaXML-master/handler.lua")

GameScene = Scene.new()
GameScene.__index = GameScene
local sti = require "libs.sti"

local halfWidth =(love.graphics.getWidth()/scale)/2
local halfHeight =(love.graphics.getHeight()/scale)/2
function GameScene.new()
	local self=setmetatable({}, GameScene)
	self.shakeIntensity = 0
	self.shakeTimer = 0

	self.oCameraX = 0
	self.oCameraY = 0

	self.shakeOffsetX = 0
	self.shakeOffsetY = 0
	return self
end
function GameScene:load()
	Scene.load(self)
	self:loadMap("assets/maps/level1.oel")
	
end
function GameScene:loadMap(path, x, y)
	local xmltext = ""
	local f, e = io.open(path, "r")

	if f then
		xmltext = f:read("*all")
	else error(e) end

	local xml = simpleTreeHandler()
	local xmlparser = xmlParser(xml)
	xmlparser:parse(xmltext)
	
	local level = xml.root.level
	self.bounds.height = level._attr.height*4;
	self.bounds.width = level._attr.width*4;
	local tiles = level.grid[1]
	local xPos, yPos = 0, 0
	for i = 1, #tiles do
		local c = tiles:sub(i,i)
		if c == "1" then
			self:add(Tile.new(xPos, yPos))
		end
		xPos = xPos + gs
		if c ~= "0" and c ~= "1" then
			xPos = 0
			yPos = yPos + gs
		end
	end

	if (level.entities ~= "") then
		for i, v in pairs(level.entities) do
			local ex = tonumber(v._attr.x)
			local ey = tonumber(v._attr.y)
			
			if i == "player" then
				self.player = Player.new(ex, ey)
				local reticule = Reticule.new(self.player);
				self.player.reticule = reticule;
				self:add(reticule);
				self:add(self.player)
			end
			if i == "slime" then self:add(Slime.new(ex, ey)) end
		end
	end
	f:close()
	return level._attr.width, level._attr.height
end
function GameScene:update(dt)
	Scene.update(self, dt)
	self.camera.x = -(self.player.x - halfWidth + (love.mouse.getX()/scale - halfWidth)/3) + self.shakeOffsetX;
	self.camera.y = -(self.player.y - halfHeight + (love.mouse.getY()/scale - halfHeight)/3) + self.shakeOffsetY;
	self.camera.x = clamp(-self.bounds.width, self.camera.x, 0);
	self.camera.y = clamp(-self.bounds.height, self.camera.y, 0)

	self.shakeTimer = self.shakeTimer - dt
	if (self.shakeTimer > 0) then
		self.shakeOffsetX = randomRange(-self.intensity, self.intensity)
		self.shakeOffsetY = randomRange(-self.intensity, self.intensity)
	else
		self.shakeOffsetX = 0
		self.shakeOffsetY = 0
	end
end
function GameScene:draw()
	Scene.draw(self)
end
function GameScene:shake(duration, intensity)
	self.intensity = intensity or 5
	self.duration = duration or 1
	self.shakeTimer = duration
end

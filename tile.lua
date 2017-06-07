require("lovepunk.entity")
Tile = Entity.new(0, 0, gs, gs)
Tile.__index = Tile


function Tile.new(x, y)
	local self = setmetatable({}, Tile)
	self.x = x
	self.y = y
	self.type = "level"
	self.image = love.graphics.newImage("assets/img/tile.png")
	self.layer = 11
	return self
end

function Tile:draw()
	love.graphics.draw(self.image, self.x, self.y, 0, self.scaleX, self.scaleY, self.originX, self.originY)
end

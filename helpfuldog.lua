require("table")
---
-- Clamps a value to a certain range.
-- @param min - The minimum value.
-- @param val - The value to clamp.
-- @param max - The maximum value.
function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end

function randomRange(minNum, maxNum)
	return (math.floor(math.random() * (maxNum - minNum + 1)) + minNum);
end


--Find vector from arg1 to arg2.  if revrse is true, it finds the vector pointing away from arg1.

function findVector(from, to, power, reverse)
	v = {x=to.x - from.x, y=to.y - from.y}
	v = normalize(v, power);
	if (reverse) then
		v.x = v.x * -1
		v.y = v.y * -1
	end
	return v;
end

function vectorToAngle(x, y)
	radians = math.atan2(y, x)
	return radians
end

function toRadians(degrees)
	r = degrees * (math.pi / 180);
	return r;
end

function toDegrees(radians)
	d = radians * (180/math.pi);
	return d;
end

function snapToGrid(num, gridsize, useFloor)
	if not useFloor then
		return math.floor(num / gridsize) * gridsize;
	else return math.floor(num / gridsize) * gridsize
	end
end

function angleToPoint(radians)
	return {x=math.cos(radians), y=math.sin(radians)};
end

function angleXY(object, angle, length, x, y)
	length = length or 1
	x = x or 0
	y = y or 0
	RAD = math.pi / -180;
	angle = angle * RAD;
	object.x = math.cos(angle) * length + x;
	object.y = math.sin(angle) * length + y;
end

function angleXYToPoint(object, angle, length, x, y)
	local length = length or 1
	local x = x or 0
	local y = y or 0
	RAD = math.pi / -180;
	angle = angle * RAD;
	p = {x=math.sin(angle) * length + x, y=math.cos(angle) * length + y}
	return p;
end

--returns true if val1 is close to val2, within the margin of error.
function isCloseTo(val1, val2, marginOfError)
	if (val1 < val2 + marginOfError and val1 > val2 - marginOfError) then return true end
	return false;
end

function isBetween(pointA, pointB, betweenPoint, error)
 	crossproduct = (betweenPoint.y - pointA.y) * (pointB.x - pointA.x) - (betweenPoint.x - pointA.x) * (pointB.y - pointA.y);
	if (math.abs(crossproduct) > error) then return false end;

 	dotproduct = (betweenPoint.x - pointA.x) * (pointB.x - pointA.x) + (betweenPoint.y - pointA.y) * (pointB.y - pointA.y);
	if (dotproduct < 0) then return false end

	squaredlengthba = (pointB.x - pointA.x) * (pointB.x - pointA.x) + (pointB.y - pointA.y) * (pointB.y - pointA.y);
	if (dotproduct > squaredlengthba) then return false end;

	return true;
end
function map(x, fromMin, fromMax, toMin, toMax)
	return toMin + ((x - fromMin) / (fromMax - fromMin)) * (toMax - toMin);
end
function normalize(vector, length)
	local length = length or 1
	local magnitude = math.sqrt((vector.x * vector.x) + (vector.y * vector.y))
	local normal = {x=vector.x / magnitude, y=vector.y / magnitude}
	normal.x = normal.x * length
	normal.y = normal.y * length
	return normal
end
function round(n)
    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
function distance(x1, y1, x2, y2)
	return math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
end

function lineStipple( x1, y1, x2, y2, dash, gap )
    local dash = dash or 10
    local gap  = dash + (gap or 10)

    local steep = math.abs(y2-y1) > math.abs(x2-x1)
    if steep then
        x1, y1 = y1, x1
        x2, y2 = y2, x2
    end
    if x1 > x2 then
        x1, x2 = x2, x1
        y1, y2 = y2, y1
    end

    local dx = x2 - x1
    local dy = math.abs( y2 - y1 )
    local err = dx / 2
    local ystep = (y1 < y2) and 1 or -1
    local y = y1
    local maxX = x2
    local pixelCount = 0
    local isDash = true
    local lastA, lastB, a, b

    for x = x1, maxX do
        pixelCount = pixelCount + 1
        if (isDash and pixelCount == dash) or (not isDash and pixelCount == gap) then
            pixelCount = 0
            isDash = not isDash
            a = steep and y or x
            b = steep and x or y
            if lastA then
                love.graphics.line( lastA, lastB, a, b )
                lastA = nil
                lastB = nil
            else
                lastA = a
                lastB = b
            end
        end

        err = err - dy
        if err < 0 then
            y = y + ystep
            err = err + dx
        end
    end
end
function sign(num)
	if (num > 0) then return 1
	elseif num < 0 then return -1
	else return 0
	end
end

function pixelLine(x1, y1, x2, y2)
	local dir= findVector({x=x1, y=y1}, {x=x2, y=y2}, 1)
	local xPos = x1
	local yPos = y1
	while (distance(xPos, yPos, x2, y2) > 1) do
		xPos = xPos + dir.x
		yPos = yPos + dir.y
		love.graphics.rectangle("fill", snapToGrid(xPos, 1), snapToGrid(yPos, 1), 2, 2);
	end
end
function dashedPixelLine(x1, y1, x2, y2, dash, gap)
	local dir= findVector({x=x1, y=y1}, {x=x2, y=y2}, 1)
	local xPos = x1
	local yPos = y1
	local count = 0
	while (distance(xPos, yPos, x2, y2) > 1) do
		count = count + 2

		xPos = xPos + dir.x
		yPos = yPos + dir.y

		if (count > gap) then
			love.graphics.rectangle("fill", snapToGrid(xPos, 1), snapToGrid(yPos, 1), 2, 2);
		end
		if (count > dash + gap) then count = 0 end
	end
end
function lerp(a, b, t)
	return a + (b - a) * t;
end

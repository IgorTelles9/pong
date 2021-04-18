Ball = Class{}

function Ball:init(x, y, width , height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height

	--these variable are for keeping tracking of our velocity on both the
	-- X and Y axis, since the ball can move in two dimensions
	self.dy = math.random(2) == 1 and -100 or 100
	self.dx = math.random(-50, 50)
end

--[[ 
	Places the ball in the middle of the screen, with an initial random
	velocity on both axes
--]]
function Ball:reset()
	self.x = VIRTUAL_WIDTH / 2 - 2
	self.y = VIRTUAL_HEIGHT / 2 - 2
	self.dx = math.random(2) == 1 and -100 or 100
	self.dy = math.random(-50, 50)
end

function Ball:colides(paddle)
	if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
		return false
	end

	if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
		return false
	end

	-- if the above aren't true, they're overlapping
	return true
end

--[[
	Simply applies velocity to position, scaled by deltaTime
]]
function Ball:update(dt)
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt
end

function Ball:render()
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
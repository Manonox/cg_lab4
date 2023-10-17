local Line = class("Line")
local transform = require("transform")


function Line:initialize(p1, p2)
    self.point1 = p1
    self.point2 = p2
end

function Line:draw()
    love.graphics.line(self.point1.x, self.point1.y, self.point2.x, self.point2.y)
end

function Line:apply(matrix)
    self.point1 = transform.apply(self.point1, matrix)
    self.point2 = transform.apply(self.point2, matrix)
end


local mgl = require("MGL")
function Line:closestPointToPoint(point)
    local a, b = self.point1, self.point2
    local v = point - a
    local dir = b - a
    local dirn = mgl.normalize(dir)
    local t = mgl.dot(v, dirn)
    t = math.clamp(t, 0, mgl.length(dir))
    return a + dirn * t
end

function Line:distanceToPoint(point)
    return mgl.length(self:closestPointToPoint(point) - point)
end

function Line:rotate90()
    local midpoint = (self.point1 + self.point2) / 2
    self:apply(transform.rotate(math.pi / 2, midpoint))
end

function Line:intersectLine(other)
    local x1, x2, x3, x4 = self.point1.x, self.point2.x, other.point1.x, other.point2.x
    local y1, y2, y3, y4 = self.point1.y, self.point2.y, other.point1.y, other.point2.y
    
    local denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
    local t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4))
    local u = ((x1 - x3) * (y1 - y2) - (y1 - y3) * (x1 - x2))
    t, u = t / denom, u / denom
    if t < 0 or t > 1 or u < 0 or u > 1 then return end
    return Vec2(x1 + t * (x2 - x1), y1 + t * (y2 - y1))
end


return Line

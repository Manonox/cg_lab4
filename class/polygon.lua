local Polygon = class("Polygon")
local Line = require("Line")
local transform = require("transform")
local mgl = require("MGL")


function Polygon:initialize(points)
    self.points = points
end


function Polygon:draw()
    local points = self.points
    local line = {}
    for _, point in ipairs(points) do
        line[#line + 1] = point.x
        line[#line + 1] = point.y
    end
    line[#line + 1] = points[1].x
    line[#line + 1] = points[1].y
    love.graphics.line(line)
end

function Polygon:apply(matrix)
    local points = self.points
    for i, point in ipairs(points) do
        points[i] = transform.apply(points[i], matrix)
    end
end

function Polygon:getEdges()
    local lines = {}
    local points = self.points
    for i, point in ipairs(points) do
        local i2 = 1 + i % #points
        lines[#lines + 1] = Line(point, points[i2])
    end
    return lines
end

function Polygon:isPointInside(point)
    local edges = self:getEdges()
    local rayStart = Vec2(-99999, point.y)
    local rayEnd = Vec2(point.x, point.y)
    local ray = Line(rayStart, rayEnd)
    local points = {}
    local count = 0
    for _, edge in ipairs(edges) do
        local point = ray:intersectLine(edge)
        if point then
            for _, other in ipairs(points) do
                if mgl.length(point - other) < 0.000001 then
                    local y = point.y
                    point = nil
                    
                    local y1, y2 = edge.point1.y, edge.point2.y
                    local d1, d2 = math.abs(y - y1), math.abs(y - y2)
                    print(d1, d2)
                    count = count + (d1 < d2 and 0 or 1)

                    break
                end
            end
        end

        if point then
            love.graphics.setColor(0, 0, 1)
            love.graphics.setLineWidth(2)
            love.graphics.circle("line", point.x, point.y, 4)
            points[#points + 1] = point
            count = count + 1
        end
    end
    return count % 2 == 1
end


return Polygon

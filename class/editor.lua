local Line = require("Line")
local Polygon = require("Polygon")
local transform = require("transform")

local Editor = class("Editor")
local mgl = require("MGL")
local tools = {}
Editor.static.tools = tools


-- Create Line

tools.line = {}

function tools.line:mousepressed(x, y, b)
    if b ~= 1 then return end
    local point1 = Vec2(x, y)
    if not self.editor:checkBounds(point1) then return end
    self.begin = point1
end

function tools.line:mousereleased(x, y, b)
    if b ~= 1 then return end
    if not self.begin then return end
    local point1 = self.begin
    self.begin = nil

    local point2 = Vec2(x, y)
    if not self.editor:checkBounds(point2) then return end
    if mgl.length(point2 - point1) < 10 then return end
    self.editor.lines[Line(point1, point2)] = true
end

function tools.line:draw()
    local p1 = self.begin
    if not p1 then return end
    local p2 = Vec2(love.mouse.getPosition())
    love.graphics.setLineStyle("smooth")
    love.graphics.setLineWidth(1)
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.line(p1.x, p1.y, p2.x, p2.y)
end


-- Create Poly

tools.poly = {}
function tools.poly:init()
    self.points = {}
end

function tools.poly:mousereleased(x, y, b)
    local point = Vec2(x, y)
    if not self.editor:checkBounds(point) then return end
    if b == 1 then
        self.points[#self.points + 1] = point
    elseif b == 2 and #self.points >= 3 then
        self.editor.polygons[Polygon(self.points)] = true
        self.points = {}
    end
end

function tools.poly:draw()
    local points = self.points
    love.graphics.setColor(0.5, 0.4, 0.2)
    for _, point in ipairs(points) do
        love.graphics.circle("line", point.x, point.y, 3)
    end

    if #points >= 3 then
        love.graphics.setLineStyle("smooth")
        love.graphics.setLineWidth(1)
        local line = {}
        for _, point in ipairs(points) do
            line[#line + 1] = point.x
            line[#line + 1] = point.y
        end
        line[#line + 1] = points[1].x
        line[#line + 1] = points[1].y
        love.graphics.line(line)
    end
end


-- Translate

tools.translate = {}
function tools.translate:mousepressed(x, y, b)
    if b ~= 1 then return end
    local point = Vec2(x, y)
    if not self.editor:checkBounds(point) then return end
    self.dragging = true
end

function tools.translate:mousereleased(x, y, b)
    if b ~= 1 then return end
    self.dragging = false
end

function tools.translate:mousemoved(x, y, dx, dy)
    if not self.dragging then return end
    local v = Vec2(dx, dy)
    local matrix = transform.translate(v)
    self.editor:apply(matrix)
end


-- Rotate

tools.rotate = {}
function tools.rotate:mousepressed(x, y, b)
    if b ~= 1 then return end
    local point = Vec2(x, y)
    if not self.editor:checkBounds(point) then return end
    self.dragging = point
end

function tools.rotate:mousereleased(x, y, b)
    if b ~= 1 then return end
    self.dragging = false
end

function tools.rotate:mousemoved(x, y, dx, dy)
    if not self.dragging then return end
    local ang = dx * math.pi / 180
    local pivot = self.dragging
    local matrix = transform.rotate(ang, pivot)
    self.editor:apply(matrix)
end

function tools.rotate:draw()
    if not self.dragging then return end
    local pivot = self.dragging
    love.graphics.setColor(0.3, 0.7, 1)
    love.graphics.circle("line", pivot.x, pivot.y, 3)
end


-- Scale

tools.scale = {}
function tools.scale:mousepressed(x, y, b)
    if b ~= 1 then return end
    local point = Vec2(x, y)
    if not self.editor:checkBounds(point) then return end
    self.dragging = point
end

function tools.scale:mousereleased(x, y, b)
    if b ~= 1 then return end
    self.dragging = false
end

function tools.scale:mousemoved(x, y, dx, dy)
    if not self.dragging then return end
    local pivot = self.dragging
    local d = Vec2(dx, dy)
    local v = Vec2(1, 1) + d * 0.01
    local matrix = transform.scale(v, pivot)
    self.editor:apply(matrix)
end

function tools.scale:draw()
    if not self.dragging then return end
    local pivot = self.dragging
    love.graphics.setColor(0.8, 0.5, 1)
    love.graphics.circle("line", pivot.x, pivot.y, 3)
end


-- Rotate Line 90deg

tools.linerotate = {}
function tools.linerotate:closestPoint(point)
    local line = self:closestLine(point)
    return line and line:closestPointToPoint(point)
end

function tools.linerotate:closestLine(point)
    local mindist, minline
    for line in pairs(self.editor.lines) do
        local dist = line:distanceToPoint(point)
        if not mindist or dist < mindist then
            minline = line
            mindist = dist
        end
    end
    return minline
end

function tools.linerotate:draw()
    local point = self:closestPoint(Vec2(love.mouse.getPosition()))
    if point then
        love.graphics.setColor(0.5, 1, 0.5)
        love.graphics.circle("line", point.x, point.y, 3)
    end
end

function tools.linerotate:mousepressed(x, y, b)
    if b ~= 1 then return end
    local point = Vec2(x, y)
    if not self.editor:checkBounds(point) then return end
    
    local line = self:closestLine(point)
    if line then
        line:rotate90()
    end
end


-- Line Intersections

tools.linesect = {}

function tools.linesect:mousepressed(x, y, b)
    if b ~= 1 then return end
    local point1 = Vec2(x, y)
    if not self.editor:checkBounds(point1) then return end
    self.dragging = point1
end

function tools.linesect:mousereleased(x, y, b)
    if b ~= 1 then return end
    self.dragging = nil
end

function tools.linesect:draw()
    if not self.dragging then return end
    local point1 = self.dragging
    local point2 = Vec2(love.mouse.getPosition())
    local intersecting = Line(point1, point2)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineStyle("smooth")
    love.graphics.setLineWidth(1)
    love.graphics.line(point1.x, point1.y, point2.x, point2.y)
    
    love.graphics.setColor(0, 1, 0)
    for line in pairs(self.editor.lines) do
        local point = line:intersectLine(intersecting)
        if point then
            love.graphics.circle("fill", point.x, point.y, 4)
        end
    end
end



-- Poly Contains Point Test


tools.polysect = {}
function tools.polysect:draw()
    local point = Vec2(love.mouse.getPosition())

    for polygon in pairs(self.editor.polygons) do
        local isInside = polygon:isPointInside(point)
        local green = isInside and 1 or 0
        love.graphics.setColor(1 - green, green, 0)
        
        love.graphics.setLineWidth(3)
        polygon:draw()
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", point.x, point.y, 3)
end



function Editor:initialize()
    self.position = Vec2(128, 0)
    self.size = Vec2(512, 512)

    love.draw:add(bind(self.draw, self))
    love.mousepressed:add(bind(self.mousepressed, self))
    love.mousereleased:add(bind(self.mousereleased, self))
    love.mousemoved:add(bind(self.mousemoved, self))

    -- self.points = {}
    self.lines = {}
    self.polygons = {}
    
    self.actions = {}
    self:addAction("Clear", function()
        self.lines = {}
        self.polygons = {}
    end)
    self:addTool("line", "Create Line")
    self:addTool("poly", "Create Poly")
    self:addTool("translate", "Translate")
    self:addTool("rotate", "Rotate")
    self:addTool("scale", "Scale")
    self:addTool("linerotate", "Rotate Line 90deg")
    self:addTool("linesect", "Line Intersections")
    self:addTool("polysect", "Poly Contains Point")
    self.current_tool = "line"
end


function Editor:addAction(name, func)
    self.actions[#self.actions + 1] = { name = name, func = func, }
end


function Editor:addTool(key, name)
    self.current_tool = key
    self:callTool("init")
    self:addAction(name, function()
        self.current_tool = key
        print("Tool: " .. key)
    end)
end


function Editor:callTool(method, ...)
    local tool = self.class.tools[self.current_tool]
    local func = tool[method]
    if func then
        tool.editor = self
        func(tool, ...)
        tool.editor = nil
    end
end


function Editor:apply(matrix)
    for line in pairs(self.lines) do
        line:apply(matrix)
    end

    for polygon in pairs(self.polygons) do
        polygon:apply(matrix)
    end
end


function Editor:draw()
    love.graphics.setColor(0.03, 0.03, 0.03)
    local x, y = unpack(self.position)
    local w, h = unpack(self.position + self.size)
    love.graphics.rectangle("fill", x, y, w, h)

    love.graphics.setLineStyle("smooth")
    love.graphics.setLineWidth(2)
    love.graphics.setColor(0.6, 0.8, 1)
    self:drawLines()

    love.graphics.setLineStyle("smooth")
    love.graphics.setLineWidth(2)
    love.graphics.setColor(1, 0.8, 0.6)
    self:drawPolygons()

    self:callTool("draw")
end


function Editor:drawLines()
    for line in pairs(self.lines) do
        line:draw()
    end
end


function Editor:drawPolygons()
    for polygon in pairs(self.polygons) do
        polygon:draw()
    end
end


function Editor:checkBounds(v)
    local s = self.position
    local e = self.position + self.size
    return v.x >= s.x and v.x <= e.x and v.y >= s.y and v.y <= e.y
end


function Editor:mousepressed(x, y, b)
    self:callTool("mousepressed", x, y, b)
end

function Editor:mousereleased(x, y, b)
    self:callTool("mousereleased", x, y, b)
end

function Editor:mousemoved(x, y, dx, dy)
    self:callTool("mousemoved", x, y, dx, dy)
end



return Editor

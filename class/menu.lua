local Menu = class("Menu")
Menu.static.optionHeight = 32


function Menu:initialize(options)
    self.position = Vec2(0, 0)
    self.size = Vec2(128, 512)
    self.options = options
    love.draw:add(bind(self.draw, self))
    love.mousepressed:add(bind(self.click, self))
end


local function drawOption(self, option, y)
    local x = self.position.x
    local w, h = self.size.x, self.class.optionHeight

    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", x, y, w, h)
    
    local mx, my = love.mouse.getPosition()
    local b = 0.2
    if mx > x and mx < x + w and my > y and my < y + h then
        b = love.mouse.isDown(1) and 0.15 or 0.3
    end

    love.graphics.setColor(b, b, b)
    love.graphics.rectangle("fill", x + 2, y + 2, w - 4, h - 4)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(option.name, x, y + 8, self.size.x, "center")
end


function Menu:draw()
    love.graphics.setColor(0.05, 0.05, 0.05)
    love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x, self.size.y)

    for i, option in ipairs(self.options) do
        drawOption(self, option, (i - 1) * self.class.optionHeight)
    end
end


function Menu:click(mx, my, b)
    local x = self.position.x
    local w = self.size.x
    if not (mx > x and mx < x + w) then return end
    local i = math.floor(my / self.class.optionHeight) + 1
    local option = self.options[i]
    if not option then return end
    if not option.func then return end
    option.func()
end

return Menu

--file: button.lua
--Clicky buttons

Button = Object:extend()
require "lib.extraFunc"

function Button:new(x,y,width,height,text,action)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.text = text
    self.action = action
    self.hover = false
end

function Button:update(dt)
    if love.mouse.getX() > self.x and love.mouse.getX() < self.x + self.width and love.mouse.getY() > self.y and love.mouse.getY() < self.y + self.height then
        self.hover = true
        if love.mouse.isDown(1) then
            self:click()
        end
    else
        self.hover = false
    end
end

function Button:draw()
    if self.hover then
        love.graphics.setColor(1,1,1,0.75)
    else
        love.graphics.setColor(1,1,1,0.5)
    end
    love.graphics.rectangle("fill",self.x,self.y,self.width,self.height)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line",self.x,self.y,self.width,self.height)
    love.graphics.setColor(0,0,0)
    simpleText(self.text,22,self.x + self.width/2,self.y + self.height/2,'center')
end

function Button:click()
    if self.hover then
        self.action()
    end
end
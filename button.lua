--file: button.lua
--Clicky buttons & menu functions

Button = Object:extend()
require "lib.extraFunc"

function PauseGame()
    if State ~= 'pause' then 
        DebugInfo = false
        Buttons = {}
        State = 'pause'
        Buttons['resume'] = Button(10,50,200,50,"Resume",ResumeGame,0)
        Buttons['options'] = Button(10,120,200,50,"Options",OptionsMenu,0.1)
        Buttons['quit'] = Button(10,190,200,50,"Quit",SureQuit,0.2)
    end
end

function ResumeGame()
    if State == 'pause' then
        Buttons = {}
        State = 'game'

    end
end

function SureQuit()
    if State == 'pause' then
        Buttons = {}
        State = 'surequit'
        Buttons['back'] = Button(10, 50, 200, 50, "Back", PauseGame, 0)
        Buttons['quit'] = Button(10, 120, 200, 50, "Quit", love.event.quit, 0.1)
    end
end

function OptionsMenu()
    if State == 'pause' then 
        Buttons = {}
        State = 'options' 
        Buttons['fullscreen'] = Button(10, 50, 300, 50, function() local x = 'Off' if love.window.getFullscreen() then x = 'On' end return "Fullscreen: "..x end, function() love.window.setFullscreen(not love.window.getFullscreen()) end, 0)
        Buttons['vsync'] = Button(10, 120, 300, 50, function() local x = 'Off' if love.window.getVSync()==1 then x = 'On' end return "Vsync: "..x end, function() love.window.setVSync(1 - love.window.getVSync()) end, 0.05)
        Buttons['renderer'] = Button(10, 190, 300, 50, function() local x = 'Screen' if NewRenderer then x = 'Update' end return "Renderer: "..x end, function() NewRenderer = not NewRenderer end, 0.1)
        Buttons['graphics'] = Button(10, 260, 300, 50, function() local x = 'Fast' if HighGraphics then x = 'Fancy' end return "Graphics: "..x end, function() HighGraphics = not HighGraphics end, 0.15)
        Buttons['creative'] = Button(10, 330, 300, 50, function() local x = 'Off' if CreativeMode then x = 'On' end return "Creative: "..x end, function() CreativeMode = not CreativeMode end, 0.2)
        Buttons['back'] = Button(10, 400, 300, 50, "Back", PauseGame, 0.25)
    end
end

function GraphicsMenu()
    if State == 'options' then
        Buttons = {}
        State = 'graphicsmenu'
    end
end


function Button:new(x, y, width, height, text, action, delay)
    self.xT = x*GameScale
    self.yT = y*GameScale
    self.widthT = width*GameScale
    self.heightT = height*GameScale
    self.text = text
    self.action = action
    self.hover = false
    self.xpos = -5000
    self.ypos = 0
    self.width = width*GameScale
    self.height = height*GameScale

    self.timeAlive = -delay or 0
end

function Button:update(dt)
    self.timeAlive = self.timeAlive + dt

    --slide in from left
    local slideInDistance = 42 * self.width * GameScale
    if self.timeAlive < 0.3 then
        self.xpos = self.xT - slideInDistance * (0.3 - math.max(0,self.timeAlive))^3 -- slide in effect
    else
        self.xpos = self.xT
    end

    self.ypos = self.yT * GameScale
    self.width = self.widthT * GameScale
    self.height = self.heightT * GameScale
    if love.mouse.getX() > self.xpos and love.mouse.getX() < self.xpos + self.width and love.mouse.getY() > self.ypos and love.mouse.getY() < self.ypos + self.height then
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

    love.graphics.rectangle("fill",self.xpos,self.ypos,self.width,self.height,10,10)
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("line",self.xpos,self.ypos,self.width,self.height,10,10)
    if type(self.text) == 'string' then
        simpleText(self.text,22,self.xpos + self.width/2,self.ypos + self.height/2,'center')
    else
        simpleText(self.text(),22,self.xpos + self.width/2,self.ypos + self.height/2,'center')
    end
    love.graphics.setColor(1,1,1,1)
end

function Button:click()
    if self.hover and not DebugPressed then
        DebugPressed = true
        self.action()
    end
end




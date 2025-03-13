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
        Buttons['options'] = Button(10,120,200,50,"Options",OptionsMenu,0.15)
        Buttons['quit'] = Button(10,190,200,50,"Quit",SureQuit,0.3)
    end
end

function ResumeGame()
    if State == 'pause' then
        Buttons = {}
        State = 'resuming'
        ResumeTimer = SecondsCounter + 0.25

    end
end

function SureQuit()
    if State == 'pause' then
        Buttons = {}
        State = 'surequit'
        Buttons['back'] = Button(10, 50, 200, 50, "Back", PauseGame, 0)
        Buttons['quit'] = Button(10, 120, 200, 50, "Quit", love.event.quit, 0.2)
    end
end

function OptionsMenu()
    if State == 'pause' then 
        Buttons = {}
        State = 'options' 
        Buttons['fullscreen'] = Button(10, 50, 300, 50, function() local x = 'Off' if love.window.getFullscreen() then x = 'On' end return "Fullscreen: "..x end, function() love.window.setFullscreen(not love.window.getFullscreen()) end, 0)
        Buttons['vsync'] = Button(10, 120, 300, 50, function() local x = 'Off' if love.window.getVSync()==1 then x = 'On' end return "Vsync: "..x end, function() love.window.setVSync(1 - love.window.getVSync()) end, 0.1)
        Buttons['renderer'] = Button(10, 190, 300, 50, function() local x = 'Screen' if NewRenderer then x = 'Update' end return "Renderer: "..x end, function() NewRenderer = not NewRenderer end, 0.2)
        Buttons['graphics'] = Button(10, 260, 300, 50, function() local x = 'Fast' if HighGraphics then x = 'Fancy' end return "Graphics: "..x end, function() HighGraphics = not HighGraphics end, 0.3)
        Buttons['creative'] = Button(10, 330, 300, 50, function() local x = 'Off' if CreativeMode then x = 'On' end return "Creative: "..x end, function() CreativeMode = not CreativeMode end, 0.4)
        Buttons['back'] = Button(10, 400, 300, 50, "Back", PauseGame, 0.5)

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
    self.x = 0
    self.y = 0
    self.width = 0
    self.height = 0

    self.timeAlive = -delay or 0
end

function Button:update(dt)
    self.timeAlive = self.timeAlive + dt
    self.x = self.xT * GameScale

    --slide in from left
    
    local slideInDistance = 16 * self.width * GameScale
    if self.timeAlive < 0.5 then
        self.x = self.x - slideInDistance * (0.5 - math.max(0,self.timeAlive))^3 -- slide in effect
    end

    self.y = self.yT * GameScale
    self.width = self.widthT * GameScale
    self.height = self.heightT * GameScale
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

    love.graphics.rectangle("fill",self.x,self.y,self.width,self.height,10,10)
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("line",self.x,self.y,self.width,self.height,10,10)
    if type(self.text) == 'string' then
        simpleText(self.text,22,self.x + self.width/2,self.y + self.height/2,'center')
    else
        simpleText(self.text(),22,self.x + self.width/2,self.y + self.height/2,'center')
    end
    love.graphics.setColor(1,1,1,1)
end

function Button:click()
    if self.hover and not DebugPressed then
        DebugPressed = true
        self.action()
    end
end




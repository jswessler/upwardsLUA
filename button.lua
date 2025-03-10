--file: button.lua
--Clicky buttons & menu functions

Button = Object:extend()
require "lib.extraFunc"

function PauseGame()
    if State ~= 'pause' then 
        Buttons = {}
        State = 'pause'
        Buttons['resume'] = Button(20*GameScale,50*GameScale,200*GameScale,50*GameScale,"Resume",ResumeGame)
        Buttons['options'] = Button(20*GameScale,120*GameScale,200*GameScale,50*GameScale,"Options",OptionsMenu)
        Buttons['quit'] = Button(20*GameScale,190*GameScale,200*GameScale,50*GameScale,"Quit",love.event.quit)
    end
end

function ResumeGame()
    if State == 'pause' then 
        Buttons = {}
        State = 'resuming' 
        ResumeTimer = SecondsCounter+0.25

    end
end

function OptionsMenu()
    if State == 'pause' then 
        Buttons = {}
        State = 'options' 
        Buttons['back'] = Button(20*GameScale,190*GameScale,200*GameScale,50*GameScale,"Back",PauseGame)
        Buttons['vsync'] = Button(20*GameScale,120*GameScale,200*GameScale,50*GameScale, function() return "Vsync: "..love.window.getVSync() end, function() love.window.setVSync(1-love.window.getVSync()) end)
        Buttons['fullscreen'] = Button(20*GameScale,50*GameScale,200*GameScale,50*GameScale,function() return "Fullscreen: "..tostring(love.window.getFullscreen()) end, function() love.window.setFullscreen(not love.window.getFullscreen()) end)
    end
end


function Button:new(x,y,width,height,text,action)
    self.xT = x
    self.yT = y
    self.widthT = width
    self.heightT = height
    self.text = text
    self.action = action
    self.hover = false
    self.x = 0
    self.y = 0
    self.width = 0
    self.height = 0
end

function Button:update(dt)
    self.x = self.xT * GameScale
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




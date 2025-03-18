--file: button.lua
--Clicky buttons & menu functions

Button = Object:extend()
require "lib.extraFunc"
require "startup"

function PauseGame()
    DebugInfo = false
    Buttons = {}
    State = 'pause'
    Buttons['resume'] = Button(10,50,200,50,"Resume",ResumeGame,0)
    Buttons['options'] = Button(10,120,200,50,"Options",OptionsMenu,0.1)
    Buttons['quit'] = Button(10,190,200,50,"Quit",SureQuit,0.2)
end

function ResumeGame()
    Buttons = {}
    State = 'game'
end

function SureQuit()
    Buttons = {}
    State = 'surequit'
    Buttons['Back'] = Button(10, 50, 200, 50, "Back", PauseGame, 0)
    Buttons['Title'] = Button(10, 120, 200, 50, "To Title", function() State = 'menu' MenuMenu() end, 0)
    Buttons['Quit'] = Button(10, 190, 200, 50, "Exit Game", love.event.quit, 0)
end

function OptionsMenu()
    Buttons = {}
    State = 'options' 
    Buttons['graphics'] = Button(10, 50, 300, 50, "Graphics", GraphicsMenu, 0)
    Buttons['controls'] = Button(10, 120, 300, 50, "Controls", ControlsMenu, 0.05)
    Buttons['audio'] = Button(10, 190, 300, 50, "Audio", AudioMenu, 0.1)
    Buttons['creative'] = Button(10, 260, 300, 50, function() local x = 'Off' if CreativeMode then x = 'On' end return "Creative: "..x end, function() CreativeMode = not CreativeMode end, 0.15)
    Buttons['back'] = Button(10, 330, 300, 50, "Back", PauseGame, 0.2)
end

function GraphicsMenu()
    Buttons = {}
    State = 'graphicsmenu'
    Buttons['fullscreen'] = Button(10, 50, 300, 50, function() local x = 'Off' if love.window.getFullscreen() then x = 'On' end return "Fullscreen: "..x end, function() love.window.setFullscreen(not love.window.getFullscreen()) end, 0)
    Buttons['vsync'] = Button(10, 120, 300, 50, function() local x = 'Off' if love.window.getVSync()==1 then x = 'On' end return "Vsync: "..x end, function() love.window.setVSync(1 - love.window.getVSync()) end, 0.05)
    Buttons['renderer'] = Button(10, 190, 300, 50, function() local x = 'Screen' if NewRenderer then x = 'Canvas' end return "Renderer: "..x end, function() NewRenderer = not NewRenderer end, 0.1)
    Buttons['graphics'] = Button(10, 260, 300, 50, function() local x = 'Fast' if HighGraphics then x = 'Fancy' end return "Graphics: "..x end, function() HighGraphics = not HighGraphics end, 0.15)
    Buttons['fps'] = Button(10, 330, 300, 50, function() local x = '60' if FpsLimit ~= 71 then x = 'Unlimited'end return "FPS: "..x end, function() if FpsLimit == 71 then FpsLimit = 0 else FpsLimit = 71 end end, 0.2)
    Buttons['back'] = Button(10, 400, 300, 50, "Back", OptionsMenu, 0.25)
end

function ControlsMenu()
    Buttons = {}
    State = 'controlsmenu'
    Buttons['Jump'] = Button(10*GameScale, 50, 200, 40, function() return "Jump: "..KeyBinds['Jump'] end, function() State = 'Jump-CS' end, 0, "Jump")
    Buttons['Right'] = Button(10*GameScale, 100, 200, 40, function() return "Right: "..KeyBinds['Right'] end, function() State = 'Right-CS' end, 0.025, "Right")
    Buttons['Left'] = Button(10*GameScale, 150, 200, 40, function() return "Left: "..KeyBinds['Left'] end, function() State = 'Left-CS' end, 0.05, "Left")
    Buttons['Up'] = Button(10*GameScale, 200, 200, 40, function() return "Up: "..KeyBinds['Up'] end, function() State = 'Up-CS' end, 0.075, "Up")
    Buttons['Slide'] = Button(10*GameScale, 250, 200, 40, function() return "Slide: "..KeyBinds['Slide'] end, function() State = 'Slide-CS' end, 0.1, "Slide")
    Buttons['Dive'] = Button(250*GameScale, 50, 200, 40, function() return "Dive: "..KeyBinds['Dive'] end, function() State = 'Dive-CS' end, 0.125, "Dive")
    Buttons['Pause'] = Button(250*GameScale, 100, 200, 40, function() return "Pause: "..KeyBinds['Pause'] end, function() State = 'Pause-CS' end, 0.15, "Pause")
    Buttons['Call'] = Button(250*GameScale, 150, 200, 40, function() return "Take Call: "..KeyBinds['Call'] end, function() State = 'Call-CS' end, 0.175, "Call")
    Buttons['Throw'] = Button(250*GameScale, 200, 200, 40, function() return "Throw Kunai: "..KeyBinds['Throw'] end, function() State = 'Throw-CS' end, 0.2, "Throw")
    Buttons['Skip'] = Button(250*GameScale, 250, 200, 40, function() return "Next Text: "..KeyBinds['Skip'] end, function() State = 'Skip-CS' end, 0.225, "Skip")
    Buttons['Fast'] = Button(10*GameScale, 300, 200, 40, function() return "Skip Text: "..KeyBinds['Fast'] end, function() State = 'Fast-CS' end, 0.25, "Fast")



    Buttons['back'] = Button(10, 350, 200, 40, 'Back', OptionsMenu, 0.3)
end

function AudioMenu()
end

function MenuMenu()
    FrameCounter = 0
    Buttons = {}
    State = 'menu'
    Buttons['Play'] = Button(80, WindowHeight-220, 400, 100, "Play", function() LoadLevel('lvl1') end, 0)
    Buttons['Quit'] = Button(80, WindowHeight-100, 400, 50, "Quit", love.event.quit, 0)
end


function Button:new(x, y, width, height, text, action, delay, id)
    self.id = id or nil
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
    local slideInDistance = (42 + (self.xT-10)) * self.width * GameScale
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
    --Shadow
    love.graphics.setColor(0.25,0.25,0.25,0.5)

    --Increase opacity when hovering over
    if self.hover then
        love.graphics.rectangle('fill',self.xpos-4,self.ypos+12,self.width,self.height,12,12)
        love.graphics.setColor(1,1,1,0.75)
    else
        love.graphics.rectangle('fill',self.xpos-2,self.ypos+6,self.width,self.height,12,12)
        love.graphics.setColor(1,1,1,0.5)
    end
    
    --Override for controls menu buttons
    if self.id == split(State,'-')[1] then
        love.graphics.setColor(1,0,0,0.75)
    end
    love.graphics.rectangle("fill",self.xpos,self.ypos,self.width,self.height,10,10)

    --Outline
    love.graphics.setColor(0,0,0,1)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line",self.xpos,self.ypos,self.width,self.height,10,10)
    love.graphics.setLineWidth(1)

    --Text
    if type(self.text) == 'string' then
        simpleText(self.text,22,self.xpos + self.width/2,self.ypos + self.height/2+2,'center')
    else
        simpleText(self.text(),22,self.xpos + self.width/2,self.ypos + self.height/2+2,'center')
    end

    love.graphics.setColor(1,1,1,1)
end

function Button:click()
    if self.hover and not DebugPressed then
        DebugPressed = true
        self.action()
    end
end




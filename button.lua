--file: button.lua
--Clicky buttons & menu functions

Button = Object:extend()
require "lib.extraFunc"
require "startup"

function PauseGame()
    DebugInfo = 0
    Buttons = {}
    MouseWheelY = 0 --Reset zoom
    ZoomScroll = 0
    StateVar.state = 'menu'
    StateVar.substate = 'none'
    StateVar.physics = 'display'
    Buttons['Resume'] = Button(10,50,200,50,"Resume",ResumeGame,0)
    Buttons['Options'] = Button(10,120,200,50,"Options",OptionsMenu,0.1)
    Buttons['Quit'] = Button(10,190,200,50,"Quit",SureQuit,0.2)
end

function ResumeGame()
    Buttons = {}
    StateVar.genstate = 'game'
    StateVar.state = 'play'
    StateVar.physics = 'on'
end

function SureQuit()
    Buttons = {}
    StateVar.substate = 'surequit'
    Buttons['Back'] = Button(10, 50, 200, 50, "Back", PauseGame, 0)
    Buttons['Title'] = Button(10, 120, 200, 50, "To Title", function() StateVar.genstate = 'title' GlAni = 0.5 StateVar.ani = 'totitle' end, 0.1)
    Buttons['Quit'] = Button(10, 190, 200, 50, "Exit Game", function() GlAni = 0.5 StateVar.ani = 'quitting' end, 0.2)
end

function OptionsMenu()
    Buttons = {}
    StateVar.substate = 'options'
    StateVar.physics = 'display'
    Buttons['Graphics'] = Button(10, 50, 300, 50, "Graphics", GraphicsMenu, 0)
    Buttons['Performance'] = Button(10, 120, 300, 50, "Performance", PerformanceMenu, 0.05)
    Buttons['Controls'] = Button(10, 190, 300, 50, "Controls", ControlsMenu, 0.1)
    Buttons['Audio'] = Button(10, 260, 300, 50, "Audio", AudioMenu, 0.15)
    Buttons['CMode'] = Button(10, 330, 300, 50, function() local x = 'Off' if CreativeMode then x = 'On' end return "Creative: "..x end, function() CreativeMode = not CreativeMode end, 0.2)
    Buttons['Back'] = Button(10, 400, 200, 50, "Back", function() if StateVar.genstate == 'game' then PauseGame() else TitleScreen(false) end end, 0.25)
end

function GraphicsMenu()
    Buttons = {}
    StateVar.substate = 'graphics'
    Buttons['Fullscreen'] = Button(10, 50, 300, 50, function() local x = 'Off' if love.window.getFullscreen() then x = 'On' end return "Fullscreen: "..x end, function() love.window.setFullscreen(not love.window.getFullscreen()) end, 0)
    Buttons['VSync'] = Button(10, 120, 300, 50, function() local x = 'Adaptive' if love.window.getVSync()==1 then x = 'Single' end return "Vsync: "..x end, function() love.window.setVSync(0 - love.window.getVSync()) end, 0.05)
    Buttons['Renderer'] = Button(10, 190, 300, 50, function() local x = 'Screen' if NewRenderer then x = 'Canvas' end return "Renderer: "..x end, function() NewRenderer = not NewRenderer end, 0.1)
    Buttons['GrQuality'] = Button(10, 260, 300, 50, function() local x = 'Fast' if HighGraphics then x = 'Fancy' end return "Graphics: "..x end, function() HighGraphics = not HighGraphics end, 0.15)
    Buttons['Back'] = Button(10, 330, 200, 50, "Back", OptionsMenu, 0.3)
end

function PerformanceMenu()
    Buttons = {}
    StateVar.substate = 'performance'
    Buttons['StepSize'] = Button(10, 50, 350, 50, function() return "Step Size: "..StepSize end,nil,0,nil,function(x) StepSize = x end,2,16,function() StepSize = 4 end)
    Buttons['FPS'] = Button(10, 120, 350, 50, function() if FpsLimit == 0 then return "Max FPS: Unlimited" else return "Max FPS: "..FpsLimit end end,nil,0.1,nil,function(x) FpsLimit = x end,30,144,function() FpsLimit = 0 end)
    Buttons['Back'] = Button(10, 190, 200, 50, "Back", OptionsMenu, 0.2)
end

function ControlsMenu()
    Buttons = {}
    StateVar.substate = 'controls'
    Buttons['Jump'] = Button(10*GameScale, 50, 200, 40, function() return "Jump: "..KeyBinds['Jump'] end, function() StateVar.substate = 'Jump-CS' end, 0.25, "Jump")
    Buttons['Right'] = Button(10*GameScale, 100, 200, 40, function() return "Right: "..KeyBinds['Right'] end, function() StateVar.substate = 'Right-CS' end, 0.275, "Right")
    Buttons['Left'] = Button(10*GameScale, 150, 200, 40, function() return "Left: "..KeyBinds['Left'] end, function() StateVar.substate = 'Left-CS' end, 0.3, "Left")
    Buttons['Up'] = Button(10*GameScale, 200, 200, 40, function() return "Up: "..KeyBinds['Up'] end, function() StateVar.substate = 'Up-CS' end, 0.325, "Up")
    Buttons['Slide'] = Button(10*GameScale, 250, 200, 40, function() return "Slide: "..KeyBinds['Slide'] end, function() StateVar.substate = 'Slide-CS' end, 0.35, "Slide")
    Buttons['Dive'] = Button(250*GameScale, 50, 200, 40, function() return "Dive: "..KeyBinds['Dive'] end, function() StateVar.substate = 'Dive-CS' end, 0, "Dive")
    Buttons['Pause'] = Button(250*GameScale, 100, 200, 40, function() return "Pause: "..KeyBinds['Pause'] end, function() StateVar.substate = 'Pause-CS' end, 0.025, "Pause")
    Buttons['Spin'] = Button(250*GameScale, 150, 200, 40, function() return "Spin: "..KeyBinds['Spin'] end, function() StateVar.substate = 'Spin-CS' end, 0.05, "Spin")
    Buttons['Throw'] = Button(250*GameScale, 200, 200, 40, function() return "Kunai: "..KeyBinds['Throw'] end, function() StateVar.substate = 'Throw-CS' end, 0.075, "Throw")
    Buttons['Skip'] = Button(250*GameScale, 250, 200, 40, function() return "Next Text: "..KeyBinds['Skip'] end, function() StateVar.substate = 'Skip-CS' end, 0.1, "Skip")
    Buttons['Fast'] = Button(10*GameScale, 300, 200, 40, function() return "Skip Text: "..KeyBinds['Fast'] end, function() StateVar.substate = 'Fast-CS' end, 0.375, "Fast")

    Buttons['Back'] = Button(10, 350, 200, 50, 'Back', OptionsMenu, 0.3)
end

function AudioMenu()
    Buttons = {}
    StateVar.substate = 'audio'
    Buttons['Back'] = Button(10, 50, 300, 50, "Back (not implemented)", OptionsMenu, 0)
end

--Main menu
function TitleScreen(reset)
    if reset then
        love.graphics.setDefaultFilter("linear","linear",4)
        FrameCounter = 0
    end
    Buttons = {}
    StateVar.genstate = 'title'
    StateVar.physics = 'off'
    Buttons['New Game'] = Button(30, 570, 240, 130, "New Game", function() StateVar.ani = 'levelloadtrans' GlAni = 0.6 end, 0)
    Buttons['Continue'] = Button(290, 570, 240, 130, "Continue", function() StateVar.ani = 'levelloadtrans' GlAni = 0.6 end, 0) --TODO: Save screen
    Buttons['Options'] = Button(60, 720, 180, 50, "Options", OptionsMenu, 0)
    Buttons['Quit'] = Button(320, 720, 180, 50, "Quit", function() GlAni = 0.5 StateVar.ani = 'quitting' end, 0)
end


function Button:new(x, y, width, height, text, action, delay, id, slider, sMin, sMax,rcAction)
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
    self.slider = slider or nil
    self.sliderMin = sMin or nil
    self.sliderMax = sMax or nil
    self.timeAlive = -delay or 0
    self.rcAction = rcAction or nil
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
        if love.mouse.isDown(2) then
            self:rclick()
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
    if self.id == split(StateVar.substate,'-')[1] then
        love.graphics.setColor(1,0,0,0.75)
    end

    --Override for using slider buttons
    if love.mouse.isDown(1) and self.hover and self.slider ~= nil then
        love.graphics.setColor(1,0,0,0.75)
    end
    love.graphics.rectangle("fill",self.xpos,self.ypos,self.width,self.height,10,10)
    
    if self.slider ~= nil then
        --Draw line
        love.graphics.rectangle('fill',self.xpos+5,self.ypos+self.height-10,self.width-10,2)
    end
    
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
    if self.slider ~= nil then
        local x = (love.mouse.getX() - self.xpos) / self.width
        local y = round(x * (self.sliderMax - self.sliderMin) + self.sliderMin)
        self.slider(y)
    elseif self.hover and not DebugPressed then
        DebugPressed = true
        self.action()
    end
end

function Button:rclick()
    if self.rcAction ~= nil and self.hover and not DebugPressed then
        DebugPressed = true
        self.rcAction()
    end
end




--!file: main.lua
--Upwards!

--[[
for l.1:
- Phone stays above your head on different scales


]]

if arg[2] == "debug" then
    require("lldebugger").start()
end

function love.load()

    
    --Build Id
    BuildId = "l.2"

    --Imports
    Object = require "lib.classic"
    require "lib.loadArl"
    require "lib.extraFunc"
    
    require "shader.gaussianblur"

    require "player"
    require "sensor"
    require "camera"
    require "kunai"
    require "button"
    require "call"
    local Heart = require "heart"
    require "lib.playerCollision"

    --Set up window & display
    WindowWidth = 1280
    WindowHeight = 800
    love.window.setMode(WindowWidth,WindowHeight, {resizable=true,vsync=0,minwidth=1280,minheight=800,msaa=2,highdpi=true,usedpiscale=true})
    love.window.setTitle("Upwards "..BuildId)


    --Counters
    FrameCounter = 0
    SecondsCounter = 0
    UpdateCounter = 0
    
    --scaling
    GameScale = 1
    love.graphics.setDefaultFilter("linear","nearest",4)

    --Load images
    HexImg = love.graphics.newImage("Images/UI/hex.png")
    KunaiImg = love.graphics.newImage("Images/UI/kunai.png")

    --state
    State = 'game'

    --lists
    ThrownKunai = {}
    Particles = {}
    Buttons = {}
    Health = {Heart(1,4),Heart(1,4)}

    --initial values
    Kunais = 5
    DKunais = 5
    CameraX = 0
    CameraY = 0
    DiffCX = 0
    DiffCY = 0
    DebugPressed = false
    DebugInfo = false
    TileUpdates = 0
    ScreenshotText = -1
    HudEnabled = true
    KunaiReticle = false
    NewRenderer = true
    HighGraphics = true
    CreativeMode = false

    --Phone Calls
    NextCall = 0
    TBoxWidth = 0
    BoxRect = ''
    NameRect = ''
    TextName = ''
    CurrentText = {'','',''}
    PhoneCounter = 0
    PhoneScale = 4

    --Phone variables
    TriggerPhone = false
    PhoneX = 0
    PhoneY = 0

    --Load Level
    LevelLoad = 'lvl1.arl'
    loadARL(LevelLoad)

    --Initialize Images
    HpImages = {
        ['red0'] = love.graphics.newImage("/Images/Hearts/red0.png"),
        ['red1'] = love.graphics.newImage("/Images/Hearts/red1.png"),
        ['red2'] = love.graphics.newImage("/Images/Hearts/red2.png"),
        ['red3'] = love.graphics.newImage("/Images/Hearts/red3.png"),
        ['red4'] = love.graphics.newImage("/Images/Hearts/red4.png"),
        ['blue1'] = love.graphics.newImage("/Images/Hearts/blue1.png"),
        ['blue2'] = love.graphics.newImage("/Images/Hearts/blue2.png"),
        ['blue3'] = love.graphics.newImage("/Images/Hearts/blue3.png"),
        ['blue4'] = love.graphics.newImage("/Images/Hearts/blue4.png"),
        ['silver1'] = love.graphics.newImage("/Images/Hearts/silver1.png"),
        ['silver2'] = love.graphics.newImage("/Images/Hearts/silver2.png"),
        ['blood'] = love.graphics.newImage("/Images/Hearts/blood.png")
    }


    --Initialize BG Objects
    love.resize()

    --spawn initial entities
    Pl = Player(SpawnPoint[1]*32,SpawnPoint[2]*32+32)


end

function love.update(dt)
    local t = love.timer.getTime()


    --Update counters
    FrameCounter = FrameCounter + dt
    UpdateCounter = UpdateCounter + 1
    SecondsCounter = round(FrameCounter)

    MouseX, MouseY = love.mouse.getPosition()

    --Update Buttons
    for i,v in pairs(Buttons) do
        v:update(dt)
    end

    if State == 'game' or State == 'phonecall' then

        --Update Camera
        normalCamera(MouseX,MouseY,dt,math.max(0,1.5*(Pl.yv-2.5)))

        --Update player physics & animation
        Pl:update(dt)

        --Update player internal collision detection (non-solid objects)
        for i=Pl.col[2]+8,Pl.col[1]-8,24 do
            for j=Pl.col[4],Pl.col[3],27.5 do
                local ret = Pl.se:detect(j,i)
                playerCollisionDetect(ret[2],ret[3],dt)
            end
        end

    end

    --Draw level & do non-physics updating
    if State == 'game' or State == 'phonecall' then
        --Update tiles
        TileUpdates = 0
        tileProperties(dt)


        --Update kunai
        for i,v in ipairs(ThrownKunai) do
            if v:update(dt) then
                DKunais = Kunais
                table.remove(ThrownKunai,i)
            end
        end

        --Update Phone
        PhoneRect = {x = PhoneX, y = PhoneY, w = 15*GameScale*PhoneScale, h = 40*GameScale*PhoneScale}
        if TriggerPhone then
            PhoneScale = 2
            PhoneCounter = PhoneCounter + dt

            --Phone shakes
            if UpdateCounter%2 == 0 then
                PhoneImg = love.graphics.newImage("Images/Phone/phone"..round(1+(UpdateCounter%6)/2)..".png")
            end

            --Phone rings out at 7s
            if PhoneCounter > 7 then
                TriggerPhone = false

            --Move phone back to corner at 6.5s
            elseif PhoneCounter > 6.5 then
                PhoneX = PhoneX + (WindowWidth-(80*GameScale)-PhoneX)*(20*dt)
                PhoneY = PhoneY + ((10*GameScale)-PhoneY)*(20*dt)
            
            --Move phone to your head at 0.5s
            elseif PhoneCounter > 0.5 then
                PhoneX = PhoneX + ((Pl.xpos*GameScale-CameraX-PhoneX-16)+love.math.random(-2,2))*(8*dt)
                PhoneY = PhoneY + ((Pl.ypos*GameScale-CameraY-PhoneY-175)+love.math.random(-2,2))*(8*dt)
            
            --Set phone to top right otherwise
            else
                PhoneX = WindowWidth-(80*GameScale)
                PhoneY = (10*GameScale)
            end

            --Collide
            if pointCollideRect(PhoneRect,MouseX,MouseY) and love.mouse.isDown(1) then
                TriggerPhone = false
                NextCall = 0-NextCall
            end
        else
            PhoneScale = 4
            PhoneImg = love.graphics.newImage("Images/Phone/normal1.png")
            PhoneX = WindowWidth-(80*GameScale)
            PhoneY = (10*GameScale)

            --Pause if clicked
            if DebugPressed == false and NextCall == 0 and pointCollideRect(PhoneRect,MouseX,MouseY) and love.mouse.isDown(1) then
                DebugPressed = true
                PauseGame()
            end
        end

        --Handle Phone Calls
        if NextCall > 0 then
            handlePhone(NextCall,dt)
        end
    end

    --Pause Menu

    if love.keyboard.isDown('escape') then
        DebugPressed = true
        PauseGame()
    end

end


function love.draw()
    love.graphics.setColor(0.1,0.1,0.1,1)
    love.graphics.rectangle("fill",0,0,WindowWidth,WindowHeight)
    love.graphics.setColor(1,1,1,1)

    --Update WindowWidth & WindowHeight
    WindowWidth, WindowHeight = love.graphics.getDimensions()
    GameScale = WindowHeight/800

    --Resume game
    if State == 'resuming' then
        love.graphics.setColor(1,0,0,0.75)
        love.graphics.line(Pl.xpos-CameraX,Pl.ypos-CameraY,Pl.xpos-CameraX+Pl.xv*40*GameScale,Pl.ypos-CameraY+Pl.yv*40*GameScale)
        love.graphics.setColor(1,1,1,1)
        if SecondsCounter > ResumeTimer then
            State = 'game'
        end

    end

    --F1: Toggle HUD
    if love.keyboard.isDown("f1") and not DebugPressed then
        DebugPressed = true
        HudEnabled = not HudEnabled
    end

    --F2: Take Screenshot
    if love.keyboard.isDown("f2") and not DebugPressed then
        DebugPressed = true
        love.graphics.captureScreenshot("Upwards-"..os.time()..".png")
        ScreenshotText = 150
    end

    --F3: Debug Info
    if love.keyboard.isDown("f3") and not DebugPressed then
        DebugPressed = true
        DebugInfo = not DebugInfo
    end

    --T: Toggle reticle
    if love.keyboard.isDown("t") and not DebugPressed then
        DebugPressed = true
        KunaiReticle = not KunaiReticle
    end

    if not love.keyboard.isDown("f1","f2","f3","t","escape") and not love.mouse.isDown(1) then
        DebugPressed = false
    end

    --draw kunai
    for i,v in ipairs(ThrownKunai) do
        love.graphics.draw(v.baseImage,(v.xpos-CameraX)*GameScale,(v.ypos-CameraY)*GameScale,v.direction,2*GameScale,2*GameScale,0,0)
    end

    --draw kunai reticle
    if KunaiReticle then
        love.graphics.setColor(1,1,1,0.5)
        love.graphics.rectangle("fill",MouseX-15-Pl.kunaiInnacuracy,MouseY-1,10,2)
        love.graphics.rectangle("fill",MouseX+5+Pl.kunaiInnacuracy,MouseY-1,10,2)
        love.graphics.rectangle("fill",MouseX-1,MouseY-15-Pl.kunaiInnacuracy,2,10)
        love.graphics.rectangle("fill",MouseX-1,MouseY+5+Pl.kunaiInnacuracy,2,10)

        love.graphics.setColor(1,1,1,1)
    end

    --draw player
    if type(Pl.img) ~= "string" then
        if Pl.dFacing == -1 then
            love.graphics.draw(Pl.img,(Pl.xpos-CameraX+Pl.imgPos[1])*GameScale,(Pl.ypos-CameraY+Pl.imgPos[2])*GameScale,0,-2*GameScale,2*GameScale,-Pl.imgPos[1],0)
        else
            love.graphics.draw(Pl.img,(Pl.xpos-CameraX+Pl.imgPos[1])*GameScale,(Pl.ypos-CameraY+Pl.imgPos[2])*GameScale,0,2*GameScale,2*GameScale,0,0)
        end
    end
    local dirties = 0
    if NewRenderer then
        dirties = RenderTwo()
    else
        dirties = 0
        RenderOne()
    end


    --Draw HUD
    if HudEnabled then
        HudX = -Pl.xv*3
        HudY = -(math.min(0,Pl.yv*6))

        --Draw Phone
        love.graphics.draw(PhoneImg,PhoneX+HudX,PhoneY+HudY,0,GameScale*PhoneScale,GameScale*PhoneScale)
        
        --Hex
        love.graphics.draw(HexImg,HudX,WindowHeight-(220*GameScale)+HudY,(-4.289/57.19),0.25*GameScale,0.25*GameScale)
        
        --Hearts

        for i,hp in ipairs(Health) do
            if hp.amt <= 0 and hp.type ~= 1 then
                table.remove(Health,i)
            else
                local img = HpImages[hp.fileExt..hp.amt]
                love.graphics.draw(img,((120*GameScale)+(68*i*GameScale))+HudX,WindowHeight-(97*GameScale)-(i*5.1*GameScale)+HudY,(-4.289/57.19),4*GameScale,4*GameScale)
            end
        end

        --Rightside HUD Kunais

        for i=0,DKunais-1,1 do
            if i == 0 then
                if Pl.kunaiAni >= 0 and Pl.kunaiAni <= 14 then
                    love.graphics.draw(KunaiImg,WindowWidth-(100*GameScale)-(i*38*GameScale)+Pl.kunaiAni+HudX,WindowHeight-(150*GameScale)-(i*3*GameScale)-(Pl.kunaiAni*Pl.kunaiAni+Pl.kunaiAni*GameScale)+HudY,(4.289/57.19),0.15*GameScale,0.15*GameScale)
                elseif Pl.kunaiAni >= 39 or Pl.kunaiAni <= -1 then
                    love.graphics.draw(KunaiImg,WindowWidth-(100*GameScale)-(i*38*GameScale)+HudX,WindowHeight-(150*GameScale)-(i*3*GameScale)+HudY,(4.289/57.19),0.15*GameScale,0.15*GameScale)
                end
            else
                if Pl.kunaiAni >= 24 and Pl.kunaiAni <= 40 then
                    love.graphics.draw(KunaiImg,WindowWidth-(152*GameScale)-(i*38*GameScale)+(Pl.kunaiAni*2.3)+HudX,WindowHeight-(154*GameScale)-(i*3*GameScale)+(Pl.kunaiAni/5*GameScale)+HudY,(4.289/57.19),0.15*GameScale,0.15*GameScale)
                else
                    love.graphics.draw(KunaiImg,WindowWidth-(100*GameScale)-(i*38*GameScale)+HudX,WindowHeight-(150*GameScale)-(i*3*GameScale)+HudY,(4.289/57.19),0.15*GameScale,0.15*GameScale)
                end
            end
        end


        --Energy bar (ported from 1 line python monstrosity)
        --pg.draw.aaline(HUD,(60,60,60) if 10*j+(i/2)>=pl.energy else (220-(pl.energy*6),40+(pl.energy*6),40) if pl.energy<30 else (40,300-pl.energy,-400+(pl.energy*6)) if pl.energy>80 else (40,220,40), (WID-20-i-(22*j)+int(energyFade),HEI-55-(j*1.666)-(i/13.333)+int(energyFade/12)+(1 if i==0 or i==19 else 0)),(WID-20-i-(22*j)+int(energyFade),HEI-20-(j*1.666)-(i/13.333)+int(energyFade/12)-(1 if i==0 or i==19 else 0)))

        --Background rect
        love.graphics.setColor(0.8,0.8,0.8,0.6)
        love.graphics.draw(BgRectCanvas,HudX,HudY)
        for j=0, 9, 1 do
            for i=1, 20, HighGraphics and 1 or 2 do
                --Color math
                if 10*j+(i/2) >= Pl.energy then
                    love.graphics.setColor(0.3,0.3,0.3,1)
                elseif Pl.energy < 30 then
                    love.graphics.setColor(1-(Pl.energy/33.3333),0.1+(Pl.energy/33.3333),0.3,1)
                elseif Pl.energy > 80 then
                    love.graphics.setColor(0.1,1.4-(Pl.energy/200),-2.36+(Pl.energy/30),1)
                else
                    love.graphics.setColor(0.1,1,0.3,1)
                end
                --Colored rects
                if i == 1 or HighGraphics and i == 20 or i == 19 then
                    love.graphics.rectangle('fill',WindowWidth-(20*GameScale)-i*GameScale-(22*j*GameScale)+HudX,WindowHeight-(54*GameScale)-(j*1.66666*GameScale)-(i/13.333333*GameScale)+HudY,2*GameScale,33*GameScale)
                else
                    love.graphics.rectangle('fill',WindowWidth-(20*GameScale)-i*GameScale-(22*j*GameScale)+HudX,WindowHeight-(55*GameScale)-(j*1.66666*GameScale)-(i/13.333333*GameScale)+HudY,2*GameScale,35*GameScale)
                end
                love.graphics.setColor(1,1,1,1)
            end
        end
    end

    --Text
    if State == 'phonecall' then

        --Rectangles
        --exterior
        love.graphics.setColor(1,1,1,1)
        love.graphics.rectangle("fill", BoxRect.x-5, BoxRect.y-5, BoxRect.w+10, BoxRect.h+10, 30,30)
        love.graphics.rectangle("fill", NameRect.x-5, NameRect.y-5, NameRect.w+10, NameRect.h+10, 30,30)
        
        --interior
        love.graphics.setColor(0,0,0,1)
        love.graphics.rectangle("fill", BoxRect.x, BoxRect.y, BoxRect.w, BoxRect.h, 25,25)
        love.graphics.rectangle("fill", NameRect.x, NameRect.y, NameRect.w, NameRect.h, 25,25)
        love.graphics.setColor(1,1,1,1)

        --Text
        simpleText(TextName,28,90*GameScale,WindowHeight-(380*GameScale))
        for i,v in ipairs(CurrentText) do
            simpleText(v,32,60*GameScale,WindowHeight-(330*GameScale)+(i*GameScale*50))
        end
    end

    --EVERYTHING ABOVE GETS SHADERS
    -- love.graphics.setShader(blurShader)
    -- blurShader:send("radius",3)

    --Draw BuildId
    simpleText("Upwards "..BuildId,20,10*GameScale,10*GameScale)

    --Draw Buttons
    for i,v in pairs(Buttons) do
        v:draw()
    end


    --Screenshot Text
    if ScreenshotText > 0 then
        love.graphics.setColor(1,1,1,math.min(1,ScreenshotText/60))
        simpleText("Screenshot Saved",20,WindowWidth-(200*GameScale),WindowHeight-(100*GameScale))
        ScreenshotText = ScreenshotText - 1
    elseif ScreenshotText > -1 then
        ScreenshotText = -1
    end


    --debug text & sensor
    if DebugInfo then
        local stats = love.graphics.getStats()
        local SH = 0
        for i,v in ipairs(Pl.se.locations) do
            if v[1] then
                SH = SH + 1
            end
        end
        simpleText("XY: "..round(Pl.xpos).." / "..round(Pl.ypos).." V: "..round(Pl.xv,2).." / "..round(Pl.yv,2),16,10*GameScale,40*GameScale)
        simpleText(round(love.timer.getFPS(),1).." fps Dr: "..WindowWidth.."x"..WindowHeight.." S: "..round(GameScale,2).." V: "..love.window.getVSync(),16,10*GameScale,60*GameScale)
        simpleText("PL: "..round(Pl.abilities[1],1).."/"..round(Pl.abilities[2],1).."/"..round(Pl.abilities[3],1).."/"..round(Pl.abilities[4],1).."/"..round(Pl.abilities[5],1).." F: "..Pl.facing.." D: "..Pl.dFacing.." E: "..round(Pl.energy,1).." O: "..Pl.onWall.." Jc: "..round(Pl.jCounter,2).." Ms: "..round(Pl.maxSpd,2),16,10*GameScale,80*GameScale)
        simpleText("PLa: "..Pl.animation.." N: "..Pl.nextAni.." C: "..round(Pl.counter%60).." F: "..round(Pl.aniFrame,1).." T: "..round(Pl.aniTimer,1).."/"..round(Pl.aniiTimer,1),16,10*GameScale,100*GameScale)
        simpleText("Sc: "..#Pl.se.locations.." Sh: "..SH,16,10*GameScale,120*GameScale)
        simpleText("Dc: "..round(stats.drawcalls).." Tm: "..round(stats.texturememory/1024/1024,1).."MB Im: "..round(stats.images).." Di: "..round(dirties),16,10*GameScale,140*GameScale)
        simpleText("L: "..LevelLoad,16,10*GameScale,160*GameScale)

        --Draw sensors
        Pl.se:draw(true)
        for i,v in pairs(ThrownKunai) do
            v.kSe:draw(true)
        end

    end
    Pl.se:draw(false)
end




local love_errorhandler = love.errorhandler
function love.errorhandler(msg)
---@diagnostic disable-next-line: undefined-global
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end


function RenderOne()
    --draw blocks
    Xl,Yl = getOnScreen()
    for i,x in ipairs(Xl) do
        for o,y in ipairs(Yl) do
            local xt = math.floor(x/32)
            local yt = math.floor(y/32)
            x = x - (x%32)
            y = y - (y%32)
            local bl = LevelData[xt.."-"..yt]

            --Draw tile
            if (LoadedTiles[bl]~=nil) then
                local t = split(LevelData[xt.."-"..yt],"-")
                if t[1] == "7" or t[1] == "8" or t[1] == "9" or t[1] == "10" then
                    love.graphics.draw(LoadedTiles[bl],(x-CameraX)*GameScale,(y-CameraY)*GameScale,0,2*GameScale,2*GameScale)
                else
                    love.graphics.draw(LoadedTiles[bl],(x-CameraX)*GameScale,(y-CameraY)*GameScale,0,1*GameScale,1*GameScale)
                end
            end

            --Draw block text when pressing P
            if love.keyboard.isDown("p") and bl~= '0-0' then
                simpleText(bl,14,16+(x-CameraX)*GameScale,16+(y-CameraY)*GameScale,'center')
            end
        end
    end

end

function RenderTwo()
    local dir = 0

    --Update Dirty Tiles
    love.graphics.setCanvas(TileCanvas)
    for i,v in pairs(DirtyTiles) do
        dir = dir + 1
        local bl = LevelData[i]
        local x = split(i,"-")[1]
        local y = split(i,"-")[2]
        if LoadedTiles[bl]~=nil then
            local t = split(LevelData[i],"-")
            if t[1] == "7" or t[1] == "8" or t[1] == "9" or t[1] == "10" then
                love.graphics.draw(LoadedTiles[bl],x*32,y*32,0,2*GameScale,2*GameScale)
            else
                love.graphics.draw(LoadedTiles[bl],x*32,y*32,0,1*GameScale,1*GameScale)
            end
        else
            love.graphics.setBlendMode('replace')
            love.graphics.setColor(0,0,0,0)
            love.graphics.rectangle('fill',x*32,y*32,32*GameScale,32*GameScale)
            love.graphics.setColor(1,1,1,1)
            love.graphics.setBlendMode('alpha')
        end
    end
    love.graphics.setCanvas()
    DirtyTiles = {}

    --Draw Background
    love.graphics.draw(TileCanvas,LevelWidth-(CameraX*GameScale)-100,LevelHeight-(CameraY*GameScale)-100,0,GameScale,GameScale)
    return dir
end

function love.resize()

    --Set window width & height
    WindowWidth, WindowHeight = love.graphics.getDimensions()
    GameScale = WindowHeight/800

    --Initialize Energy bar background area
    BgRectCanvas = love.graphics.newCanvas()
    love.graphics.setCanvas(BgRectCanvas)
    for i=-100,210,1 do
        local hei = math.min(40,(math.sqrt(210-i)*8.944))
        love.graphics.rectangle('fill',WindowWidth-(50*GameScale)-i*GameScale,WindowHeight-(60*GameScale)-(i/13.333333*GameScale),1*GameScale,hei*GameScale)
    end
    love.graphics.setCanvas()

    --Initialize Level Canvas
    DirtyTiles = {}
    TileCanvas = love.graphics.newCanvas(LevelWidth*32,LevelHeight*32)

    love.graphics.setCanvas(TileCanvas)
    love.graphics.clear()
    for x=0,LevelWidth,1 do
        for y=0,LevelHeight,1 do
            local bl = LevelData[x.."-"..y]
            if LoadedTiles[bl]~=nil then
                local t = split(LevelData[x.."-"..y],"-")
                if t[1] == "7" or t[1] == "8" or t[1] == "9" or t[1] == "10" then
                    love.graphics.draw(LoadedTiles[bl],x*32,y*32,0,2*GameScale,2*GameScale)
                else
                    love.graphics.draw(LoadedTiles[bl],x*32,y*32,0,1*GameScale,1*GameScale)
                end
            end
        end
    end
    love.graphics.setCanvas()

end
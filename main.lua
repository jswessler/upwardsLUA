--!file: main.lua
--Upwards!

--[[
]]

--Build Id
BuildId = "a1.0.1"

if arg[2] == "debug" then
    require("lldebugger").start()
end

function love.load()
    --Imports
    Object = require "lib.classic"
    require "lib.loadArl"
    require "lib.extraFunc"
    require "lib.playerCollision"
    
    require "shader.gaussianblur"

    require "player"
    require "sensor"
    require "camera"
    require "kunai"
    require "button"
    require "call"
    require "startup"
    require "heart"

    --Initial loading routine
    State = 'jlidecode'
    InitialLoad()

end

function love.update(dt)
    --Update counters
    FrameCounter = FrameCounter + dt
    UpdateCounter = UpdateCounter + 1
    SecondsCounter = round(FrameCounter)

    --Update mouse position
    MouseX, MouseY = love.mouse.getPosition()

    --Update Buttons
    for i,v in pairs(Buttons) do
        v:update(dt)
    end

    --Gamemodes where physics is enabled
    if State == 'game' or State == 'phonecall' then
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

    --Gamemodes where level is updated
    if State == 'game' or State == 'phonecall' then

        --Update Tiles
        TileUpdates = 0
        tileProperties(dt)

        --Update Kunai
        for i,v in ipairs(ThrownKunai) do
            if v:update(dt) then
                DKunais = Kunais
                table.remove(ThrownKunai,i)
            end
        end

        --Update particles
        for i,v in ipairs(Particles) do
            if v:update(dt) then
                table.remove(Particles,i)
            end
        end

        --Update Phone
        PhoneRect = {x = PhoneX, y = PhoneY, w = 15*GameScale*PhoneScale, h = 40*GameScale*PhoneScale}
        if TriggerPhone then
            PhoneScale = 2
            PhoneCounter = PhoneCounter + dt

            --Phone shakes (image)
            if UpdateCounter%2 == 0 then
                PhoneImg = love.graphics.newImage("Images/Phone/phone"..round(1+(UpdateCounter%6)/2)..".png")
            end

            --Phone rings out at 8s
            if PhoneCounter > 8 then
                NextCall = 0
                TriggerPhone = false

            --Move phone back to corner at 7.5s
            elseif PhoneCounter > 7.5 then
                PhoneX = PhoneX + (WindowWidth-(80*GameScale)-PhoneX)*(20*dt)
                PhoneY = PhoneY + ((10*GameScale)-PhoneY)*(20*dt)
            
            --Move phone to your head at 0.5s
            elseif PhoneCounter > 0.5 then
                PhoneX = PhoneX + (((Pl.xpos-CameraX)*(GameScale*Zoom)-PhoneX-(16*GameScale*Zoom))+love.math.random(-12,12))*(8*dt)
                PhoneY = PhoneY + (((Pl.ypos-CameraY)*(GameScale*Zoom)-PhoneY-(175*GameScale*Zoom))+love.math.random(-12,12))*(8*dt)
            
            --Set phone to top right otherwise
            else
                PhoneX = WindowWidth-(80*GameScale)
                PhoneY = (10*GameScale)
            end

            --Collide
            if (pointCollideRect(PhoneRect,MouseX,MouseY) and (love.mouse.isDown(1)) or love.keyboard.isDown(KeyBinds['Call'])) then
                TriggerPhone = false
                NextCall = 0-NextCall
            end
        else

            --Set phone to the top right corner
            PhoneScale = 4
            PhoneImg = DefaultPhoneImg
            PhoneX = WindowWidth-(80*GameScale)
            PhoneY = (10*GameScale)

            --If hovering over the phone when not active
            if pointCollideRect(PhoneRect,MouseX,MouseY) then
                
                --Switch phone image
                PhoneImg = PausePhoneImg

                --Pause if phone is clicked on the top right corner
                if DebugPressed == false and NextCall == 0 and love.mouse.isDown(1) then
                    DebugPressed = true
                    PauseGame()
                end
            end
        end

        --Handle Phone Calls
        if NextCall > 0 then
            handlePhone(NextCall,dt)
        end
    end

    --Do things when ESC pressed
    if love.keyboard.isDown(KeyBinds['Pause']) and not DebugPressed then
        DebugPressed = true

        --States where ESC sends you to pause menu
        if State == 'options' or State == 'game' or State == 'surequit' or State == 'phonecall' then
            PauseGame()
        
        --States where ESC sends you to options menu
        elseif State == 'graphicsmenu' or State == 'controlsmenu' then
            OptionsMenu()
            
        --States where ESC puts you back in the game
        elseif State == 'pause' then
            ResumeGame()

        --States where ESC quits the game
        elseif State == 'menu' then
            love.event.quit()
        end
    end
end

function love.draw()
    local starttime = love.timer.getTime()


    --Background color
    love.graphics.setColor(0.1,0.1,0.1,1)
    love.graphics.rectangle("fill",0,0,WindowWidth,WindowHeight)
    love.graphics.setColor(1,1,1,1)

    --Update WindowWidth & WindowHeight
    WindowWidth, WindowHeight = love.graphics.getDimensions()
    GameScale = WindowHeight/800

    --F2: Take Screenshot
    if love.keyboard.isDown("f2") and not DebugPressed then
        DebugPressed = true
        love.graphics.captureScreenshot("Upwards-"..os.time()..".png")
        ScreenshotText = 150
    end

    --Things to draw when the game is running
    if State ~= 'menu' and State ~= 'initialload' and State ~= "jlidecode" then

        --Update Zoom
        local tz = ZoomBase
        if (HighGraphics and UpdateCounter%1==1 or UpdateCounter%4==1) and math.abs(Pl.xv) + math.abs(Pl.yv/2) >= 2 then
            tz = tz + ((5 - (math.abs(Pl.xv) + math.abs(Pl.yv/2)))/40)-0.075
        end
        Zoom = Zoom + (tz-Zoom)/(0.5/love.timer.getDelta())
        GameScale = GameScale * Zoom

        --Update Camera
        normalCamera(MouseX,MouseY,math.min(0.04,1/love.timer.getFPS()),math.max(0,1.5*(Pl.yv-2.5)))

        --F1: Toggle HUD
        if love.keyboard.isDown("f1") and not DebugPressed then
            DebugPressed = true
            HudEnabled = not HudEnabled
        end

        --F3: Debug Info
        if love.keyboard.isDown("f3") and not DebugPressed then
            DebugPressed = true
            DebugInfo = not DebugInfo
        end

        --F4: Sensor Info
        if love.keyboard.isDown("f4") and not DebugPressed then
            DebugPressed = true
            SensorInfo = not SensorInfo
        end

        --T: Toggle reticle
        if love.keyboard.isDown("t") and not DebugPressed then
            DebugPressed = true
            KunaiReticle = not KunaiReticle
        end

        --Draw Kunai
        for i,v in ipairs(ThrownKunai) do
            love.graphics.draw(v.baseImage,(v.xpos-CameraX)*GameScale,(v.ypos-CameraY)*GameScale,v.direction,2*GameScale,2*GameScale,0,0)
        end

        --Draw Player
        if type(Pl.img) ~= "string" then

            if Pl.dFacing == -1 then
                love.graphics.setColor(0,0,0,0.5)
                love.graphics.draw(Pl.img,(Pl.xpos-5-CameraX+Pl.imgPos[1])*GameScale,(Pl.ypos+10-CameraY+Pl.imgPos[2])*GameScale,0,-2*GameScale,2*GameScale,-Pl.imgPos[1],0)
                love.graphics.setColor(1,1,1,1)
                love.graphics.draw(Pl.img,(Pl.xpos-CameraX+Pl.imgPos[1])*GameScale,(Pl.ypos-CameraY+Pl.imgPos[2])*GameScale,0,-2*GameScale,2*GameScale,-Pl.imgPos[1],0)
            else
                love.graphics.setColor(0,0,0,0.5)
                love.graphics.draw(Pl.img,(Pl.xpos-5-CameraX+Pl.imgPos[1])*GameScale,(Pl.ypos+10-CameraY+Pl.imgPos[2])*GameScale,0,2*GameScale,2*GameScale,0,0)
                love.graphics.setColor(1,1,1,1)
                love.graphics.draw(Pl.img,(Pl.xpos-CameraX+Pl.imgPos[1])*GameScale,(Pl.ypos-CameraY+Pl.imgPos[2])*GameScale,0,2*GameScale,2*GameScale,0,0)
            end

        end

        --Draw Particles
        for i,v in ipairs(Particles) do
            v:draw()
        end

        --Draw Blocks
        if NewRenderer then
            RenderTwo()
        else
            RenderOne()
        end

        --Get sensor data
        local SH = 0
        if DebugInfo then
            for i,v in ipairs(Pl.se.locations) do
                if v[1] then
                    SH = SH + 1
                end
            end
        end

        --Draw sensors
        if SensorInfo then
            Pl.se:draw(true)
            for i,v in pairs(ThrownKunai) do
                v.kSe:draw(true)
                v.kSe:draw(false)
            end
        end

        --HUD Below this (Nonscaled elements)
        GameScale = GameScale / Zoom

        --draw kunai reticle
        if KunaiReticle then
            love.graphics.setColor(1,1,1,0.5)
            love.graphics.rectangle("fill",MouseX-(15*GameScale)-Pl.kunaiInnacuracy,MouseY-(1*GameScale),10*GameScale,2*GameScale)
            love.graphics.rectangle("fill",MouseX+(5*GameScale)+Pl.kunaiInnacuracy,MouseY-(1*GameScale),10*GameScale,2*GameScale)
            love.graphics.rectangle("fill",MouseX-(1*GameScale),MouseY-(15*GameScale)-Pl.kunaiInnacuracy,2*GameScale,10*GameScale)
            love.graphics.rectangle("fill",MouseX-(1*GameScale),MouseY+(5*GameScale)+Pl.kunaiInnacuracy,2*GameScale,10*GameScale)

            love.graphics.setColor(1,1,1,1)
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

            --Energy bar background
            love.graphics.setColor(0.8,0.8,0.8,0.6)
            love.graphics.draw(BgRectCanvas,HudX,HudY)

            --Energy bar
            love.graphics.setCanvas(EnergyCanvas)
            for j=0, 9, 1 do
                for i=1, round(20*GameScale), HighGraphics and 1 or 2 do
                    --Color math
                    if 10*j+(i/(2*GameScale)) >= Pl.energy then
                        love.graphics.setColor(0.3,0.3,0.3,1)
                    elseif Pl.energy < 30 then
                        love.graphics.setColor(1-(Pl.energy/33.3333),0.1+(Pl.energy/33.3333),0.3,1)
                    elseif Pl.energy > 80 then
                        love.graphics.setColor(0.1,1.4-(Pl.energy/200),-2.36+(Pl.energy/30),1)
                    else
                        love.graphics.setColor(0.1,1,0.3,1)
                    end
                    --Colored rects
                    local h = (i==1 or i==round(20*GameScale)) and 33 or 35
                    love.graphics.rectangle('fill',(238*GameScale)-(20*GameScale)-i-(22*j*GameScale),(35-h)/2,HighGraphics and 1 or 2,h*GameScale)
                end
            end
            love.graphics.setColor(1,1,1,1)
            love.graphics.setCanvas()
            love.graphics.draw(EnergyCanvas,WindowWidth-(235*GameScale)+HudX,WindowHeight-(71.5*GameScale)+HudY,(4.289/57.19))
        end

        --Text
        if State == 'phonecall' then

            --Border rectangle (white)
            love.graphics.setColor(1,1,1,1)
            love.graphics.rectangle("fill", BoxRect.x-5, BoxRect.y-5, BoxRect.w+10, BoxRect.h+10, 30,30)
            love.graphics.rectangle("fill", NameRect.x-5, NameRect.y-5, NameRect.w+10, NameRect.h+10, 30,30)
            
            --Interior rectangle (black)
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

        love.graphics.setColor(1,1,1,1)


        --debug text & sensor
        if DebugInfo then
            local stats = love.graphics.getStats()
            
            simpleText("XY: "..round(Pl.xpos).." / "..round(Pl.ypos).." V: "..round(Pl.xv,2).." / "..round(Pl.yv,2),16,10*GameScale,40*GameScale)
            simpleText(round(love.timer.getFPS(),1).." fps Dr: "..WindowWidth.."x"..WindowHeight.." S: "..round(GameScale,2).." Z: "..round(Zoom,2).."/"..round(ZoomBase,2).." V: "..love.window.getVSync(),16,10*GameScale,60*GameScale)
            simpleText("PL: "..round(Pl.abilities[1],1).."/"..round(Pl.abilities[2],1).."/"..round(Pl.abilities[3],1).."/"..round(Pl.abilities[4],1).."/"..round(Pl.abilities[5],1).." F: "..Pl.facing.." D: "..Pl.dFacing.." E: "..round(Pl.energy,1).." O: "..Pl.onWall.." Jc: "..round(Pl.jCounter,2).." Ms: "..round(Pl.maxSpd,2),16,10*GameScale,80*GameScale)
            simpleText("PLa: "..Pl.animation.." N: "..Pl.nextAni.." C: "..round(Pl.counter%60).." F: "..round(Pl.aniFrame,1).." T: "..round(Pl.aniTimer,1).."/"..round(Pl.aniiTimer,1),16,10*GameScale,100*GameScale)
            simpleText("Sc: "..#Pl.se.locations.." Sh: "..SH,16,10*GameScale,120*GameScale)
            simpleText("Dc: "..round(stats.drawcalls).." Tm: "..round(stats.texturememory/1024/1024,1).."MB Im: "..round(stats.images)..(HighGraphics and " Fancy" or " Fast").." GB: "..round(2986*(60*love.timer.getDelta())),16,10*GameScale,140*GameScale)
            simpleText(_VERSION.." G: "..round(collectgarbage("count")),16,10*GameScale,180*GameScale)
            simpleText("Love "..love.getVersion().." "..love.system.getOS().. " C: "..love.system.getProcessorCount(),16,10*GameScale,200*GameScale)
        end
        Pl.se:draw(false)
    else

        --Non-game states
        --Logo
        if State == 'initialload' then
            love.graphics.setColor(1,1,1,(FrameCounter < 0.5 and FrameCounter/0.5 or FrameCounter > 2.5 and 3.5-FrameCounter or 1))
            love.graphics.draw(LogoImg,0,0,0,WindowWidth/1536,WindowWidth/1536)
            if FrameCounter > 4 or love.keyboard.isDown(KeyBinds['Jump']) then
                MenuLoad()
            end
        end

        --Title Screen
        if State == 'menu' then
            love.graphics.setColor(1,1,1,math.min(1,FrameCounter))
            love.graphics.draw(TitleImg,0,0,0,WindowHeight/2160,WindowHeight/2160)
        end

        --JLI Decode
        if State == 'jlidecode' then
            local JLIDecodes = {"FMV/logo", "FMV/title"}
            JLIStatus = 'Checking '..JLIDecodes[JLIProgress]
            simpleText(JLIStatus,24,WindowWidth/2,WindowHeight/2-100,'center')
            JLIInitialDecode(JLIDecodes[JLIProgress])
            love.graphics.setColor(0.25,0.25,0.25,1)
            love.graphics.rectangle("fill",0,0,WindowWidth,WindowHeight)
            love.graphics.setColor(1,1,1,1)
            simpleText(JLIStatus,24,WindowWidth/2,WindowHeight/2-50,'center')
            JLIProgress = JLIProgress + 1
            if JLIProgress > #JLIDecodes then
                InitialLoadLoad()
            end
        end
    end

    --Screenshot Text
    if ScreenshotText > 0 then
        love.graphics.setColor(1,1,1,math.min(1,ScreenshotText/60))
        simpleText("Screenshot Saved",20,WindowWidth-(200*GameScale),WindowHeight-(100*GameScale))
        ScreenshotText = ScreenshotText - 1
    elseif ScreenshotText > -1 then
        ScreenshotText = -1
    end
    love.graphics.setColor(1,1,1,1)

    --Reset keys pressed (so you can't spam keys)
    if not love.keyboard.isDown("f1","f2","f3","f4","t","escape") and not love.mouse.isDown(1) then
        DebugPressed = false
    end

    --Draw BuildId
    simpleText("Upwards "..BuildId,20,10*GameScale,10*GameScale)

    --Buttons
    for i,v in pairs(Buttons) do
        v:draw()
    end

    --Enforce FPS cap
    if FpsLimit ~= 0 then
        while love.timer.getTime() < starttime + (1/FpsLimit) do
            --Spinning loop
        end
    end
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

        --Add new blocks
        if LoadedTiles[bl]~=nil then
            local t = split(LevelData[i],"-")
            if t[1] == "7" or t[1] == "8" or t[1] == "9" or t[1] == "10" then
                love.graphics.draw(LoadedTiles[bl],x*32,y*32,0,2,2)
            else
                love.graphics.draw(LoadedTiles[bl],x*32,y*32,0,1,1)
            end
        else

            --Delete blocks that don't exist anymore
            love.graphics.setBlendMode('replace')
            love.graphics.setColor(0,0,0,0)
            love.graphics.rectangle('fill',x*32,y*32,math.max(32,32*GameScale/Zoom),math.max(32,32*GameScale/Zoom))
            love.graphics.setColor(1,1,1,1)
            love.graphics.setBlendMode('alpha')
        end
    end

    --Reset canvas to the screen
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

    if State ~= 'initialload' and State ~= 'menu' and State ~= 'jlidecode' then

        --Initialize Energy bar background area
        BgRectCanvas = love.graphics.newCanvas(WindowWidth+100,WindowHeight,{msaa=4})
        love.graphics.setCanvas(BgRectCanvas)
        for i=-100,210,1 do
            local hei = math.min(40,(math.sqrt(210-i)*8.944))
            love.graphics.rectangle('fill',WindowWidth-(50*GameScale)-i*GameScale,WindowHeight-(60*GameScale)-(i/13.333333*GameScale),1*GameScale,hei*GameScale)
        end

        --Energy bar Canvas
        EnergyCanvas = love.graphics.newCanvas(238*GameScale,35*GameScale,{msaa=4})

        love.graphics.setCanvas()
        --Initialize Level Canvas
        DirtyTiles = {}
        TileCanvas = love.graphics.newCanvas(LevelWidth*32,LevelHeight*32,{msaa=2})

        love.graphics.setCanvas(TileCanvas)
        love.graphics.clear()
        for x=0,LevelWidth,1 do
            for y=0,LevelHeight,1 do
                local bl = LevelData[x.."-"..y]
                if LoadedTiles[bl]~=nil then
                    local t = split(LevelData[x.."-"..y],"-")
                    if t[1] == "7" or t[1] == "8" or t[1] == "9" or t[1] == "10" then
                        love.graphics.draw(LoadedTiles[bl],x*32,y*32,0,2,2)
                    else
                        love.graphics.draw(LoadedTiles[bl],x*32,y*32,0,1,1)
                    end
                end
            end
        end
        love.graphics.setCanvas()
    end
end

function love.keypressed(key, scancode, isrepeat)
    local x = split(State,'-')
    if x[2] == 'CS' then
        KeyBinds[x[1]] = love.keyboard.getScancodeFromKey(key)
        State = 'controlsmenu'
    end
end
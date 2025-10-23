--!file: main.lua
--Upwards!

--[[ todo

    a1.2.7
    - More pixel art
    - Fix phone calls (add portraits)


    a1.3.0
    - Lvlgen in lua
]]

BuildId = "Alpha 1.2.6_03"

if arg[2] == "debug" then
    require("lldebugger").start()
end

function love.load()
    --Imports
    Object = require "lib.classic"
    require "lib.extraFunc"
    require "lib.playerCollision"

    require "animation"

    require "entity.kunai"
    require "entity.coin"
    require "entity.entity"
    require "entity.enemy"

    require "hdma.hdma"

    require "player"
    require "sensor"
    require "camera"
    require "button"
    require "call"
    require "startup"
    require "heart"

    InitialLoad() --Initial Loading Routine

end

function love.update(dt)
    --Update counters
    FrameCounter = FrameCounter + dt
    UpdateCounter = UpdateCounter + 1
    SecondsCounter = round(FrameCounter)

    if GlAni > 0 then GlAni = GlAni - dt end --Update the GlAni timer, for animations
    if GlAni < 0 then GlAni = 0 end --reset to 0 when done

    MouseX, MouseY = love.mouse.getPosition() --Update mouse position

    --Update Buttons
    for i,v in pairs(Buttons) do
        v:update(dt)
    end

    if StateVar.physics == 'on' then --Gamemodes where physics is enabled

        --Update player physics & animation
        Pl:update(dt)

        --Update player internal collision detection for non-solid objects
        for i=Pl.col[2]+8,Pl.col[1]-8,24 do
            for j=Pl.col[4],Pl.col[3],27.5 do --Covers a region inside the player

                --Nonsolid block detection
                local ret = Pl.se:detect(j,i) --detect block Ids
                PlColDetect(ret[2],ret[3],dt) --see if those block Ids can collide with the player
            end
        end


        --Update Tiles
        TileUpdates = 0 --debug count number of tile updates
        TileProp(dt)

        --Update enemies
        for i,v in ipairs(Enemies) do
            v:update(dt)
            if v.health == 0 then
                v:die()
            end

            --Disappear at the end of death animations
            if FrameCounter > v.deathCounter and v.health == -1 then
                --Create coin if squished
                if v.deathMode == 'squish' then
                    local coin = Coin(v.xpos,v.ypos,(love.math.random()-0.5)*5,(love.math.random()-1.5)*10)
                    table.insert(Entities,coin)
                end
                --Regardless, remove enemy from list
                table.remove(Enemies,i)
            end
        end

        --Update Entities
        for i,v in ipairs(Entities) do
            if v:update(dt) then
                DKunais = Kunais
                table.remove(Entities,i)
            end
        end

        --Update particles
        for i,v in ipairs(Particles) do
            if v:update(dt) then
                table.remove(Particles,i)
            end
        end

        --Update total health
        TotalHealth = 0
        HeartFlashAmt = HeartFlashAmt - (dt*2.5) --heart flash fades out
        for i,hp in ipairs(Health) do
            hp:update(dt)
            if hp.amt > 0 then
                TotalHealth = TotalHealth + hp.amt
            end
        end


        --Handle Phone Calls
        if NextCall > 0 then
            handlePhone(NextCall,dt)
        end

        --Autosave every 45s
        if FrameCounter > AutoSave then
            SaveGame()
            FadingText = {150, "Autosaving..."}
            AutoSave = FrameCounter + 45
        end
    end

    --Update Phone
    if StateVar.genstate == 'game' then
        PhoneRect = {x = PhoneX, y = PhoneY, w = 15*GameScale*PhoneScale, h = 40*GameScale*PhoneScale}
        PhoneAnimate(dt)
    end

    --Do things when ESC pressed
    if love.keyboard.isDown(KeyBinds['Pause']) and not DebugPressed then
        DebugPressed = true

        --States where ESC sends you to pause menu
        if StateVar.genstate == 'game' and (StateVar.state == 'play') or (StateVar.state == 'menu' and (StateVar.substate == "options" or StateVar.substate == 'surequit')) then
            PauseGame()
            if love.keyboard.isDown('lshift') then
                GlAni = 0.5
                StateVar.ani = 'totitle'
            end
        
        --States where ESC sends you to options menu
        elseif StateVar.genstate == 'game' and StateVar.state ~= 'play' and (StateVar.substate == 'graphics' or StateVar.substate == 'performance' or StateVar.substate == 'controls' or StateVar.substate == 'audio') then
            OptionsMenu()
            
        --States where ESC puts you back in the game
        elseif StateVar.genstate == 'game' and StateVar.state == 'menu' then
            ResumeGame()

        --States where ESC quits the game
        elseif StateVar.genstate == 'title' then
            if StateVar.substate == 'options' then
                TitleScreen(false)
            end
        else
            GlAni = 0.5 --Quit the game
            StateVar.ani = 'quitting'
        end
    end

    if FpsLimit ~= 0 then
        Next_Time = Next_Time + 1/FpsLimit
    end

    --Collect garbage every few frames
    if DrawCounter%8 == 0 then
        collectgarbage('step', collectgarbage('count')/60)
    end

    --Enforce FPS cap
    if FpsLimit ~= 0 then
        local cur_time = love.timer.getTime()
        if Next_Time <= cur_time then
            Next_Time = cur_time
            return
        end
        love.timer.sleep(Next_Time - cur_time)
    end

end

function love.draw()
    DrawCounter = DrawCounter + 1 --debug count draw calls
    love.graphics.setCanvas(ScreenCanvas)
    love.graphics.clear() --reset main canvas


    --Background color
    love.graphics.setColor(0.1,0.1,0.1,1)
    love.graphics.rectangle("fill",0,0,WindowWidth,WindowHeight)
    love.graphics.setColor(1,1,1,1)

    --Draw HDMA background
    


    --Update WindowWidth & WindowHeight
    WindowWidth, WindowHeight = love.graphics.getDimensions()
    GameScale = WindowHeight/800

    --F2: Take Screenshot
    if love.keyboard.isDown("f2") and not DebugPressed then
        DebugPressed = true
        love.graphics.captureScreenshot("Upwards-"..os.time()..".png")
        FadingText = {155, "Screenshot Taken"}
    end

    --Things to draw when the game is running
    if StateVar.physics ~= 'off' and StateVar.genstate == 'game' then

        --Update Zoom
        local tz = ZoomBase+ZoomScroll
        if (HighGraphics and UpdateCounter%1==1 or UpdateCounter%4==1) and math.abs(Pl.xv) + math.abs(Pl.yv/2) >= 2 then --slightly zoom out when travelling at high speed
            tz = tz + ((5 - (math.abs(Pl.xv) + math.abs(Pl.yv/2)))/10)-0.3
        end
        Zoom = Zoom + (tz-Zoom)/(0.5/love.timer.getDelta())
        GameScale = GameScale * Zoom

        --Update Camera
        if StateVar.physics == 'on' then
            normalCamera(MouseX,MouseY,math.min(0.04,1/love.timer.getFPS()),math.max(0,2.5*(Pl.yv-2.5)))
        end

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

        --F5: Toggle reticle
        if love.keyboard.isDown("f5") and not DebugPressed then
            DebugPressed = true
            KunaiReticle = not KunaiReticle
        end

        --F6: Deal 1 dmg
        if love.keyboard.isDown("f6") and not DebugPressed then
            DebugPressed = true
            local dmgAmt = 1
            for i=#Health,1,-1 do
                dmgAmt = Health[i]:takeDmg(dmgAmt)
            end
        end

        --Draw Entities
        for i,v in ipairs(Entities) do
            v:draw(GameScale)
        end

        --Draw Player
        if StateVar.physics == 'on' then
            Pl:animate(Pl.saveDt)
        end
        Pl:draw()

        --Draw enemies
        for i,v in ipairs(Enemies) do
            v:draw()
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
                    SH = SH + 1 --counts up the number of sensor hits
                end
            end
        end

        --Draw sensors
        if SensorInfo then
            Pl.se:draw() --Draw all player sensors
            for i,v in pairs(Entities) do --Draw all entity sensors
                v.se:draw()
            end
            for i,v in pairs(Enemies) do --Draw all enemy sensors
                v.se:draw()
            end
        end

        --Auto set step size if enabled
        if AutoStep then
            local f = love.timer.getFPS()
            StepSize = clamp(round((HighGraphics and 360 or 240)/f),2,16)
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
            HudX, HudY = HudSetup()

            --Draw Phone
            love.graphics.draw(PhoneImg,PhoneX+HudX,PhoneY+HudY,0,GameScale*PhoneScale,GameScale*PhoneScale)
            
            --Draw Hex
            love.graphics.setDefaultFilter("linear","linear",8)
            love.graphics.draw(HexImg,HudX-(2*GameScale),WindowHeight-(215*GameScale)+HudY,0,0.25*GameScale,0.26*GameScale)
            love.graphics.setDefaultFilter("linear","nearest",4)

            --Draw Hearts (Hearts are only updated on draw)
            --Remove depleted soul/silver/blood hearts
            for i,hp in ipairs(Health) do
                if hp.amt <= 0 and hp.type ~= 1 then
                    table.remove(Health,i)
                else
                    local img = HpImages[hp.fileExt..hp.amt]
                    --Draw hearts
                    love.graphics.draw(img,((120*GameScale)+(68*i*GameScale))+HudX,WindowHeight-(97*GameScale)-(i*5.1*GameScale)+HudY-hp.yp,(-4.289/57.19),4*GameScale,4*GameScale)
                end

                --Heart jumping randomly
                if HeartJumpCounter < FrameCounter - 0.1*i and not hp.move then
                    hp.yv = -20
                    hp.move = true
                    if i == #Health then
                        HeartJumpCounter = math.max(0.3*#Health,(love.math.random()+0.1)*12) + FrameCounter
                    end
                end

                --Heart flash at low HP
                if TotalHealth <= 2 and HeartFlashCounter<FrameCounter then
                    HeartFlashAmt = 1
                    if hp.amt == 2 then
                        HeartFlashCounter = FrameCounter + 1.5
                    elseif hp.amt == 1 then
                        HeartFlashCounter = FrameCounter + 0.5
                    end
                end

                --Draw crit HP flash
                if i == 1 and HeartFlashAmt > 0 then
                    local critimg = HpImages['crit']
                    love.graphics.setColor(1,1,1,HeartFlashAmt)
                    love.graphics.draw(critimg,((120*GameScale)+(68*i*GameScale))+HudX,WindowHeight-(97*GameScale)-(i*5.1*GameScale)+HudY-hp.yp,(-4.289/57.19),4*GameScale,4*GameScale)
                    love.graphics.setColor(1,1,1,1)
                end
            end

            --Rightside HUD Kunais
            for i=0,DKunais-1,1 do
                if i == 0 then --first kunai on the right, goes up
                    if Pl.kunaiAni >= 0 and Pl.kunaiAni <= 14 then
                        love.graphics.draw(KunaiImg,WindowWidth-(100*GameScale)-(i*38*GameScale)+Pl.kunaiAni+HudX,WindowHeight-(150*GameScale)-(i*3*GameScale)-(Pl.kunaiAni*Pl.kunaiAni+Pl.kunaiAni*GameScale)+HudY,(4.289/57.19),0.15*GameScale,0.15*GameScale)
                    elseif Pl.kunaiAni >= 39 or Pl.kunaiAni <= -1 then
                        love.graphics.draw(KunaiImg,WindowWidth-(100*GameScale)-(i*38*GameScale)+HudX,WindowHeight-(150*GameScale)-(i*3*GameScale)+HudY,(4.289/57.19),0.15*GameScale,0.15*GameScale)
                    end
                else --all other kunais slide over to the right
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
                    if 10*j+(i/(2*GameScale)) >= Pl.totalEnergy then --set color to dark gray if energy < position
                        love.graphics.setColor(0.45,0.45,0.45,1)
                        if 10*j+(i/(2*GameScale)) >= Pl.remEnergy then
                            love.graphics.setColor(0.3,0.3,0.3,1)
                        end
                    elseif Pl.totalEnergy < 30 then
                        love.graphics.setColor(1-(Pl.totalEnergy/33.3333),0.1+(Pl.totalEnergy/33.3333),0.3,1)
                    elseif Pl.energy[1] > 5 then --if the lower bar is nearly full, make the energy bar blue
                        love.graphics.setColor(0.1,1.025-(Pl.energy[1]/200),-0.25+(Pl.energy[1]/20),1)
                    else
                        love.graphics.setColor(0.1,1,0.3,1)
                    end

                    --Colored rects
                    local h = (i==1 or i==round(20*GameScale)) and 33 or 35
                    love.graphics.rectangle('fill',(238*GameScale)-(20*GameScale)-i-(22*j*GameScale),(35-h)/2,HighGraphics and 1 or 2,h*GameScale)
                end
            end
            love.graphics.setColor(1,1,1,1)
            love.graphics.setCanvas(ScreenCanvas)
            love.graphics.draw(EnergyCanvas,WindowWidth-(235*GameScale)+HudX,WindowHeight-(71.5*GameScale)+HudY,(4.289/57.19))
        end

        --Textbox & Text
        if StateVar.state == 'phonecall' then

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
            SimpleText(TextName,28,90*GameScale,WindowHeight-(380*GameScale))
            for i,v in ipairs(CurrentText) do
                SimpleText(v,32,60*GameScale,WindowHeight-(330*GameScale)+(i*GameScale*50))
            end
        end

        love.graphics.setColor(1,1,1,1)
        if love.keyboard.isDown("f9") then --Show debug blocks IDS
            local Xl,Yl = GetOnScreen()
            for i,x in ipairs(Xl) do
                for o,y in ipairs(Yl) do
                    local xt = math.floor(x/32)
                    local yt = math.floor(y/32)
                    x = x - (x%32)
                    y = y - (y%32)
                    local bl = LevelData[xt.."-"..yt]
                    local t = {0,0}
                    if LoadedTiles[bl]~= nil then
                        t = split(bl,"-")
                    end
                    SimpleText(t[1],8,(x-CameraX)*GameScale,(y-CameraY)*GameScale)
                    SimpleText(t[2],8,(x-CameraX)*GameScale,10+(y-CameraY)*GameScale)
                    SimpleText(xt.."/"..yt,8,(x-CameraX)*GameScale,20+(y-CameraY)*GameScale)

                end
            end
        end


        --debug text
        if DebugInfo then
            local stats = love.graphics.getStats()
            SimpleText("XY: "..round(Pl.xpos).." / "..round(Pl.ypos).." BL: "..math.floor(Pl.xpos/32).." / "..math.floor(Pl.ypos/32).." Ve: "..round(Pl.xv,2).." / "..round(Pl.yv,2),16,10*GameScale,40*GameScale)
            SimpleText(round(love.timer.getFPS(),1).." fps Ss: "..StepSize..(AutoStep and "A" or "").." Dr: "..WindowWidth.."x"..WindowHeight.." S: "..round(GameScale,2).." Z: "..round(Zoom,2).."/"..round(ZoomBase,2),16,10*GameScale,60*GameScale)
            SimpleText("PL: "..round(Pl.abilities['jump'],1).."/"..round(Pl.abilities['jumpext'],1).."/"..round(Pl.abilities['djump'],1).."/"..round(Pl.abilities['dive'],1).."/"..round(Pl.abilities['spinny'],2).." F: "..Pl.facing.." D: "..Pl.dFacing.." E: "..round(Pl.energy[1],1).."/"..round(Pl.energy[2],1).." RE: "..round(Pl.remEnergy,1).." O: "..Pl.onWall.." Jc: "..round(Pl.jCounter,2).." Ms: "..round(Pl.maxSpd,2),16,10*GameScale,80*GameScale)
            SimpleText("PLa: "..Pl.animation.." N: "..Pl.nextAni.." C: "..round(Pl.counter%60).." F: "..round(Pl.aniFrame,1).." T: "..round(Pl.aniTimer,1).."/"..round(Pl.aniiTimer,1),16,10*GameScale,100*GameScale)
            SimpleText("Sc: "..#Pl.se.locations.." Sh: "..SH,16,10*GameScale,120*GameScale)
            SimpleText("Dc: "..round(stats.drawcalls).." Tm: "..round(stats.texturememory/(1024*1024),1).."MB Im: "..round(stats.images)..(HighGraphics and " Fancy" or " Fast"),16,10*GameScale,140*GameScale)
            SimpleText(_VERSION.." G: "..round(collectgarbage("count")),16,10*GameScale,180*GameScale)
            SimpleText("Love "..love.getVersion().." "..love.system.getOS().. " C: "..love.system.getProcessorCount(),16,10*GameScale,200*GameScale)

            --show exact energy values
            SimpleText(round(Pl.energy[1],1),18,WindowWidth-50+HudX,WindowHeight-170+HudY)
            SimpleText(round(Pl.energy[2],1),18,WindowWidth-50+HudX,WindowHeight-150+HudY)
        end
    else
        --Non-game states
        
        --Logo
        if StateVar.genstate == 'initialload' then
            if GlAni == 0 then --Wait a small amount before showing title screen
                if FrameCounter < 0.25 then
                    love.graphics.setColor(1,1,1,FrameCounter*4)
                elseif FrameCounter < 2.75 then
                    love.graphics.setColor(1,1,1,1)
                else
                    love.graphics.setColor(1,1,1,(3.5-FrameCounter)*1.333)
                end
                love.graphics.draw(LogoImg,0,0,0,WindowWidth/1382,WindowWidth/1382)
                if FrameCounter > 3.5 or love.keyboard.isDown(KeyBinds['Jump']) then
                    TitleScreen(true)
                end
            else
                FrameCounter = 0
            end
        end

        --Title Screen Draws
        if StateVar.genstate == 'title' then
            love.graphics.push()
            love.graphics.translate(XPadding,YPadding) --center the title screen graphics
            love.graphics.setColor(1,1,1,math.min(1,FrameCounter*1.25)) --fade in

            --Title screen background moves slightly
            local perlinX = love.math.noise(FrameCounter/3)
            local perlinY = love.math.noise(FrameCounter/3+100)
            local perlinR = love.math.noise(FrameCounter/4-100)
            love.graphics.draw(TitleImgBg,(perlinX-0.5)*6,(perlinY-0.5)*6,(perlinR-0.5)/300,WindowHeight/(2160-math.min(10,FrameCounter*5)),WindowHeight/(2160-math.min(10,FrameCounter*5)))
            
            --Aria fades in from the bottom and moves around with perlin noise
            local perlinX = love.math.noise(FrameCounter/3,love.math.getRandomSeed()*1000) --only the x is randomized like this because the default y has aria going down immediately after floating up and it looks nice
            local perlinY = love.math.noise(FrameCounter/3+100)
            local perlinR = love.math.noise(FrameCounter/4-100)

            --Draw
            love.graphics.draw(TitleImgAr,(perlinX-0.5)*18,((perlinY-0.5)*36)+50*math.pow(1.5-math.min(1.5,FrameCounter),2.5),(perlinR-0.5)/20,WindowHeight/2160,WindowHeight/2160)
            love.graphics.pop()

        end

        --Load Level Draws
        if StateVar.state == 'loadlevel' then
            --Check if the level loading routine is done
            local info = love.thread.getChannel("lvlLoadRet"):pop()
            if info then
                LevelData = info[1]
                LevelWidth = info[3]
                LevelHeight = info[4]

                --Create loadedtiles list
                LoadedTiles = {}
                for a,v in pairs(info[2]) do
                    local i = love.graphics.newImage(v)
                    LoadedTiles[a] = i
                end

                --Spawn enemies
                for i,v in pairs(info[5]) do
                    local e = Enemy(v[1],v[2],v[3])
                    table.insert(Enemies,e)
                end
                
                --Spawn player
                Pl = Player(info[6][1],info[6][2]+1)
                CameraX = Pl.xpos
                CameraY = Pl.ypos

                --Change state
                StateVar.genstate = 'game'
                StateVar.state = 'play'
                StateVar.physics = 'on'
                love.resize()

                --Move player and set variables if we're loading a save
                if LoadingGame and LoadState then
                    --Set states
                    Pl.xpos = LoadState['xpos']
                    Pl.ypos = LoadState['ypos']
                    CameraX = Pl.xpos
                    CameraY = Pl.ypos
                    Pl.xv = LoadState['xv']
                    Pl.yv = LoadState['yv']
                    Health = {}
                    for i,v in pairs(LoadState['health']) do
                        table.insert(Health,Heart(v.type,v.amt))
                    end
                    Pl.energy = LoadState['energy']
                    Pl.abilities = LoadState['ab']
                    --Reset
                    LoadState = nil
                    LoadingGame = false
                end
            else
                --background if GlAni = 0
                if GlAni <= 0 then
                    love.graphics.clear(0,0,0,1)
                end

                --Show progress bar
                local progress = love.thread.getChannel('status'):pop()
                if progress then
                    love.thread.getChannel('status'):clear()
                    love.graphics.setColor(0.333,0.333,0.333,1) 
                    love.graphics.rectangle('fill',WindowWidth-475,WindowHeight-25,350,10,5,5) --bg rect
                    love.graphics.setColor(1,1,1,1) 
                    love.graphics.rectangle('fill', WindowWidth-475,WindowHeight-25,350*progress[2],10,5,5) --main rect
                    SimpleText(progress[1],20,WindowWidth-275,WindowHeight-60)
                end

                --Show aria running animation
                local frame = math.floor((FrameCounter*30)%11)+1
                local img = love.graphics.newImage("image/Aria/run"..frame..".png")
                love.graphics.draw(img,WindowWidth-120,WindowHeight-120,0,2,2)
            end
        end
    end

    --Fading Text
    if FadingText[1] > 0 then
        FadingText[1] = FadingText[1] - 1
        if FadingText[1] <= 150 then
            love.graphics.setColor(1,1,1,math.min(1,FadingText[1]/60))
            local x = TextWidth("Upwards "..BuildId,20)
            SimpleText(FadingText[2],20,(x+20)*GameScale,10*GameScale)
        end
    elseif FadingText[1] > -1 then
        FadingText[1] = -1
    end
    love.graphics.setColor(1,1,1,1)

    --Reset keys pressed (so you can't spam keys)
    if not love.keyboard.isDown("f1","f2","f3","f4","f5","f6","escape") and not love.mouse.isDown(1) then
        DebugPressed = false
    end

    --Buttons
    for i,v in pairs(Buttons) do
        v:draw()
    end

    --Reset sensors (probably remove this before 1.0 release (as well as sensor location tracking))
    if StateVar.physics ~= 'off' and StateVar.genstate == 'game' then
        for i,v in ipairs(Entities) do
            v.se:reset()
        end
        for i,v in ipairs(Enemies) do
            v.se:reset()
        end
        Pl.se:reset()
    end

    --Global Animations (down here to go on top of buttons)
    GlobalAnimate()

    --Draw BuildId
    SimpleText("Upwards "..BuildId,20,10*GameScale,10*GameScale)

    --Flip display
    love.graphics.setCanvas()
    love.graphics.draw(ScreenCanvas)
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
    Xl,Yl = GetOnScreen()
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
                if t[1] == "7" or t[1] == "8" or t[1] == "9" or t[1] == "10" or t[1] == "32" then
                    love.graphics.draw(LoadedTiles[bl],(x-CameraX)*GameScale,(y-CameraY)*GameScale,0,2*GameScale,2*GameScale)
                else
                    love.graphics.draw(LoadedTiles[bl],(x-CameraX)*GameScale,(y-CameraY)*GameScale,0,1*GameScale,1*GameScale)
                end
            end

            --Draw block text when pressing f9
            if love.keyboard.isDown("f9") and bl~= '0-0' then
                SimpleText(bl,14,16+(x-CameraX)*GameScale,16+(y-CameraY)*GameScale,'center')
            end
        end
    end

end

function RenderTwo()
    local numDTiles = 0

    --Update Dirty Tiles
    love.graphics.setCanvas(TileCanvas)
    for i,v in pairs(DirtyTiles) do
        numDTiles = numDTiles + 1
        local bl = LevelData[i]
        local x = split(i,"-")[1]
        local y = split(i,"-")[2]

        --Add new blocks
        if LoadedTiles[bl]~=nil then
            local t = split(LevelData[i],"-")
            if t[1] == "7" or t[1] == "8" or t[1] == "9" or t[1] == "10" or t[1] == "32" then
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
    love.graphics.setCanvas(ScreenCanvas)
    DirtyTiles = {}

    --Draw Background
    love.graphics.draw(TileCanvas,LevelWidth-(CameraX*GameScale)-(LevelWidth),LevelHeight-(CameraY*GameScale)-(LevelHeight),0,GameScale,GameScale)
    return numDTiles
end

function love.resize()

    --Set window width & height
    WindowWidth, WindowHeight = love.graphics.getDimensions()

    --Remake screencanvas
    ScreenCanvas = love.graphics.newCanvas(WindowWidth,WindowHeight)
    HDMACanvas = love.graphics.newCanvas(WindowWidth/4,WindowHeight/4)
    HDMATempCanvas = love.graphics.newCanvas(WindowWidth/4,WindowHeight/4)

    --From love2d wiki
    GameScale = WindowHeight/800
    XPadding = (WindowWidth - (1280*GameScale))/2
    YPadding = (WindowHeight - (800*GameScale))/2

    if StateVar.genstate == 'game' then

        --Initialize Energy bar background area
        BgRectCanvas = love.graphics.newCanvas(WindowWidth+100,WindowHeight,{msaa=4})
        love.graphics.setCanvas(BgRectCanvas)
        for i=-100,210,1 do
            local hei = math.min(40,(math.sqrt(210-i)*8.944)) --Slope down smoothly at the end of the bar
            love.graphics.rectangle('fill',WindowWidth-(50*GameScale)-i*GameScale,WindowHeight-(60*GameScale)-(i/13.333333*GameScale),1*GameScale,hei*GameScale)
        end

        --Energy bar Canvas
        EnergyCanvas = love.graphics.newCanvas(238*GameScale,35*GameScale,{msaa=4})

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
                    if t[1] == "7" or t[1] == "8" or t[1] == "9" or t[1] == "10" or t[1] == "32" then --double scale
                        love.graphics.draw(LoadedTiles[bl],x*32,y*32,0,2,2)
                    else
                        love.graphics.draw(LoadedTiles[bl],x*32,y*32,0,1,1)
                    end
                end
            end
        end
        love.graphics.setCanvas(ScreenCanvas) --reset canvas
    end
end

function love.keypressed(key, scancode, isrepeat)
    local x = split(StateVar.substate,'-') --If you're currently changing a keybind
    if x[2] == 'CS' then
        KeyBinds[x[1]] = love.keyboard.getScancodeFromKey(key)
        StateVar.state = 'controlsmenu'
    end
end

function love.wheelmoved(x,y)
    MouseWheelY = math.max(-20,math.min(20,MouseWheelY + (y or 0)))
    ZoomScroll = MouseWheelY/200
end

--!file: main.lua
--Upwards!

if arg[2] == "debug" then
    require("lldebugger").start()
end

function love.load()
    
    --Build Id
    BuildId = "l.06"

    --Imports
    Object = require "lib.classic"
    require "lib.simplestats"
    require "lib.mathExtras"
    require "lib.loadArl"
    require "lib.distFuncs"
    require "lib.drawFuncs"

    require "player"
    require "sensor"
    require "camera"
    require "kunai"
    local Heart = require "heart"
    require "lib.playerCollision"

    --Set up window & display
    WindowWidth = 1280
    WindowHeight = 800
    love.window.setMode(WindowWidth,WindowHeight, {resizable=true,vsync=true,minwidth=1280,minheight=800,msaa=2})

    --Counters
    FrameCounter = 0
    SecondsCounter = 0
    
    --scaling
    GameScale = 1
    love.graphics.setDefaultFilter("linear","nearest",4)

    --Load images
    HexImg = love.graphics.newImage("Images/UI/hex.png")
    KunaiImg = love.graphics.newImage("Images/UI/kunai.png")

    --state
    State = 'game'

    --spawn initial entities
    Pl = Player(3000,100)

    --lists
    ThrownKunai = {}
    Particles = {}
    Buttons = {}
    Health = {Heart(1,4),Heart(1,4)}

    --initial values
    Kunais = 5
    DKunais = 5
    KuAni = -1
    CameraX = 0
    CameraY = 0
    DiffCX = 0
    DiffCY = 0

    Path = love.filesystem.getWorkingDirectory()

    --load & scale images
    --kunaiImg = love.graphics.newImage("")
    loadARL('lvl1.arl',Path)


end

function love.update(dt)
    MouseX, MouseY = love.mouse.getPosition()
    normalCamera(MouseX,MouseY,dt,math.max(0,1.5*(Pl.yv-2.5)))


    --Update player physics & animation
    Pl:update(dt)

    --Update player internal collision detection (non-solid objects)
    for i=Pl.col[2]+8,Pl.col[1]-8,8 do
        for j=Pl.col[4]+8,Pl.col[3]-4,8 do
            local ret = Pl.se:detect(j,i)
            playerCollisionDetect(ret[2],ret[3],dt)
        end
    end

    --Update tiles
    tileProperties(dt)

    --Spawn Kunai
    if Pl.kunaiAni > 37 and Pl.kunaiAni < 38 then
        local tan = tanAngle(MouseX-(Pl.xpos-CameraX),MouseY-(Pl.ypos-CameraY))
        local dx = tan[1] + 0.1*love.math.random()-0.05
        local dy = tan[2] + 0.1*love.math.random()-0.05
        print(dx,dy)
        table.insert(ThrownKunai,Kunai(Pl.xpos,Pl.ypos-60,dx*30,dy*30))
        KuAni = 0
        Pl.energy = Pl.energy - 10
        Pl.kunaiAni = 36
    end

    --Update kunai
    for i,v in ipairs(ThrownKunai) do
        if v:update(dt) then
            DKunais = Kunais
            table.remove(ThrownKunai,i)
        end
    end
    if KuAni ~= -1 then
        KuAni = KuAni + (dt*60)
    end
    if KuAni >= 40 then
        KuAni = -1
        DKunais = Kunais
    end


end


function love.draw(dt)
    love.graphics.setColor(0.1,0.1,0.1,1)
    love.graphics.rectangle("fill",0,0,WindowWidth,WindowHeight)
    love.graphics.setColor(1,1,1,1)

    --Update WindowWidth & WindowHeight
    WindowWidth, WindowHeight = love.graphics.getDimensions()
    GameScale = WindowHeight/800

    --debug text & sensor
    if love.keyboard.isDown('r') then
        
        simpleText("Xpos - "..Pl.xpos,16,10,50)
        simpleText("Ypos - "..Pl.ypos,16,10,70)
        simpleText("Xv - "..Pl.xv,16,10,90)
        simpleText("Yv - "..Pl.yv,16,10,110)
        if Pl.onGround then
            simpleText("On Ground",16,10,130)
        end
        simpleText("Onwall - "..Pl.onWall,16,10,150)
        simpleText("Energy = "..Pl.energy,16,10,170)
        simpleText("Gravity = "..Pl.gravity,16,10,190)
        simpleText("JCounter = "..Pl.jCounter,16,10,210)
        simpleText("KunaiAni = "..KuAni,16,10,230)
        simpleText("Kunais = "..Kunais,16,10,250)
        simpleText("Max Speed = "..Pl.maxSpd,16,10,270)
        --draw sensors & player circle
        Pl.se:draw(true)

    end
    Pl.se:draw(false)



    --draw kunai
    for i,v in ipairs(ThrownKunai) do
        love.graphics.draw(v.baseImage,(v.xpos-CameraX)*GameScale,(v.ypos-CameraY)*GameScale,v.direction,2*GameScale,2*GameScale,0,0)
    end

    --draw player
    if type(Pl.img) ~= "string" then
        if Pl.dFacing == -1 then
            love.graphics.draw(Pl.img,(Pl.xpos-CameraX+Pl.imgPos[1])*GameScale,(Pl.ypos-CameraY+Pl.imgPos[2])*GameScale,0,-2*GameScale,2*GameScale,-Pl.imgPos[1],0)
        else
            love.graphics.draw(Pl.img,(Pl.xpos-CameraX+Pl.imgPos[1])*GameScale,(Pl.ypos-CameraY+Pl.imgPos[2])*GameScale,0,2*GameScale,2*GameScale,0,0)
        end
    end

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

            --Draw block text when pressing T
            if love.keyboard.isDown("t") and bl~= '0-0' then
                simpleText(bl,14,2+(x-CameraX)*GameScale,10+(y-CameraY)*GameScale)
            end
        end
    end

    --Draw HUD
    --Hex
    HudX = -Pl.xv*5
    HudY = -(math.min(0,Pl.yv*6))
    
    love.graphics.draw(HexImg,HudX,WindowHeight-(200*GameScale)+HudY,(-4.289/57.19),0.25*GameScale,0.25*GameScale)
    --Hearts
    for i,hp in ipairs(Health) do
        if hp.amt <= 0 and hp.type ~= 1 then
            table.remove(Health,i)
        else
            hp.img = "Images/Hearts/"..hp.fileExt..hp.amt..".png"
            local img = love.graphics.newImage(hp.img)
            love.graphics.draw(img,((120*GameScale)+(68*i*GameScale))+HudX,WindowHeight-(77*GameScale)-(i*5.1*GameScale)+HudY,(-4.289/57.19),4*GameScale,4*GameScale)
        end
        
    end

    --Rightside HUD Kunais
    for i=0,DKunais-1,1 do
        if i == 0 then
            if KuAni >= 0 and KuAni <= 14 then
                love.graphics.draw(KunaiImg,WindowWidth-(100*GameScale)-(i*38*GameScale)+KuAni+HudX,WindowHeight-(150*GameScale)-(i*3*GameScale)-(KuAni*KuAni+KuAni*GameScale)+HudY,0,0.15*GameScale,0.15*GameScale)
            elseif KuAni >= 39 or KuAni <= -1 then
                love.graphics.draw(KunaiImg,WindowWidth-(100*GameScale)-(i*38*GameScale)+HudX,WindowHeight-(150*GameScale)-(i*3*GameScale)+HudY,0,0.15*GameScale,0.15*GameScale)
            end
        else
            if KuAni >= 24 and KuAni <= 40 then
                love.graphics.draw(KunaiImg,WindowWidth-(152*GameScale)-(i*38*GameScale)+(KuAni*2.3)+HudX,WindowHeight-(154*GameScale)-(i*3*GameScale)+(KuAni/5*GameScale)+HudY,0,0.15*GameScale,0.15*GameScale)
            else
                love.graphics.draw(KunaiImg,WindowWidth-(100*GameScale)-(i*38*GameScale)+HudX,WindowHeight-(150*GameScale)-(i*3*GameScale)+HudY,0,0.15*GameScale,0.15*GameScale)
            end
        end
    end

    --Energy bar (ported from 1 line python monstrosity)
    --pg.draw.aaline(HUD,(60,60,60) if 10*j+(i/2)>=pl.energy else (220-(pl.energy*6),40+(pl.energy*6),40) if pl.energy<30 else (40,300-pl.energy,-400+(pl.energy*6)) if pl.energy>80 else (40,220,40), (WID-20-i-(22*j)+int(energyFade),HEI-55-(j*1.666)-(i/13.333)+int(energyFade/12)+(1 if i==0 or i==19 else 0)),(WID-20-i-(22*j)+int(energyFade),HEI-20-(j*1.666)-(i/13.333)+int(energyFade/12)-(1 if i==0 or i==19 else 0)))
    for j=0, 9, 1 do 
        for i=1, 20, 1 do
            if 10*j+(i/2) >= Pl.energy then
                love.graphics.setColor(0.3,0.3,0.3,1)
            elseif Pl.energy < 30 then
                love.graphics.setColor(1-(Pl.energy/33.3333),0.1+(Pl.energy/33.3333),0.3,1)
            elseif Pl.energy > 80 then
                love.graphics.setColor(0.1,1.4-(Pl.energy/200),-2.36+(Pl.energy/30),1)
            else
                love.graphics.setColor(0.1,1,0.3,1)
            end
            if i == 1 or i == 20 then
                love.graphics.line(WindowWidth-(20*GameScale)-i*GameScale-(22*j*GameScale)+HudX,WindowHeight-(54*GameScale)-(j*1.66666*GameScale)-(i/13.333333*GameScale)+HudY,WindowWidth-(20*GameScale)-i*GameScale-(22*j*GameScale)+HudX,WindowHeight-(21*GameScale)-(j*1.66666*GameScale)-(i/13.33333*GameScale)+HudY)
            else
                love.graphics.line(WindowWidth-(20*GameScale)-i*GameScale-(22*j*GameScale)+HudX,WindowHeight-(55*GameScale)-(j*1.66666*GameScale)-(i/13.333333*GameScale)+HudY,WindowWidth-(20*GameScale)-i*GameScale-(22*j*GameScale)+HudX,WindowHeight-(20*GameScale)-(j*1.66666*GameScale)-(i/13.33333*GameScale)+HudY)
            end
            love.graphics.setColor(1,1,1,1)
        end
    end

    --Draw BuildId
    simpleText("Upwards "..BuildId,20,5,10)
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
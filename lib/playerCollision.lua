--!file: playerCollision.lua
--Checks for non-solid collision and does various actions

require "lib.extraFunc"

function PlColDetect(tile,pB,dt) --pB formatted as "0-0, 1-0" etc.
    local blF = split(tile,"-")
    local blMain = tonumber(blF[1])
    local blSub = tonumber(blF[2])

    --dash crystal
    if blMain == 4 and blSub < 3 then
        Pl.abilities[3] = 4
        Pl.abilities[4] = 2
        Pl.abilities[5] = 2
        local totEnergy = 10 + (Pl.remEnergy-Pl.totalEnergy)/2
        Pl.energy[1] = Pl.energy[1] + 0.25*totEnergy
        Pl.energy[2] = Pl.energy[2] + 0.75*totEnergy
        DirtyTiles[pB] = true
        LevelData[pB] = "6-4"
    end

    --Force Crash
    if blMain == 5 and blSub == 1 then
        error("Forced Crash via 5-1 Tile")
    end

    --Blue Heart
    if blMain == 7 and blSub <= 4 then
        if blSub == 0 then
            table.insert(Health,Heart(2,4))
        else
            table.insert(Health,Heart(2,blSub))
        end
        LevelData[pB] = "0-0"
        DirtyTiles[pB] = true
        HeartJumpCounter = -1000 --Jump hearts
    end

    --Silver Heart
    if blMain == 8 and blSub <= 2 then
        if blSub == 0 then
            table.insert(Health,Heart(3,2))
        else
            table.insert(Health,Heart(3,blSub))
        end
        LevelData[pB] = "0-0"
        DirtyTiles[pB] = true
        HeartJumpCounter = -1000 --Jump hearts
    end

    --Red Heart
    if blMain == 9 and blSub <= 4 then
        --Heal
        local healAmt = blSub
        for i=1,#Health,1 do
            healAmt = Health[i]:heal(healAmt)
        end
        HeartJumpCounter = -1000 --Jump hearts
    end

    --Blood Heart
    if blMain == 10 and blSub == 1 then
        table.insert(Health,Heart(4,1))
        HeartJumpCounter = -1000 --Jump hearts
    end

    --Phone Call
    if blMain == 11 then
        NextCall = 0-blSub
        TriggerPhone = true
        LevelData[pB] = "2-"..blSub
        DirtyTiles[pB] = true
    end

    --Camera Control
    if blMain == 13 then
        ZoomBase = (blSub/510)+0.5
    end

    --Springs
    if blMain == 32 then
        Pl.animation = 'jump'
        Pl.nextAni = 'high'
        if blSub == 1 then --straight up
            Pl.xv = Pl.xv * 0.75
            Pl.yv = (0.1*Pl.yv) - 4
        end
        if blSub == 2 then --to the right
            Pl.xv = (0.1*Pl.xv) + 3.5
            Pl.yv = (0.75*Pl.yv) - 0.5
        end
        if blSub == 3 then --to the left
            Pl.xv = (0.1*Pl.xv) - 3.5
            Pl.yv = (0.75*Pl.yv) - 0.5
        end
    end
end

--Update on-screen tiles
function TileProp(dt)
    UpdateTime = UpdateTime + dt
    if UpdateTime < 0.05 then return end
    
    --If it's time to update
    UpdateTime = 0
    local Xl,Yl = getOnScreen()
    --Update 10 on-screen tiles and 2 random tiles per 1/20 second
    for i=1,12,1 do

        --pick 1 block
        local x = 0
        local y = 0
        if i <= 10 then
            x = love.math.random(Xl[1],Xl[#Xl])
            y = love.math.random(Yl[1],Yl[#Yl])
        else
            x = love.math.random(0,LevelWidth/32)*32
            y = love.math.random(0,LevelHeight/32)*32
        end
        local xt = math.floor(x/32)
        local yt = math.floor(y/32)
        x = x - (x%32)
        y = y - (y%32)
        local bl = LevelData[xt.."-"..yt]
        local blFull = split(bl,"-")
        local blMain = blFull[1]
        local blSub = tonumber(blFull[2])

        --Properties

        --Reset dash crystal
        if blMain == "6" then
            TileUpdates = TileUpdates + 1
            LevelData[xt.."-"..yt] = "4-0"
            DirtyTiles[xt.."-"..yt] = true
        end

        --Enemy Generators
        if blMain == "19" then
            TileUpdates = TileUpdates + 1
            local e = Enemy(xt*32,yt*32,blSub+1)
            table.insert(Enemies,e)
        end
    end
end
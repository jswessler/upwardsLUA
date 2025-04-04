--!file: playerCollision.lua
--Checks for non-solid collision and does various actions

require "lib.extraFunc"

function playerCollisionDetect(tile,pB,dt) --pB formatted as "0-0, 1-0" etc.
    local blF = split(tile,"-")
    local blMain = tonumber(blF[1])
    local blSub = tonumber(blF[2])

    --dash crystal
    if blMain == 4 and blSub < 3 then
        Pl.abilities[3] = 4
        Pl.abilities[4] = 2
        Pl.abilities[5] = 2
        Pl.energy = Pl.energy + 5 + (100-Pl.energy)/3.333333
        DirtyTiles[pB] = true
        LevelData[pB] = "6-4"

        --Heal
        local healAmt = 1
        for i=1,#Health,1 do
            healAmt = Health[i]:heal(healAmt)
        end
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
    end

    --Red Heart
    if blMain == 9 and blSub <= 4 then
        --Heal
        local healAmt = blSub
        for i=1,#Health,1 do
            healAmt = Health[i]:heal(healAmt)
        end
    end

    --Blood Heart
    if blMain == 10 and blSub == 1 then
        table.insert(Health,Heart(4,1))
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
end


--Update on-screen tiles
function tileProperties(dt)
    local Xl,Yl = getOnScreen()
    for i=1,6,1 do

        --pick 1 block
        local x = love.math.random(Xl[1],Xl[#Xl])
        local y = love.math.random(Yl[1],Yl[#Yl])
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
    end
end
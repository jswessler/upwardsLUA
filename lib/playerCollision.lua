--!file: playerCollision.lua
--Checks for non-solid collision and does various actions

require "lib.distFuncs"
require "lib.mathExtras"

function playerCollisionDetect(tile,pB,dt) --block formatted as "0-0, 1-0" etc.
    local blF = split(tile,"-")
    local blM = tonumber(blF[1])
    local blS = tonumber(blF[2])

    --dash crystal
    if blM == 4 and blS < 3 then
        Pl.abilities[3] = 4
        Pl.abilities[4] = 2
        Pl.abilities[5] = 2
        Pl.energy = 100
        LevelData[pB] = "6-4"

        --Heal
        local healAmt = 1
        for i=1,#Health,1 do
            healAmt = Health[i]:heal(healAmt)
        end
    end

    --Force Crash
    if blM == 5 and blS == 1 then
        error("Forced Crash via 5-1 Tile")
    end

    --Blue Heart
    if blM == 7 and blS <= 4 then
        if blS == 0 then
            table.insert(Health,Heart(2,4))
        else
            table.insert(Health,Heart(2,blS))
        end
        LevelData[pB] = "0-0"
    end

    --Silver Heart
    if blM == 8 and blS <= 2 then
        if blS == 0 then
            table.insert(Health,Heart(3,2))
        else
            table.insert(Health,Heart(3,blS))
        end
        LevelData[pB] = "0-0"
    end

    --Red Heart
    if blM == 9 and blS <= 4 then
        --Heal
        local healAmt = blS
        for i=1,#Health,1 do
            healAmt = Health[i]:heal(healAmt)
        end
    end

    --Blood Heart
    if blM == 10 and blS == 1 then
        table.insert(Health,Heart(4,1))
    end
end


--Update on-screen tiles
function tileProperties(dt)
    local Xl,Yl = getOnScreen()
    for i,x in ipairs(Xl) do
        for o,y in ipairs(Yl) do

            --pick 1 block
            local xt = math.floor(x/32)
            local yt = math.floor(y/32)
            x = x - (x%32)
            y = y - (y%32)
            local bl = LevelData[xt.."-"..yt]
            local blF = split(bl,"-")
            local blM = blF[1]
            local blS = tonumber(blF[2])

            --Properties

            --Reset dash crystal
            if blM == "6" then
                TileUpdates = TileUpdates + 1
                if blS and math.floor(blS) > 0 then
                    LevelData[xt.."-"..yt] = "6-"..blS-dt
                else
                    LevelData[xt.."-"..yt] = "4-0"
                end
            end
        end
    end
end
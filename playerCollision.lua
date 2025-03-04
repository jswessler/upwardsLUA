--!file: playerCollision.lua
--Checks for non-solid collision and does various actions

require "lib.distFuncs"
require "lib.mathExtras"

function playerCollisionDetect(tile,pB,dt) --block formatted as "0-0, 1-0" etc.
    --dash crystal
    if tile == "4-0" or tile == "4-1" or tile == "4-2" then
        Pl.abilities[3] = 4
        Pl.abilities[4] = 2
        Pl.abilities[5] = 2
        Pl.energy = 100
        LevelData[pB] = "6-4"
    end

    --Force Crash
    if tile == '5-1' then
        error("Forced Crash via 5-1 Tile")
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
                if math.floor(blS) > 0 then
                    LevelData[xt.."-"..yt] = "6-"..blS-dt
                else
                    LevelData[xt.."-"..yt] = "4-0"
                end
            end

        end
    end

end
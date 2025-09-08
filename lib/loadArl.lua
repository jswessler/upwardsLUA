--!file: loadArl.lua
--loads ARL files (level files)

require "lib.extraFunc"
require "love.filesystem"

function LoadARL(filename)
    love.thread.getChannel('status'):clear()
    local lvlData = {}
    local ldTiles = {}
    local enemies = {} -- Holds temp enemy data for making objects in the main loop
    local sp = {} --Holds onto player spawnpoint
    local progress = {}

    local contents, size = love.filesystem.read("/Levels/"..filename)
    local counter = 1
    local cou = 1
    local lvlWid = 10
    local lvlHei = 10
    local byte = 0
    while cou<size-6 do
        progress = {"Reading Level Header",cou/64}
        love.thread.getChannel('status'):push(progress)
        byte = string.byte(contents,cou,cou)
        if counter == 5 then
            lvlWid = lvlWid + (byte*256)
        end
        if counter == 6 then
            lvlWid = lvlWid + byte
        end
        if counter == 7 then
            lvlHei = lvlHei + (byte*256)
        end
        if counter == 8 then
            lvlHei = lvlHei + byte
        end
        if counter == 9 then
            lvlWid = lvlWid - 10
            lvlHei = lvlHei - 10
        end
        if counter > 64 then --level data
            progress = {"Reading Level Data",cou/size}
            love.thread.getChannel('status'):push(progress)

            --get positions
            local x = ((counter-65)%lvlWid)
            local y = math.floor((counter-65)/lvlWid)

            --if block = 0, then skip ahead RLE bytes
            if byte == 0 then
                cou = cou + 1
                byte = string.byte(contents,cou,cou)
                for i = 0, byte-2, 1 do
                    lvlData[x.."-"..y] = "0-0"
                    counter = counter + 1
                    x = (counter-64)%lvlWid
                    y = math.floor((counter-64)/lvlWid)
                end
            
            --else, add the block to the list
            else
                cou = cou + 1
                local byte2 = string.byte(contents,cou,cou)
                lvlData[x.."-"..y] = byte.."-"..byte2

                --Spawnpoint
                if byte == 5 and byte2 == 0 then
                    sp = {x*32,y*32}
                end

                --Create enemy
                if byte == 16 or byte == 17 or byte == 18 then
                    table.insert(enemies,{x*32,y*32,(byte-16)*256+byte2+1}) --x, y, type
                end
            end
        else
            status = 'Loading ARL Header'
        end
        counter = counter + 1
        cou = cou + 1
    end
    lvlData["0-0"] = "0-0"


    --Insert tile images into the level
    local c = 0
    for i=1,2,1 do
        for i,v in pairs(lvlData) do
            c = c + 1
            if c%5 == 0 then
                progress = {"Loading Tiles",c/(2*counter)}
                love.thread.getChannel('status'):push(progress)
            end
            local file = "Images/Tiles/"..v..".png"
            if file ~= nil then
                local f = io.open(file,'r')
                if f ~= nil then
                    if ldTiles[v]~=nil then
                    else
                        local i = "Images/Tiles/"..v..".png"
                        ldTiles[v] = i
                    end
                end
            end
        end
    end
    love.thread.getChannel('lvlLoadRet'):push({lvlData, ldTiles,lvlWid,lvlHei,enemies,sp}) --return all values, this also signals that the routine is done!
    --return lvlData, ldTiles, lvlWid, lvlHei

end

LoadARL(...)
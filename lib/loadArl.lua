--!file: loadArl.lua
--loads ARL files (level files)

require "lib.extraFunc"
require "entity.enemy"

function loadARL(filename)
    local amt = 0
    local status = ''
    local StatusCH = love.thread.getChannel("status")
    local AmtCH = love.thread.getChannel("amt")
    local contents, size = love.filesystem.read("/Levels/"..filename)
    LoadedTiles = {}
    local counter = 1
    local cou = 1
    local blocks = {}
    LevelWidth = 10
    LevelHeight = 10
    local byte = 0
    while cou<size-6 do
        amt = cou/size
        AmtCH:push(amt)
        StatusCH:push(status)
        byte = string.byte(contents,cou,cou)
        if counter == 5 then
            LevelWidth = LevelWidth + (byte*256)
        end
        if counter == 6 then
            LevelWidth = LevelWidth + byte
        end
        if counter == 7 then
            LevelHeight = LevelHeight + (byte*256)
        end
        if counter == 8 then
            LevelHeight = LevelHeight + byte
        end
        if counter == 9 then
            LevelWidth = LevelWidth - 10
            LevelHeight = LevelHeight - 10
            LevelData = {}
            --LevelSubData = createList(LevelWidth*LevelHeight,0)
        end
        if counter > 64 then --level data
            status = 'Loading Level Data'
            --get positions
            local x = ((counter-65)%LevelWidth)
            local y = math.floor((counter-65)/LevelWidth)
            --if block = 0, then skip ahead RLE bytes
            if byte == 0 then
                cou = cou + 1
                byte = string.byte(contents,cou,cou)
                for i = 0, byte-2, 1 do
                    LevelData[x.."-"..y] = "0-0"
                    counter = counter + 1
                    x = (counter-64)%LevelWidth
                    y = math.floor((counter-64)/LevelWidth)
                end
            
            --else, add the block to the list
            else
                cou = cou + 1
                local byte2 = string.byte(contents,cou,cou)
                LevelData[x.."-"..y] = byte.."-"..byte2

                --Spawnpoint
                if byte == 5 and byte2 == 0 then
                    SpawnPoint = {x*32,y*32}
                end

                --Create enemy
                if byte == 16 or byte == 17 or byte == 18 then
                    local e = Enemy(x*32,y*32,(byte-16)*256+byte2+1)
                    table.insert(Enemies,e)
                end
            end
        else
            status = 'Loading ARL Header'
        end
        counter = counter + 1
        cou = cou + 1
    end
    LevelData["0-0"] = "0-0"

    amt = 0
    status = 'Inserting Tiles'

    --Insert tile images into the level
    for i=1,8,1 do
        for i,v in pairs(LevelData) do
            -- AmtCH:push(amt)
            -- StatusCH:push(status)
            local file = "Images/Tiles/"..v..".png"
            if file ~= nil then
                local f = io.open(file,'r')
                if f ~= nil then
                    if LoadedTiles[v]~=nil then
                    else
                        local i = love.graphics.newImage("Images/Tiles/"..v..".png")
                        LoadedTiles[v] = i
                    end
                end
            end
        end
    end
end
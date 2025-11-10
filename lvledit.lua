--!file: lvledit.lua
-- Port of the PyGame-based level editor into lua, runs inline instead of seperately

function EditorUpdate(dt) --called during love.update()
    --Variables
    --Control speed
    local speed = 256*dt   
    if love.keyboard.isDown("lshift") then
        speed = 1280*dt
    end

    --Move the camera
    if love.keyboard.isDown('right') then
        CameraX = CameraX + speed
    end
    if love.keyboard.isDown('left') then
        CameraX = CameraX - speed
    end
    if love.keyboard.isDown('down') then
        CameraY = CameraY + speed
    end
    if love.keyboard.isDown('up') then
        CameraY = CameraY - speed
    end
end



function SaveARL(list,dest)
    local bitO = {}
    local ls = {}
    local ls2 = {}
    local lenlist = 0

    for x=0,LevelWidth do
        for y=0,LevelWidth do
            local t = split(list[x.."-"..y])
            table.insert(ls, t[1])
            table.insert(ls2, t[2])
            lenlist = lenlist + 1
        end
    end

    -- Header bytes ("ARL" + "j")
    table.insert(bitO, 0x41) -- A
    table.insert(bitO, 0x52) -- R
    table.insert(bitO, 0x4C) -- L
    table.insert(bitO, 0x6A) -- j

    -- Width (2 bytes: high, low)
    table.insert(bitO, math.floor(LevelWidth / 256))
    table.insert(bitO, LevelWidth % 256)

    -- Height (2 bytes: high, low)
    table.insert(bitO, math.floor(LevelHeight / 256))
    table.insert(bitO, LevelHeight % 256)

    -- Level number
    table.insert(bitO, 1)

    -- Build ID bytes
    for i = 1, #BuildId do
        local byte = string.byte(BuildId, i)
        table.insert(bitO, byte)
    end

    -- Pad to 64 bytes
    while #bitO < 64 do
        table.insert(bitO, 0x00)
    end

    -- Main encoding loop
    local counter = 1
    local run = 0
    local l = lenlist

    while true do
        if counter > l+1 then 
            break 
        end
        local cur = tonumber(ls[counter]) or 0
        local cur2 = tonumber(ls2[counter] or 0)

        if cur == 0 then
            run = run + 1
        end

        if run > 0 and (run > 254 or cur ~= 0) then
            table.insert(bitO, 0x00)
            table.insert(bitO, run)
            run = 0
        end

        if cur ~= 0 and run == 0 then
            table.insert(bitO, cur)
            table.insert(bitO, cur2)
        end

        counter = counter + 1
    end

    -- End with 4 bytes of 0
    for i = 1, 4 do
        table.insert(bitO, 0x00)
    end

    -- Checksum
    local c = 0
    for i = 1, #ls do
        c = c + ls[i] + ls2[i] + 1
    end

    table.insert(bitO, math.floor(c / 256) % 256)
    table.insert(bitO, c % 256)

    -- Write to binary file
    local filename = "level/" .. tostring(dest)
    local f = assert(io.open(filename, "wb"))

    for i = 1, #bitO do
        f:write(string.char(bitO[i]))
    end

    f:close()

end
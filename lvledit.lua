--!file: lvledit.lua
-- Port of the PyGame-based level editor into lua, runs inline instead of seperately

lvlWid = 100
lvlHei = 100
lvlNum = 2
saveTo = 'lvl1.arl'

function EditorUpdate(dt) --called during love.update()
    --Variables
    --Control speed
    local speed = 300*dt   
    if love.keyboard.isDown("lshift") then
        speed = 1024*dt
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

function EditorDraw() --called during love.draw()
    if EditorEnable then
        RenderOne() --more compatible renderer
        
        --File handling
        if love.keyboard.isDown('s') then
            SaveARL(level, levelSub, saveTo)
            love.graphics.setColor(0,1,0.4,1)
            love.graphics.circle('fill',20,20,20)
            love.graphics.setColor(1,1,1,1)
        end
    end
end



function SaveARL(ls,ls2,dest)
    local bitO = {}

    -- Header bytes ("ARL" + "j")
    table.insert(bitO, 0x41) -- A
    table.insert(bitO, 0x52) -- R
    table.insert(bitO, 0x4C) -- L
    table.insert(bitO, 0x6A) -- j

    -- Width (2 bytes: high, low)
    table.insert(bitO, math.floor(lvlWid / 256))
    table.insert(bitO, lvlWid % 256)

    -- Height (2 bytes: high, low)
    table.insert(bitO, math.floor(lvlHei / 256))
    table.insert(bitO, lvlHei % 256)

    -- Level number
    table.insert(bitO, lvlNum)

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
    local l = #ls

    while true do
        if counter > l then break end
        local cur = ls[counter]
        local cur2 = ls2[counter]

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
    local filename = path .. "/Levels/" .. tostring(dest)
    local f = assert(io.open(filename, "wb"))

    for i = 1, #bitO do
        f:write(string.char(bitO[i]))
    end

    f:close()

end
--!file: jlidecode.lua
--Decodes JLI image data to png

function ind(rgb)
    return (rgb[1]*5+rgb[2]*7+rgb[3]*11)%31
end

function getInd(indx,rgb)
    table.remove(indx,ind(rgb))
    table.insert(indx,ind(rgb),rgb)
end

function jliDecode(filepath)
    local bites, size = love.filesystem.read(filepath)
    local bitR = {}
    local width = 10
    local height = 10
    local byteCounter = 0
    local totalPix = 1000
    local cPix = {0,0,0}
    local byte = 0
    local mult = 0

    local index2 = {}
    for i=1,64,1 do
        index2[i] = {0,0,0}
    end

    local cmdRem = {}
    for i=1,31,1 do
        cmdRem[i] = {-1,-1}
    end

    while true do
        byte = bites[byteCounter]
        if byteCounter == 4 then
            width = width + byte*65536
        end
        if byteCounter == 5 then
            width = width + byte*256
        end
        if byteCounter == 6 then
            width = width + byte
        end
        if byteCounter == 7 then
            height = height + byte*65536
        end
        if byteCounter == 8 then
            height = height + byte*256
        end
        if byteCounter == 9 then
            height = height + byte
            width = width - 10
            height = height - 10
            totalPix = width * height
        end
        if byteCounter == 11 then
            cPix = {bites[byteCounter],bites[byteCounter+1],bites[byteCounter+2]}
            table.insert(bitR,cPix)
            break
        end
        byteCounter = byteCounter + 1
    end

    local run = 0
    local proc = true
    byteCounter = 13
    for i=-1,totalPix+1,1 do
        table.insert(bitR,cPix)
        proc = true

        --decoder
        if run > 0 then
            run = run - 1
            proc = false
        end

        byteCounter = byteCounter + 1
        byte = bites[byteCounter]
        if byte == nil then
            proc = false
        end

        --Long code
        if byte < 64 then
            if byte >= 32 then --hi mode
                if byte >= 48 then
                    mult = 2 * ((byte-32)*2) - 8
                else
                    mult = 2 * ((byte-32)*1) - 24
                end
            end
        end


    end










end
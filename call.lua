--!file: call.lua
--handles phone calls

--variables
local txt = {}
local waitCounter = 0
local charCounter = 1
local line = -1
local textName = ''
local currentText = {'','',''}
local fullTextBox = false

function handlePhone(num,dt)
    state = 'phonecall'
    local boxRect = {x = 50, y = WindowHeight-300, w = TBoxWidth, h = 250}
    local nameRect = {x = 50, y = WindowHeight-400, w = math.min(150,TBoxWidth), h = 75}
    
    --exterior
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("fill", boxRect.x-5, boxRect.y-5, boxRect.w+10, boxRect.h+10, 30,30)
    love.graphics.rectangle("fill", nameRect.x-5, nameRect.y-5, nameRect.w+10, nameRect.h+10, 30,30)
    
    --interior
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("fill", boxRect.x, boxRect.y, boxRect.w, boxRect.h, 25,25)
    love.graphics.rectangle("fill", nameRect.x, nameRect.y, nameRect.w, nameRect.h, 25,25)
    love.graphics.setColor(1,1,1,1)





    --Expand text box
    if TBoxWidth < WindowWidth-100 then
        if fullTextBox then
            TBoxWidth = WindowWidth-100
        else
            TBoxWidth = TBoxWidth + (1500*dt)
        end
    else
        fullTextBox = true
        TBoxWidth = WindowWidth-100
        if #txt == 0 then
            local t, size = love.filesystem.read("/Phone Calls/"..num..".txt")
            for i=1,#t,1 do
                table.insert(txt,t:sub(i,i))
            end
        end
        if waitCounter <= 0 then

            --Reset waitCounter
            if love.keyboard.isDown('x') or love.keyboard.isDown('tab') then
                waitCounter = 0.01
            else
                waitCounter = 0.04
            end

            --Draw text
            if charCounter < #txt then
                local i = txt[charCounter] --Important, apparently
                if line == -1 then
                    textName = textName..i
                    if i == "\n" then
                        line = 0
                    end
                    charCounter = charCounter + 1
                else
                    if i ~= "\\" then
                        print(i)
                        currentText[line+1] = currentText[line+1]..i
                        charCounter = charCounter + 1

                    --escape codes
                    else
                        j = txt[charCounter+1]
                        if j == '.' then
                            waitCounter = 0.25
                            charCounter = charCounter + 2
                        elseif j == ',' then
                            waitCounter = 0.5
                            charCounter = charCounter + 2
                        elseif j == '|' then
                            waitCounter = 1
                            charCounter = charCounter + 2
                        elseif j == 't' then
                            line = line + 1
                            charCounter = charCounter + 2
                        elseif j == 'n' then
                            if love.keyboard.isDown('return') or love.keyboard.isDown('z') then
                                currentText = {'','',''}
                                line = -1
                                charCounter = charCounter + 2
                            end
                        end
                    end
                end

            --Finish up
            else                           
                if love.keyboard.isDown('return') or love.keyboard.isDown('z') then
                    currentText = {'','',''}
                    fullTextBox = false
                    txt = {}
                    NextCall = 0
                    TBoxWidth = 0
                    state = 'game'
                end
            end
        --Wait
        else
            waitCounter = waitCounter - dt
        end
    end

    --Text
    simpleText(textName,28*GameScale,90,WindowHeight-380*GameScale)
    for i,v in ipairs(currentText) do
        simpleText(v,32*GameScale,60,WindowHeight-330+(i*50))
    end

end

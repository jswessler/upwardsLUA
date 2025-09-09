--!file: call.lua
--handles phone calls

--variables
local txt = {}
local waitCounter = 0
local charCounter = 1
local line = -1
local fullTextBox = false

function handlePhone(num,dt)
    StateVar.state = 'phonecall'

    --Text rectangle sizes
    BoxRect = {x = 50*GameScale, y = WindowHeight-(300*GameScale), w = TBoxWidth, h = (250*GameScale)}
    NameRect = {x = 50*GameScale, y = WindowHeight-(400*GameScale), w = math.min(150*GameScale,TBoxWidth*GameScale), h = (75*GameScale)}

    --Expand text box
    if TBoxWidth < WindowWidth-100 then

        --Fix for resizing window with text box open
        if fullTextBox then
            TBoxWidth = WindowWidth-100

        --Otherwise expand textbox slowly
        else
            TBoxWidth = TBoxWidth + (4000*dt)
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
                waitCounter = 0
            else
                waitCounter = 0.0001
            end

            --Draw text
            if charCounter < #txt then
                local i = txt[charCounter] --Important, apparently
                if line == -1 then
                    TextName = TextName..i
                    if i == "\n" then
                        line = 0
                    end
                    charCounter = charCounter + 1
                else
                    if i ~= "\\" then
                        CurrentText[line+1] = CurrentText[line+1]..i
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
                                CurrentText = {'','',''}
                                line = -1
                                charCounter = charCounter + 2
                            end
                        end
                    end
                end

            --Finish up
            else                           
                if love.keyboard.isDown('return') or love.keyboard.isDown('z') then
                    CurrentText = {'','',''}
                    fullTextBox = false
                    txt = {}
                    BoxRect = ''
                    NameRect = ''
                    NextCall = 0
                    TBoxWidth = 0
                    StateVar.state = 'play'
                end
            end
        --Wait
        else
            waitCounter = waitCounter - dt
        end
    end

end

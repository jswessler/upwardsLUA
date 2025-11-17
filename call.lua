--!file: call.lua
--handles phone calls

--variables
local txt = {}
local waitCounter = 0
local charCounter = 1
local line = -1
local fullTextBox = false

function CallInit(call) --called when you first pick up a call
    TriggerPhone = false
    NextCall = 0-call
    StateVar.state = 'phonecall'
    --load entire call into memory
    local t, size = love.filesystem.read("/phone/"..NextCall..".txt")
    for i=1,#t,1 do
        table.insert(PhoneText,t:sub(i,i))
    end
    BoxRect = {x = 50*GameScale, y = WindowHeight-(300*GameScale), w = TBoxWidth, h = (250*GameScale)}
    NameRect = {x = 50*GameScale, y = WindowHeight-(400*GameScale), w = math.min(150*GameScale,TBoxWidth*GameScale), h = (75*GameScale)}
    TextStats = {line=0,char=0,tot=0,imgn='',img=nil,wait=0,name=''}
end

function CallUpdate(dt)
    --Text rectangle sizes
    BoxRect = {x = 50*GameScale, y = WindowHeight-(300*GameScale), w = TBoxWidth, h = (250*GameScale)}
    NameRect = {x = 50*GameScale, y = WindowHeight-(400*GameScale), w = math.min(150*GameScale,TBoxWidth*GameScale), h = (75*GameScale)}

    --Expand text box
    --Expand text box
    if TBoxWidth < WindowWidth-100 then

        --Fix for resizing window with text box open
        if fullTextBox then
            TBoxWidth = WindowWidth-100
        --Otherwise expand textbox gradually
        else
            TBoxWidth = TBoxWidth + (6000*dt)
        end
    else --when the text box is fully expanded
        TBoxWidth = WindowWidth - 100 --updated every frame in case the window width changes
        if TextStats.wait <= 0 then
            --Reset waitCounter
            if love.keyboard.isDown('x') or love.keyboard.isDown('tab') then
                TextStats.wait = 0 --wait 0 frames
            else
                TextStats.wait = dt --wait 1 frame
            end
            TextStats.wait = TextStats.wait - dt --reduce wait timer
            TextStats.tot = TextStats.tot + 1

            --Draw text
            if TextStats.tot < #PhoneText then
                local i = PhoneText[charCounter]
            end

            --Get text name
            if TextStats.char == 0 and TextStats.line == 0 then
                while true do
                    local i = PhoneText[TextStats.char]
                    if i == '\n' then
                        TextStats.line = 1
                        break
                    else
                        TextName = TextName..i
                    end
                    TextStats.char = TextStats.char + 1
                end

            --Get image
            elseif TextStats.char == 0 then
                while true do
                    local i = PhoneText[TextStats.char]
                    if i == '\\' then
                        break
                    else
                        TextStats.imgn = TextStats.imgn .. i
                    end
                    TextStats.char = TextStats.char + 1
                end
                TextStats.img = love.graphics.newImage("/image/Portrait/Z"..TextStats.name.."_"..TextStats.imgn..".png")
                --If there isn't a portrait, slide on screen. If there is, jump it.
            
            else --write each character of text
                local i = PhoneText[TextStats.char]
                if i ~= "\\" then --normal text
                    CurrentText[TextStats.line] = CurrentText[TextStats.line]..i
                    TextStats.char = TextStats.char + 1

                else --slash codes
                    local j = PhoneText[TextStats.char+1]
                    if j == '.' then
                        TextStats.wait = 0.25
                        TextStats.char = TextStats.char + 2
                    elseif j == ',' then
                        TextStats.wait = 0.5
                        TextStats.char = TextStats.char + 2
                    elseif j == "|" then
                        TextStats.wait = 1
                        TextStats.char = TextStats.char + 2
                    elseif j == 't' then
                        TextStats.line = TextStats.line + 1
                        TextStats.char = TextStats.char + 2
                    elseif j == 'n' then
                        if love.keyboard.isDown('return') or love.keyboard.isDown('z') then
                            CurrentText = {'','',''}
                            TextStats.line = 0
                            TextStats.char = TextStats.char + 2
                        end
                    end
                end
            end
        end
    end

end


function CallUpdateOld(dt)
    --Text rectangle sizes
    BoxRect = {x = 50*GameScale, y = WindowHeight-(300*GameScale), w = TBoxWidth, h = (250*GameScale)}
    NameRect = {x = 50*GameScale, y = WindowHeight-(400*GameScale), w = math.min(150*GameScale,TBoxWidth*GameScale), h = (75*GameScale)}

    --Expand text box
    if TBoxWidth < WindowWidth-100 then

        --Fix for resizing window with text box open
        if fullTextBox then
            TBoxWidth = WindowWidth-100
        --Otherwise expand textbox gradually
        else
            TBoxWidth = TBoxWidth + (6000*dt)
        end
    else
        fullTextBox = true
        TBoxWidth = WindowWidth-100
        if waitCounter <= 0 then
            --Reset waitCounter
            if love.keyboard.isDown('x') or love.keyboard.isDown('tab') then
                waitCounter = 0 --wait 0 frames
            else
                waitCounter = dt --wait 1 frame
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

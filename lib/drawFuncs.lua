--!file: drawFuncs.lua
--handles text and other drawables

local cachedFontSize = nil
local cachedFontObject = nil

function simpleText(text,textSize,x,y)
    if cachedFontSize ~= textSize then
        cachedFontObject = love.graphics.newFont("lib/Mikofont-Regular.ttf",textSize*1.5,'normal')
        cachedFontSize = textSize
    end
    local textObject = love.graphics.newText(cachedFontObject,text)
    local textWid = textObject:getWidth()
    love.graphics.draw(textObject,x,y,0)
end

function imgPos(img,fac)

end



--!file: drawFuncs.lua
--handles text and other drawables

function simpleText(text,textSize,x,y)
    local fontObject = love.graphics.newFont(textSize,"mono")
    local textObject = love.graphics.newText(fontObject,text)
    local textWid = textObject:getWidth()
    love.graphics.draw(textObject,x,y,0)
end

function imgPos(img,fac)

end


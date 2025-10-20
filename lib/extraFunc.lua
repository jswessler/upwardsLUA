--!file: extraFunc.lua
--extra stuff

function GetOnScreen() --get min and max x and y that's on screen
    local xs = math.max(0, math.floor(CameraX-24))
    local xf = math.min(math.floor(LevelWidth*32*GameScale), math.floor(CameraX + WindowWidth + 24))
    local ys = math.max(0, math.floor(CameraY-24))
    local yf = math.min(math.floor(LevelWidth*32*GameScale), math.floor(CameraY + WindowHeight + 24))
    local xl = {}
    local yl = {}
    while xs < xf do
        table.insert(xl,xs)
        xs = xs + 32
    end
    while ys < yf do
        table.insert(yl,ys)
        ys = ys + 32
    end
    return xl,yl
end

function TanAngle(relx,rely)
    local dir = math.atan2(rely,relx)
    local yf = math.sin(dir)
    local xf = math.cos(dir)
    return {xf,yf,dir}
end

function getDist(x1,y1,x2,y2) --hypot
    return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

function clamp(val,min,max) --min+max in 1 function
    return math.max(min,math.min(val,max))
end

function round(num, numDecimalPlaces) --python round function
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
  
function sum(list) --python sum function 
    local t = 0
    for i,v in ipairs(list) do
        t = t + v
    end
    return t
end
  
function avg(list) --erm... python avg function
    local t = sum(list)
    return t/#list
end
  
function split(str,delimiter) --thanks google searchlabs!
    local result = {}
    if not str then
        return {0,0}
    end
    for part in string.gmatch(str, "([^" .. delimiter .. "]+)") do
        table.insert(result,part)
    end
    return result
end

function ReverseList(ls) --reverse a table of simple values
    for i=1,math.floor(#ls/2),1 do
        ls[i],ls[#ls-i+1] = ls[#ls-i+1],ls[i]
    end
    return ls
end

local cachedFontSize = nil
local cachedFontObject = nil

function SimpleText(text,textSize,x,y,orient) --draw text in ariafont
    local orient = orient or "left"
    if cachedFontSize ~= textSize*1.5*GameScale then
        cachedFontObject = love.graphics.newFont("lib/Ariafont-Regular.ttf",textSize*1.5*GameScale,'normal')
        cachedFontSize = textSize*1.5*GameScale
    end
    local textObject = love.graphics.newText(cachedFontObject,text) --this errors but it always works... silly lua
    local textWid = textObject:getWidth()
    local textHei = textObject:getHeight()

    --Orient
    if orient == "center" then
      x = x - textWid/2
      y = y - textHei/2
    end
    if orient == 'right' then
      x = x - textWid
      y = y - textHei
    end
    love.graphics.draw(textObject,x,y,0)
    textObject:release()
    return textWid
end

function TextWidth(text,textSize) --get width of text
    local fontObject = love.graphics.newFont("lib/Ariafont-Regular.ttf",textSize*1.5*GameScale,'normal') --this is really fucking inefficient
    local textObject = love.graphics.newText(fontObject,text)
    return textObject:getWidth()
end


--Collide point (x,y) with rect(x,y,wid,hei)
function PointCollideRect(rect,x,y)
    if x > rect['x'] and x < rect['x']+rect['w'] and y > rect['y'] and y < rect['y']+rect['h'] then
        return true
    end
    return false
end

--Thanks chatgpt
function SerializeTable(t, indent)
    indent = indent or 0
    local s = string.rep(" ", indent) .. "{\n"
    for k, v in pairs(t) do
        local key = type(k) == "string" and string.format("[%q]", k) or "["..k.."]"
        if type(v) == "table" then
            s = s .. string.rep(" ", indent + 2) .. key .. " = " .. SerializeTable(v, indent + 2) .. ",\n"
        elseif type(v) == "string" then
            s = s .. string.rep(" ", indent + 2) .. key .. " = " .. string.format("%q", v) .. ",\n"
        else
            s = s .. string.rep(" ", indent + 2) .. key .. " = " .. tostring(v) .. ",\n"
        end
    end
    return s .. string.rep(" ", indent) .. "}"
end


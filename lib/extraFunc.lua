--!file: extraFunc.lua
--extra stuff

function getOnScreen()
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

function tanAngle(relx,rely)
    local dir = math.atan2(rely,relx)
    local yf = math.sin(dir)
    local xf = math.cos(dir)
    return {xf,yf,dir}
end

function getDist(x1,y1,x2,y2)
    return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

function clamp(val,min,max)
    return math.max(min,math.min(val,max))
end

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
  
function sum(list) --sum of a list... python...
    local t = 0
    for i,v in ipairs(list) do
        t = t + v
    end
    return t
end
  
function avg(list) --average of a list... python...
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

function reverseList(ls)
    for i=1,math.floor(#ls/2),1 do
        ls[i],ls[#ls-i+1] = ls[#ls-i+1],ls[i]
    end
    return ls
end

local cachedFontSize = nil
local cachedFontObject = nil

function simpleText(text,textSize,x,y,orient)
    local orient = orient or "left"
    if cachedFontSize ~= textSize*1.5*GameScale then
        cachedFontObject = love.graphics.newFont("lib/Mikofont-Regular.ttf",textSize*1.5*GameScale,'normal')
        cachedFontSize = textSize*1.5*GameScale
    end
    local textObject = love.graphics.newText(cachedFontObject,text)
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
end

--Collide point (x,y) with rect(x,y,wid,hei)
function pointCollideRect(rect,x,y)
    if x > rect['x'] and x < rect['x']+rect['w'] and y > rect['y'] and y < rect['y']+rect['h'] then
        return true
    end
    return false
end

function decodeJLI(fn) --Decode FMV images
    local path = love.filesystem.getWorkingDirectory()
    local filename = path.."/"..fn..".jli"
    local cmd = "py "..path.."/jli/jlidecode.py "..filename
    local exitCode = os.execute(cmd)
    while true do
        local f = io.open(fn..".png")
        if f ~= nil then
            break
        end
    end
    -- local img = love.graphics.newImage(path.."/"..fn..".png")
    -- return img
end



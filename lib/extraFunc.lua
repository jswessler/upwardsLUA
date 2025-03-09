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
  
function createList(size,value)
    local t = {}
    for i=1,size do
        t[i] = value
    end
    return t
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
    if cachedFontSize ~= textSize then
        cachedFontObject = love.graphics.newFont("lib/Mikofont-Regular.ttf",textSize*1.5,'normal')
        cachedFontSize = textSize
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
end

stats={}

-- Get the mean value of a table
function stats.mean( t )
  local sum = 0
  local count= 0

  for k,v in pairs(t) do
    if type(v) == 'number' then
      sum = sum + v
      count = count + 1
    end
  end

  return (sum / count)
end

-- Get the mode of a table.  Returns a table of values.
-- Works on anything (not just numbers).
function stats.mode( t )
  local counts={}

  for k, v in pairs( t ) do
    if counts[v] == nil then
      counts[v] = 1
    else
      counts[v] = counts[v] + 1
    end
  end

  local biggestCount = 0

  for k, v  in pairs( counts ) do
    if v > biggestCount then
      biggestCount = v
    end
  end

  local temp={}

  for k,v in pairs( counts ) do
    if v == biggestCount then
      table.insert( temp, k )
    end
  end

  return temp
end

-- Get the median of a table.
function stats.median( t )
  local temp={}

  -- deep copy table so that when we sort it, the original is unchanged
  -- also weed out any non numbers
  for k,v in pairs(t) do
    if type(v) == 'number' then
      table.insert( temp, v )
    end
  end

  table.sort( temp )

  -- If we have an even number of table elements or odd.
  if math.fmod(#temp,2) == 0 then
    -- return mean value of middle two elements
    return ( temp[#temp/2] + temp[(#temp/2)+1] ) / 2
  else
    -- return middle element
    return temp[math.ceil(#temp/2)]
  end
end
    

-- Get the standard deviation of a table
function stats.standardDeviation( t )
  local m
  local vm
  local sum = 0
  local count = 0
  local result

  m = stats.mean( t )

  for k,v in pairs(t) do
    if type(v) == 'number' then
      vm = v - m
      sum = sum + (vm * vm)
      count = count + 1
    end
  end

  result = math.sqrt(sum / (count-1))

  return result
end

-- Get the max and min for a table
function stats.maxmin( t )
  local max = -math.huge
  local min = math.huge

  for k,v in pairs( t ) do
    if type(v) == 'number' then
      max = math.max( max, v )
      min = math.min( min, v )
    end
  end

  return max, min
end

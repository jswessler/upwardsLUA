--! file: mathExtras.lua
--contains some misc python functions that lua doesn't have for some reason

--Round num to the nearest numDecimalPlaces places
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

function createList(size,value)
  local t = {}
  for i=1,size do
      t[i] = value
  end
  return t
end
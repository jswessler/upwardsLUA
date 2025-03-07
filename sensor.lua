--!file: sensor.lua
--used for collision detection

Sensor = Object:extend()

function Sensor:new(owner)
    self.owner = owner
    self.locations = {}
end

function Sensor:detect(x,y)
    local xp = math.min(LevelWidth*32,math.max(0,self.owner.xpos+x+self.owner.xv))
    local yp = math.min(LevelHeight*32,math.max(0,self.owner.ypos+y+self.owner.yv))
    local block = math.floor(xp/32).."-"..math.floor(yp/32) --location of block
    local ret = LevelData[block] --actual block found
    if ret == nil or string.sub(ret,1,1) == "0" then
        ret = nil
        table.insert(self.locations,{false,false,xp,yp})

    else

        if string.sub(ret,1,1) == "1" then
            table.insert(self.locations,{true,true,xp,yp})
            return {true,ret,block}
        else
            table.insert(self.locations,{true,false,xp,yp})
            return {false,ret,block}
        end
    end
    return {false,ret,block}
end

function Sensor:draw(qq)
    if qq then 
        for i,v in ipairs(self.locations) do
            if v[1] then
                if v[2] then
                    love.graphics.setColor(1,0,0,1)
                else
                    love.graphics.setColor(0,0.5,1,1)
                end
            else
                love.graphics.setColor(0.3,0.3,0.3,1)
            end
            love.graphics.circle('fill',(v[3]-CameraX)*GameScale,(v[4]-CameraY)*GameScale,3)
        end
        love.graphics.setColor(1,1,1,1)
    end
    self.locations = {}
end

function Sensor:tostring()
    return "Sensor, my owner is "..self.owner
end
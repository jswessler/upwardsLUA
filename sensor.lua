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
        table.insert(self.locations,{0,xp,yp})
    else

        if split(ret,"-")[1] == "1" then --if you detect a solid block
            table.insert(self.locations,{1,xp,yp})
            return {true,ret,block}
        else
            table.insert(self.locations,{2,xp,yp})
            return {false,ret,block}
        end
    end
    return {false,ret,block}
end

function Sensor:detectEnemy(x,y,loc)
    local xp = math.min(LevelWidth*32,math.max(0,self.owner.xpos+x+self.owner.xv))
    local yp = math.min(LevelHeight*32,math.max(0,self.owner.ypos+y+self.owner.yv))
    for i,e in ipairs(Enemies) do
        if loc == 'all' then
            if xp > e.xpos and xp < e.xpos+e.width and yp > e.ypos and yp < e.ypos+e.height then
                table.insert(self.locations,{3,xp,yp})
                return {true,e}
            end
        end
        if loc == 'top' then
            if xp > e.xpos and xp < e.xpos+e.width and yp > e.ypos and yp < e.ypos+4 then
                table.insert(self.locations,{3,xp,yp})
                return {true,e}
            end
        end
        if loc == 'hurt' then
            if xp > e.xpos and xp < e.xpos+e.width and yp > e.ypos+e.height/2 and yp < e.ypos+e.height then
                table.insert(self.locations,{3,xp,yp})
                return {true,e}
            end
        end
    end
    return {false,nil}
end

function Sensor:reset()
    self.locations = {}
end


function Sensor:draw()
    for i,v in ipairs(self.locations) do
        if v[1] == 1 then
            love.graphics.setColor(1,0,0,1) --red if you detected a solid block
        elseif v[1] == 2 then
            love.graphics.setColor(0,0.5,1,1) --blue if you detected a non-solid block
        elseif v[1] == 3 then
            love.graphics.setColor(0,1,0.25,1) --green if you detected an enemy
        
        else
            love.graphics.setColor(0.3,0.3,0.3,1)
        end
        love.graphics.circle('fill',(v[2]-CameraX)*GameScale,(v[3]-CameraY)*GameScale,3)
    end
    love.graphics.setColor(1,1,1,1)
    self:reset()
end

function Sensor:tostring()
    return "Sensor, my owner is "..self.owner
end
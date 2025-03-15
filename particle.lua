--!file: particle.lua
--Handles all particle effects

Particle = Object:extend()

function Particle:new(x,y,ani,dir)
    self.xpos = x
    self.ypos = y
    self.xOffset = 0
    self.yOffset = 0
    self.timeAlive = 0
    self.frame = 0
    self.type = ani
    self.dir = dir
    self.img = nil
end

function Particle:update(dt)
    self.timeAlive = self.timeAlive + dt

    --Do things for each type of particle, manually coded
    if self.type == 'run' then
        self.frame = math.floor(self.timeAlive*5)+1
        self.xOffset = -13*self.dir
        self.yOffset = -24
        if self.frame > 2 then
            return true
        end
        self.img = love.graphics.newImage("Images/Particles/"..self.type..self.frame..".png")
    end
    return false
end

function Particle:draw()
    if self.img ~= nil then
        if self.dir == 1 then
            love.graphics.draw(self.img,(self.xpos+self.xOffset-CameraX)*GameScale,(self.ypos+self.yOffset-CameraY)*GameScale,0,2*GameScale,2*GameScale,0,0)
        else
            love.graphics.draw(self.img,(self.xpos+self.xOffset-CameraX)*GameScale,(self.ypos+self.yOffset-CameraY)*GameScale,0,-2*GameScale,2*GameScale,0,0)
        end
    end
end
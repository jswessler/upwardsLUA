--!file: particle.lua
--Handles all particle effects

Particle = Object:extend()

function Particle:new(x,y,ani,dir,info)
    self.xpos = x
    self.ypos = y
    self.xOffset = 0
    self.yOffset = 0
    self.timeAlive = 0
    self.frame = 1
    self.type = ani
    self.dir = dir
    self.img = nil
    self.info = info
end

function Particle:update(dt) --return true if the particle should die
    self.timeAlive = self.timeAlive + dt

    --Do things for each type of particle, manually coded
    if self.type == 'run' then
        self.frame = math.floor(self.timeAlive*5)+1
        self.xOffset = -13*self.dir
        self.yOffset = -24
        if self.frame > 2 then
            return true
        end
    end

    if self.type == 'sparkle' then
        if self.timeAlive > 0.03 then
            self.frame = math.random(1,5)
            self.timeAlive = 0
        end
        self.xOffset = self.xOffset+math.random()-0.5
        self.yOffset = self.yOffset+math.random()-0.5
        if self.frame == 5 then
            return true
        end
    end

    if self.type == 'hiccup' then
        self.frame = math.min(8,math.floor(self.timeAlive*22)+1)
        self.xOffset = Pl.xpos-self.xpos - 122
        if self.info == 8 then
            self.yOffset = Pl.ypos-self.ypos - 123 - 5*(-self.frame^2 + 8*self.frame)
        else 
            self.yOffset = Pl.ypos-self.ypos - 115 - 2*(-self.frame^2 + 8*self.frame)
        end
        if self.frame == self.info then
            if self.info == 8 then
                Pl.abilities['spinny'] = 2
            else
                Pl.abilities['spinny'] = 1
            end
            return true
        end
    end
    self.img = love.graphics.newImage("image/Particles/"..self.type..self.frame..".png")
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
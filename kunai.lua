--!file: kunai.lua
--File for thrown kunai!

Kunai = Object:extend()
require "sensor"
require "lib.extraFunc"

function Kunai:new(xpos,ypos,xv,yv)
    self.xpos = xpos
    self.ypos = ypos
    self.xv = xv
    self.yv = yv
    self.gravity = 0.15
    self.stuck = false
    self.timeAlive = 0
    self.timeHoming = 0
    self.baseImage = love.graphics.newImage("Images/UI/pixelkunai.png") --maybe change later if there is more than 1 type of kunai
    self.kSe = Sensor(self)
    self.direction = 0
    self.colliderCount = 0

end

function Kunai:update(dt)
    self.timeAlive = self.timeAlive + dt
    local t = tanAngle(self.xv,self.yv)
    self.direction = t[3]
    self.yv = self.yv + (self.gravity*dt*240)

    --Quarterstep updating
    for i=1,4,1 do
        if not self.stuck then
            self.xpos = self.xpos + self.xv*dt*15
            self.ypos = self.ypos + self.yv*dt*15
        end

        --Scan in a rectangle
        self.colliderCount = 0
        for i=-8,8,8 do
            for j=-8,8,8 do
                if self.kSe:detect(i,j)[1] then
                    self.colliderCount = self.colliderCount + 1
                end
            end
        end

        --Hit a wall
        if self.colliderCount >= 2 then
            self.stuck = true
            self.gravity = 0
        else
            self.stuck = false
            self.gravity = 0.15
        end
    end

    --Home back to player if stuck and alive for 1.5 seconds
    if getDist(self.xpos,self.ypos,Pl.xpos,Pl.ypos) < 300 and self.timeAlive > 1.5 then
        if self.timeHoming < 1.5 then
            self.timeHoming = self.timeHoming + dt
        end
        self.stuck = false

        --Retract Kunai
        self.xv = (self.xpos-Pl.xpos) / -(18-(self.timeHoming/0.1))
        self.yv = (self.ypos-Pl.ypos+50) / -(18-(self.timeHoming/0.1)) --+50 so it goes to your face instead of your feet
        
        --Delete if right next to you
        if getDist(self.xpos,self.ypos,Pl.xpos,Pl.ypos) < 60 then
            Kunais = Kunais + 1
            return true
        end
    else
        self.timeHoming = 0
    end
    return false
end

function Kunai:tostring()
    return "Kunai, x="..round(self.xpos,2).." y="..round(self.ypos,2)
end
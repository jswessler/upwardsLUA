--!file: kunai.lua
--File for thrown kunai

require "entity.entity"
require "sensor"
require "lib.extraFunc"

Kunai = Entity:extend()

function Kunai:new(xpos,ypos,xv,yv)
    self.super.new(self,xpos,ypos,xv,yv,"kunai")
    self.radius = 8
    self.baseImage = love.graphics.newImage("Images/UI/pixelkunai.png")
    self.attachedTo = nil
end

function Kunai:update(dt)
    self.super.update(self,dt)

    --Hit a wall (overridden probably)
    if self.colliderCount >= 1 then
        self.stuck = true
        self.gravity = 0
    else
        self.stuck = false
        self.gravity = 1
    end

    --Stick to enemies
    if self.attachedTo then
        self.xpos = self.attachedTo.xpos
        self.ypos = self.attachedTo.ypos
        self.xv = 0
        self.yv = 0
        if self.attachedTo.health == -1 then
            self.attachedTo = nil
        end
    end

    --Scan for enemies

    --TODO: Have kunais get stuck in enemies until they die, and then they all drop
    self.colliderCount = 0
    if not self.attachedTo then
        for i=-self.radius,self.radius,self.radius do
            for j=-self.radius,self.radius,self.radius do
                local e = self.kSe:detectEnemy(i,j,'all')
                if e[1] and FrameCounter > e[2].iframe then
                    e[2].health = e[2].health - ((self.xv+self.yv)>5 and 1 or 0)
                    e[2].iframe = FrameCounter + 0.2
                    if e[2].health == 0 then
                        e[2].deathMode = 'struck'
                    end
                    self.attachedTo = e[2]
                end
            end
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
    local x = self.super.tostring(self)
    return x.."Kunai, x="..round(self.xpos,2).." y="..round(self.ypos,2)
end
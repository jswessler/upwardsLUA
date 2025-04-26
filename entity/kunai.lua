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
end

function Kunai:update(dt)
    self.super.update(self,dt)
    
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
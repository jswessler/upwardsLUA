--!file: kunai.lua
--File for thrown kunai

require "entity.entity"
require "sensor"
require "lib.extraFunc"

Coin = Entity:extend()

function Coin:new(xpos,ypos,xv,yv)
    self.super.new(self,xpos,ypos,xv,yv,"kunai")
    self.radius = 16
    self.baseImage = love.graphics.newImage("Images/UI/coin.png")
    self.xOffset = 16
    self.yOffset = 16
end

function Coin:update(dt)
    self.super.update(self,dt)
    self.direction = 0
    self.xv = self.xv * (0.1^dt)

    --Hit a wall (overridden probably)
    if self.colliderCount >= 1 then
        --Bounce
        if math.abs(self.xv) > 0.1 then
            self.xv = -self.xv * 0.8
        else
            self.xv = 0
        end
        if math.abs(self.yv) > 0.25 then
            self.yv = -self.yv * 0.6
        else
            self.yv = 0
            self.stuck = true
            self.gravity = 0
        end
    end
    
    --Home back to player if stuck and alive for 1.5 seconds
    if getDist(self.xpos,self.ypos,Pl.xpos,Pl.ypos) < 50 and self.timeAlive > 0.5 then
        Coins = Coins + 1

        --Heal
        local healAmt = 1
        for i=1,#Health,1 do
            healAmt = Health[i]:heal(healAmt)
        end
        return true
    end
    return false
end

function Coin:tostring()
    local x = self.super.tostring(self)
    return x.."Coin, x="..round(self.xpos,2).." y="..round(self.ypos,2)
end
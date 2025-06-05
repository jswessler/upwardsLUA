--!file: enemy.lua
--Generic enemy class

Enemy = Object:extend()
require "sensor"
require "particle"
require "lib.extraFunc"

EnemyList = {
    {1,'debug',48,96,2},
}

function Enemy:new(x,y,typ)
    self.xpos = x
    self.ypos = y
    self.rotation = 0
    self.type = typ
    self.width = EnemyList[typ][3]
    self.height = EnemyList[typ][4]
    self.health = EnemyList[typ][5]
    self.se = Sensor(self)

    self.timeAlive = 0
    self.xv = 2
    self.yv = 0
    self.gravity = 1
    self.onGround = true
    self.colliderCount = 0
    self.iframe = 0

    self.health = 2
    self.deathMode = 0 --0 = not dead, 1 = squish, 2 = kicked, 3 = idk
    self.deathCounter = -1

    self.squishFactor = 1
    
    self.img = love.graphics.newImage("Images/Enemy/enemy1.png") --change to something else later
end

function Enemy:update(dt)
    self.timeAlive = self.timeAlive + dt

    --Down Collision Detection
    self.xpos = self.xpos + self.xv * (dt*115)
    self.ypos = self.ypos + self.yv * (dt*115)
    self.colliderCount = 0
    for i = 0,self.width,8 do
        if self.se:detect(i, self.height)[1] then
            self.colliderCount = self.colliderCount + 1 
        end
    end
    
    --If on the ground
    if self.colliderCount > 0 then
        for i=0,self.width,8 do
            if self.se:detect(i,self.height-0.5)[1] then
                self.ypos = self.ypos - 0.5
            end
        end
    
        if self.onGround == false then
            self.ypos = self.ypos + (dt*140)
        end
        self.onGround = true
        self.yv = 0
        self.gravity = 0
    else
        self.onGround = false
        self.gravity = 1
    end


    
    --Right detection
    self.colliderCount = 0
    for i=8,self.height-8,8 do
        if self.se:detect(self.width, i)[1] then
            self.colliderCount = self.colliderCount + 1
        end
    end

    --If right collision
    if self.colliderCount > 0 then
        for i=8,self.height-8,8 do
            if self.se:detect(self.width+0.5,i)[1] then
                self.xpos = self.xpos - 0.5
            end
        end
        self.xv = -self.xv
    end

    --Left detection
    self.colliderCount = 0
    for i=8,self.height-8,8 do
        if self.se:detect(0, i)[1] then
            self.colliderCount = self.colliderCount + 1
        end
    end
    
    --If left collision
    if self.colliderCount > 0 then
        for i=8,self.height-8,8 do
            if self.se:detect(self.width+0.5,i)[1] then
                self.xpos = self.xpos + 0.5
            end
        end
        self.xv = -self.xv
    end

    self.yv = self.yv + (self.gravity * dt * GlobalGravity)

    --Death animations

    if self.deathMode == 1 or self.deathMode == 'squish' then
        self.squishFactor = self.squishFactor - (self.squishFactor-0.5) * (dt*20)
    end

    if self.deathMode == 2 or self.deathMode == 'kicked' then
        self.rotation = self.rotation + (self.xv * dt * 3)
    end

end

function Enemy:draw()
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.img,(self.xpos-CameraX)*GameScale,((self.ypos-CameraY) + (1-self.squishFactor)*self.height)*GameScale,self.rotation,GameScale,GameScale*self.squishFactor)
end

function Enemy:die()
    --Just disappear
    if self.deathMode == 0 or self.health < 0 then
        return true
    end

    --Squish to death
    if self.deathMode == 1 or self.deathMode == 'squish' then
        self.health = -1
        self.deathCounter = FrameCounter + 0.5 --die after 0.5s of being squished
        return false
    end

    --Kicked by a slide
    if self.deathMode == 2 or self.deathMode == 'kicked' then
        self.health = -1
        self.deathCounter = FrameCounter + 0.6 --die after 0.5s of being kicked
        self.yv = -6
        return false
    end

    --Hit by throwing knife
    if self.deathMode == 3 or self.deathMode == 'struck' then
        self.health = -1
        self.deathCounter = FrameCounter + 0.25 --die after 0.25s of being hit
        self.xv = self.xv * 1.5
        self.yv = -1.6
        return false
    end

end
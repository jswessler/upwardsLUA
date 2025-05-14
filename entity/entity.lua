--!file: entity.lua
--An entity is a thing that has gravity & collision detection

Entity = Object:extend()
require "sensor"
require "lib.extraFunc"

function Entity:new(xpos,ypos,xv,yv,typ)
    self.xpos = xpos
    self.ypos = ypos
    self.xv = xv
    self.yv = yv
    self.xOffset = 0
    self.yOffset = 0
    self.typ = typ
    self.gravity = 1
    self.timeAlive = 0
    self.kSe = Sensor(self)
    self.direction = 0
    self.colliderCount = 0
    self.radius = 8
    self.stuck = false
end

function Entity:update(dt)
    self.timeAlive = self.timeAlive + dt
    local t = tanAngle(self.xv,self.yv)
    self.direction = t[3]

    --Drag & air drag
    self.yv = self.yv + (self.gravity * dt * GlobalGravity * 3)
    self.xv = self.xv * (0.9^dt)

    --Quarterstep updating
    for i=1,StepSize,1 do
        if not self.stuck then
            self.xpos = self.xpos + self.xv*dt*(60/StepSize)
            self.ypos = self.ypos + self.yv*dt*(60/StepSize)
        end

        --Scan in a rectangle
        self.colliderCount = 0
        for i=-self.radius,self.radius,self.radius do
            for j=-self.radius,self.radius,self.radius do
                if self.kSe:detect(i,j)[1] then
                    self.colliderCount = self.colliderCount + 1
                end
            end
        end
    end
    return false
end

function Entity:tostring()
    return "Entity - "
end

function Entity:draw(s)
    local scale = s*2 or 2
    love.graphics.draw(self.baseImage,(self.xpos-CameraX-self.xOffset)*GameScale,(self.ypos-CameraY-self.yOffset)*GameScale,self.direction,scale,scale,0,0)
end
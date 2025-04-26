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
    self.typ = typ
    self.gravity = 0.15
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
    self.yv = self.yv + (self.gravity*dt*240)

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

        --Hit a wall (overridden probably)
        if self.colliderCount >= 1 then
            self.stuck = true
            self.gravity = 0
        else
            self.stuck = false
            self.gravity = 0.15
        end
    end
end

function Entity:tostring()
    return "Entity - "
end
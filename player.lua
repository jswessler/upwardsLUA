--!file: player.lua
--generic player class

Player = Object:extend()
require "sensor"

function Player:new(x,y)
    --position
    self.xpos = x
    self.ypos = y
    self.xv = 0
    self.yv = 0
    self.facing = 0

    --energy
    self.energy = 100
    self.eRegen = 0

    --variables
    self.gravity = 1
    self.jCounter = 0
    self.abilities = {4,15,0,2,2}
    self.wallClimb = false
    self.timeOnGround = 0
    self.onGround = true

    --self counter
    self.counter = 0

    --slide mechanics
    self.slide = 0
    self.slideBoost = 0
    self.slideMult = 0

    --image
    self.img = ''
    self.imgPos = {0,0}

    --display characteristics
    self.dFacing = 1
    self.animation = 'falling'
    self.nextAni = 'none'
    self.aniFrame = 1
    self.aniTimer = 0
    self.aniiTimer = 0

    --misc
    self.maxSpd = 2.5
    self.kunaiAni = 0

    --sensor
    self.se = Sensor(self)
    self.col = {12,-100,30,-25} --bottom, top, right, left, 1,2,3,4

end

function Player:animate(dt)
    self.counter = self.counter + (dt*60)
    
    if self.aniTimer > 0 then
        self.aniTimer = self.aniTimer - (60*dt)
    end
    self.aniiTimer = self.aniiTimer - (60*dt)
    if self.kunaiAni > 0 then
        self.kunaiAni = self.kunaiAni - (60*dt)
    end

    --Tumble Landing

    --Normal Landing
    if self.animation == 'landed' then
        if self.aniTimer < 0 then
            self.animation = 'none'
        end
        self.img = love.graphics.newImage("Images/Aria/land.png")
        self.imgPos = {-36,-94}

    --Hard landing (11 frame animation that must play out)
    elseif self.animation == 'hardlanded' then
        if self.aniTimer < 0 then
            self.animation = 'none'
        end
        if self.aniTimer > 11 then
            self.img = love.graphics.newImage("Images/Aria/hardland1.png")
            self.imgPos = {-34,-94}
        elseif self.aniTimer > 7 then
            self.img = love.graphics.newImage("Images/Aria/hardland2.png")
            self.imgPos = {-32,-66}
        else
            self.img = love.graphics.newImage("Images/Aria/hardland3.png")
            self.imgPos = {-26,-94}
        end

    --Phone Call

    --Ground Animations

    elseif self.onGround then

        --Slide loop
        if self.animation == 'slide' and math.abs(self.xv) > 0.5 then
            if self.slide > 221 then
                if self.counter%12 < 6 then
                    self.img = love.graphics.newImage("Images/Aria/slide1.png")
                else
                    self.img = love.graphics.newImage("Images/Aria/slide2.png")
                end
                self.imgPos = {-36,-86}
            
            --slide exit transition
            else
                if self.slide > 210 then
                    self.img = love.graphics.newImage("Images/Aria/slideout1.png")
                else
                    self.img = love.graphics.newImage("Images/Aria/slideout2.png")
                end
                self.imgPos = {-36,-86}

            end
        
        --Run (17 frame animation)
        elseif self.animation == 'run' or math.abs(self.xv) > 0.5 then
            if self.aniTimer < 0 then
                self.aniFrame = self.aniFrame + 1
                if self.aniFrame == 18 then
                    self.aniFrame = 1
                    --particle effect
                end
                if self.aniFrame == 9 then
                    --particle effect
                end
                self.aniTimer = math.max(3,round(5.5-math.abs(self.xv)))
            end

            --Grab correct frame
            self.img = love.graphics.newImage("Images/Aria/run"..self.aniFrame..".png")
            self.imgPos = {-36,-94}

        --Idle (4 frame loop)
        elseif self.animation == 'none' then
            if self.counter%60 < 16 then
                self.img = love.graphics.newImage("Images/Aria/idle1.png")
            elseif self.counter%60 < 31 then
                self.img = love.graphics.newImage("Images/Aria/idle2.png")
            elseif self.counter%60 < 47 then
                self.img = love.graphics.newImage("Images/Aria/idle3.png")
            else
                self.img = love.graphics.newImage("Images/Aria/idle4.png")
            end
            self.imgPos = {-26,-100}
        end
    
    --Air Animations
    else

        --Hover
        if self.animation == 'hover' then
            self.nextAni = 'low'
            self.aniiTimer = 13
            self.animation = 'none'
            if self.aniTimer < 0 then
                self.aniFrame = self.aniFrame + 1
                self.aniTimer = 6
            end
            if self.aniFrame > 6 then
                self.aniFrame = 1
            end
            if self.energy > 30 then
                if math.abs(self.xv) < 0.5 then
                    self.img = love.graphics.newImage("Images/Aria/hovern"..self.aniFrame..".png")
                else    
                    self.img = love.graphics.newImage("Images/Aria/hoverr"..self.aniFrame..".png")
                end
            else
                if math.abs(self.xv) < 0.5 then
                    self.img = love.graphics.newImage("Images/Aria/hovernl"..self.aniFrame..".png")
                else    
                    self.img = love.graphics.newImage("Images/Aria/hoverrl"..self.aniFrame..".png")
                end
            end
            self.imgPos = {-31,-102}
    

        --Air Transitions (awful coding)
        elseif self.yv > -0.5 and (self.nextAni=='high' or self.nextAni=='low') and not self.onGround then --if we have a queued animation
            
            --high transition after jump
            if self.aniiTimer < -1 then
                self.aniiTimer = 13
            end
            if self.nextAni == 'high' then
                if self.aniiTimer < 0 then
                    self.nextAni = 'none'
                    self.animation = 'falling'
                end
                --after 3 frames, go to standard falling animation
                self.img = love.graphics.newImage("Images/Aria/jumptrans"..math.floor((18-self.aniiTimer)/5)..".png")
                self.imgPos = {-31,-100}


            --mid transition after double jump
            elseif self.nextAni == 'mid' then
                if self.aniiTimer < 0 then
                    self.nextAni = 'none'
                    self.animation = 'falling'
                end
                self.img = love.graphics.newImage("Images/Aria/lowtrans2.png")
                self.imgPos = {-31,-100}

            --low transition after hover or dive jump
            elseif self.nextAni == 'low' then
                if self.aniiTimer < 0 then
                    self.nextAni = 'none'
                    self.animation = 'falling'
                end
                self.img = love.graphics.newImage("Images/Aria/lowtrans"..math.floor((18-self.aniiTimer)/5)..".png")
                self.imgPos = {-31,-100}
            end
            if self.aniiTimer < 0 then
                self.aniiTimer = 13
            end
        
        else
            --Other air animations

            --Walljump

            --Wallslide
            if self.animation == 'wallslide' then
                if self.counter % 20 < 10 then
                    self.img = love.graphics.newImage("Images/Aria/wallslide.png")
                else
                    self.img = love.graphics.newImage("Images/Aria/wallslide2.png")
                end
                if self.dFacing == 1 then
                    self.imgPos = {-24,-102}
                else
                    self.imgPos = {-28,-102}
                end
            end

            --Double Jump
            if self.nextAni == 'djump' then
                self.animation = 'falling'
                if self.aniTimer < 0 then
                    self.aniFrame = self.aniFrame + 1
                    self.aniTimer = 3.5
                end
                if self.aniFrame > 5 then
                    self.nextAni = 'mid'
                    self.aniiTimer = 13
                end
                self.img = love.graphics.newImage("Images/Aria/djump"..math.min(3,self.aniFrame)..".png")
                self.imgPos = {-84,-101}


            --Djump transition (when moving up)
            elseif self.animation == 'djumpup' then
                if self.aniTimer < 0 then
                    self.aniFrame = self.aniFrame + 1
                    self.aniTimer = 4
                end
                if self.aniFrame > 3 then
                    self.nextAni = 'djump'
                    self.animation = 'none'
                end
                self.img = love.graphics.newImage("Images/Aria/djumpup"..math.min(2,self.aniFrame)..".png")
                self.imgPos = {-32,-125}
            
            --Djump transition (when moving down)
            elseif self.animation == 'djumpdown' then
                if self.aniTimer < 0 then
                    self.aniFrame = self.aniFrame + 1
                    self.aniTimer = 4
                end
                if self.aniFrame > 3 then
                    self.nextAni = 'djump'
                    self.animation = 'none'
                end
                self.img = love.graphics.newImage("Images/Aria/djumpdown"..math.min(2,self.aniFrame)..".png")
                self.imgPos = {-31,-104}
            
            --Single Jump
            elseif self.animation == 'jump' then
                self.nextAni = 'high'
                self.aniiTimer = 13
                self.aniTimer = 6
                if self.counter%30 < 16 then
                    self.img = love.graphics.newImage("Images/Aria/jumpup1.png")
                else
                    self.img = love.graphics.newImage("Images/Aria/jumpup2.png")
                end
                self.imgPos = {-31,-100}

            --Dive

            --Hover?

        --Falling Animations

            elseif self.nextAni == 'fastfall' then
                if self.aniTimer < 0 then
                    self.aniFrame = self.aniFrame + 1
                    self.aniTimer = math.floor(19-(1.5*self.yv))
                end
                if self.aniFrame > 4 then
                    self.aniFrame = 1
                end
                self.img = love.graphics.newImage("Images/Aria/flail"..self.aniFrame..".png")
                self.imgPos = {-31,-116}

            elseif self.nextAni == 'fftrans' then
                if self.aniTimer < 0 then
                    self.nextAni = 'fastfall'
                end
                self.img = love.graphics.newImage("Images/Aria/fftrans.png")
                self.imgPos = {-31,-116}

            elseif self.animation == 'falling' then
                if self.aniTimer < 0 then
                    self.aniFrame = self.aniFrame + 1
                    self.aniTimer = 5
                end
                if self.aniFrame > 4 then
                    self.aniFrame = 1
                end
                if self.yv > 4.25 then
                    self.aniTimer = 9
                    self.nextAni = 'fftrans'
                    self.animation = 'none'
                end
                self.img = love.graphics.newImage("Images/Aria/falling"..self.aniFrame..".png")
                self.imgPos = {-31,-116}
            end
        end
    end
end

function Player:update(dt)
    
    --reduce jCounter
    if self.jCounter > 0 then
        self.jCounter = self.jCounter - (dt*10)
    end

    --prevent energy from going out of bounds
    if self.energy < 0 then
        self.energy = 0
    end
    if self.energy > 100 then
        self.energy = 100
    end

    --energy calculations
    if self.energy < 20 then
        self.eRegen = (self.energy/105)+0.005
    elseif self.energy < 75 then
        self.eRegen = 0.19
    else
        self.eRegen = math.max(0.01,0.0075 + (100-self.energy)/250)
    end
    --silver heart calculation
    local silverCap = 0
    for i=1,#Health,1 do
        if Health[i].type == 3 and silverCap <= 2 then
            silverCap = silverCap + Health[i].amt
            self.eRegen = self.eRegen * 1+(0.02*Health[i].amt)
            self.energy = self.energy + (4*dt) * (100-self.energy)/100 * Health[i].amt
        end
    end

    --down collision detection
    for j=1,2,1 do
        self.xpos = self.xpos + self.xv*(dt*225/2)
        self.ypos = self.ypos + self.yv*(dt*225/2)
        self.colliderCount = 0
        for i = -19, 27, 2 do
            if self.se:detect(i, self.col[1])[1] then
                self.colliderCount = self.colliderCount + 1
            end
        end
        if self.colliderCount > 0 and not self.onGround then
            break
        end
    end

    --If you're on the ground
    if self.colliderCount > 0 then

        --don't sink into the ground
        for i=0,20,1 do
            if self.se:detect(math.random(-19,27), self.col[1]-0.5)[1] then
                self.ypos = self.ypos - 0.1
            end
        end

        --first frame on ground
        if self.onGround == false then
            self.ypos = self.ypos + (dt*140)
            self.energy = self.energy + (5*self.eRegen)+0.5
            if self.yv > 0.5 and self.yv < 4.5 then
                self.animation = 'landed'
                self.aniTimer = 1+math.floor(self.yv*2.5)
            elseif self.yv > 4.5 then
                self.aniTimer = 21
                self.animation = 'hardlanded'
                self.maxSpd = 1.5
                local dmgAmt = 0
                if self.yv > 7.75 then
                    dmgAmt = 3
                elseif self.yv > 6.75 then
                    dmgAmt = 2
                elseif self.yv > 5.75 then
                    dmgAmt = 1
                end
                for i=#Health,1,-1 do
                    dmgAmt = Health[i]:takeDmg(dmgAmt)
                end
            end
        end
        self.onGround = true
        self.timeOnGround = self.timeOnGround + dt

        --slowdown if you landed hard
        if self.animation == 'hardlanded' then
            self.xv = self.xv * 0.01^dt
        end
        self.yv = 0
        self.gravity = 0
        self.abilities[1] = 1 --jump
        self.abilities[2] = 15 --jump extension
        self.abilities[3] = 4 --double jump
        self.abilities[4] = 2 --dive
        self.abilities[5] = 2 --dive jump
        self.energy = self.energy + (270*dt*(self.eRegen+0.001))
    else
        --regen energy if you're falling quickly
        self.onGround = false
        self.timeOnGround = 0
        self.gravity = 1

        --slide off an edge
        if self.slide > 0 then
            self.slide = self.slide - math.min(5,self.slide)
            self.jCounter = 1
            self.energy = self.energy - (2*dt)
            self.nextAni = 'low'
        end

        --up detection

        self.colliderCount = 0
        for i = -19, 27, 2 do
            if self.se:detect(i, self.col[2])[1] then
                self.colliderCount = self.colliderCount + 1
            end
        end
        if self.colliderCount > 0 then
            self.yv = 0
            self.ypos = self.ypos + 1
            self.jCounter = 0
        end
    end

    self.onWall = 0
    self.WJEnabled = 0

    --Right detection
    self.colliderCount = 0
    for i = self.col[2]+10, 0, 2 do
        if self.se:detect(self.col[3],i)[1] then
            self.colliderCount = self.colliderCount + 1
        end
    end
    if self.colliderCount > 0 then
        self.onWall = 1
        self.xv = 0
        if self.colliderCount > 30 then
            self.WJEnabled = 1
        end
    end

    --Left Detection
    self.colliderCount = 0
    for i = self.col[2]+10, 0, 2 do
        if self.se:detect(self.col[4],i)[1] then
            self.colliderCount = self.colliderCount + 1
        end
    end
    if self.colliderCount > 0 then
        self.onWall = -1
        self.xv = 0
        if self.colliderCount > 30 then
            self.WJEnabled = -1
        end
    end

    --keybinds & actions
    if love.keyboard.isDown("space") or love.keyboard.isDown("up") then
        
        --main single jump
        if self.abilities[1] > 0 then
            if self.slide >= 190 and self.slideBoost == 0 then
                self.slideBoost = (90-self.slide-190)^2
            end
            self.abilities[1] = 0
            self.jCounter = 8
            self.yv = self.yv - (0.6 + (self.slideBoost/50000) + (0.14*math.abs(self.xv)))
            if self.slideBoost ~= 0 then
                self.energy = self.energy - (10*dt)
                self.xv = self.xv * (1+self.slideBoost/250000)
            end
            self.animation = 'jump'
            self.onGround = false
        end

        --jump extension
        if not self.onGround and self.abilities[1]<=0 and self.abilities[2]>0 and self.energy > 0.2 then
            self.yv = self.yv - (dt*20)
            if self.abilities[2] < 12.5 then
                self.energy = self.energy - (30*dt)
            end
            self.abilities[2] = self.abilities[2] - (120*dt)
        end

        --hover
        if self.yv > 0 and self.energy > 0.1 and self.animation~='djumpdown' then
            self.yv = self.yv - 0.01
            self.yv = self.yv * 0.002^dt
            self.jCounter = 1
            self.energy = self.energy - (0.07+(0.0125*math.abs(self.xv)))*(170*dt)
            self.animation = 'hover'
        end

        --double jump
        if (self.abilities[3] > 0 and self.abilities[3] < 4) and not self.onGround and not self.wallClimb and self.abilities[1]<=0 and self.abilities[4]==2 and self.energy > 1 then
            --cancel out some downwards momentum if going down
            if self.yv > 0.5 then
                self.yv = 0.5
            end
            self.yv = self.yv - dt*(62 + (6*math.abs(self.xv)))
            self.maxSpd = math.min(2.75,self.maxSpd*(5^dt))
            self.xv = self.xv * (8^dt)
            self.abilities[3] = self.abilities[3] - (60*dt)
            self.energy = self.energy - (260*dt)
            self.jCounter = 10
            self.aniFrame = 1

            --adjust animation
            if self.animation ~= 'djumpdown' and self.animation ~= 'djumpup' then
                if self.yv > 0 then
                    self.animation = 'djumpdown'
                else
                    self.animation = 'djumpup'
                end
            end
        end

        --jump out of dive
        if self.abilities[5] > 0 and not self.onGround and self.abilities[1] <= 0 and self.abilities[4] ~= 2 and self.energy > 5 then
            self.yv = self.yv - 0.725
            self.xv = self.xv * 0.000001^dt
            self.abilities[5] = self.abilities[5] - (60*dt)
            self.abilities[4] = 0
            self.energy = self.energy - (40*dt)
            self.jCounter = 4

            --animation
            self.animation = 'hover'
        end

    --logic when not pressing space
    else
        self.slideBoost = 0

        --lose single jump if you let go of space
        if self.abilities[1] > 0 and self.abilities[1] < 4 and not self.onGround then 
            self.abilities[1] = 0
            self.abilities[2] = 0
        end

        --activate double jump once you let go of space after normal jump
        if self.abilities[1] <= 0 and self.abilities[3] == 4 then 
            self.abilities[3] = 3
            self.abilities[2] = 0
        end

        --lose double jump if you let go early
        if self.abilities[3] > 0 and self.abilities[3] < 3 then
            self.abilities[3] = 0
        end

        --hop off wall
        self.wallClimb = false

        --slight hover at the end of jumps (burns jCounter)
        if self.yv > -1 and self.jCounter > 0 then
            self.energy = self.energy - (3*dt)
            self.jCounter = self.jCounter - (30*dt)
            self.gravity = 0.5
        end

        --wall slide
        if not self.onGround and self.onWall~=0 and self.facing~=0 and self.energy > 1 then
            --limit fall speed
            self.yv = self.yv - 0.0025
            if love.keyboard.isDown("lctrl") then
                self.energy = self.energy - (15*dt) - (self.energy/50*dt)
                if self.yv > 0.5 then
                    self.yv = self.yv * 0.0005^dt
                end
                if self.yv > 1 then
                    self.yv = self.yv - (self.yv-3)/100
                end
            else
                self.energy = self.energy - (10*dt)
                if self.yv > 1.5 then
                    self.yv = self.yv * 0.1^dt
                end
                if self.yv > 3 then
                    self.yv = self.yv - (self.yv-3)/150
                end
            end

            --adjust
            self.jCounter = 2
            self.wallClimb = true
            self.animation = 'wallslide'
            self.nextAni = 'none'
            
        --transition out of wallslide animation
        elseif self.animation == 'wallslide' then
            self.nextAni = 'low'
            self.animation = 'none'
            self.aniiTimer = 13
        end

        --Wall Jump
        if self.wallClimb and self.energy > 6 and ((love.keyboard.isDown("a") and self.onWall == 1 and self.WJEnabled == 1) or (love.keyboard.isDown("d") and self.onWall == -1 and self.WJEnabled == -1)) then
            self.yv = self.yv * 0.25
            self.yv = -3.75
            self.jCounter = 10
            self.xv = -self.facing * 3
            self.energy = self.energy - 6
            self.wallClimb = false
            self.abilities[4] = 2
            self.abilities[5] = 1
            self.animation = 'jump' --change to walljump later
        end
    end

    --dive
    if love.keyboard.isDown("lctrl") then
        if self.abilities[4] > 0 and self.abilities[1]<=0 and self.energy > 10 then
            self.xv = self.dFacing * 4.25
            self.yv = self.yv * 0.1^dt
            self.yv = self.yv - 16*dt
            self.abilities[3] = 0
            self.abilities[4] = self.abilities[4] - (20*dt)
            self.maxSpd = 3.75

            --Fixes for dive cheeses
            --Fix for pressing double jump then immediately dive
            if self.animation == 'djumpup' or self.animation == 'djumpdown' then
                self.energy = self.energy - (80*dt)
                self.yv = self.yv + (60*dt)
            end

            --Fix for holding ctrl on ground then jumping
            if self.se:detect(0,15)[1] and self.animation == 'jump' then
                self.energy = self.energy - 10
                self.yv = self.yv + (70*dt)
            end

            self.energy = self.energy - (120*dt)
            self.animation = 'jump' --change to dive later

        end
    end

    --kunai spawning
    if self.kunaiAni < 18 and self.energy > 20 and Kunais > 0 and (love.keyboard.isDown("e") or love.mouse.isDown(1)) then
        self.kunaiAni = 40
        self.energy = self.energy - 12
        --self.animation = 'none' --change to throwing animation later
    end

    --directional inputs
    self.facing = 0

    --high traction on the ground
    if self.onGround then
        if (love.keyboard.isDown("a" or love.keyboard.isDown("left"))) and self.onWall~=-1 then
            self.xv = self.xv - 30*dt
            self.facing = -1
            self.animation = 'run'
            if self.maxSpd < 3 then
                self.maxSpd = self.maxSpd + 1*dt
            end
        elseif (love.keyboard.isDown("d" or love.keyboard.isDown("right"))) and self.onWall~=1 then
            self.xv = self.xv + 30*dt
            self.facing = 1
            self.animation = 'run'
            if self.maxSpd < 3 then
                self.maxSpd = self.maxSpd + 1*dt
            end
        end

        --slide
        if (self.slide > 0 and self.se:detect(0,-90)[1] and self.energy > 5) or ((love.keyboard.isDown("s") or love.keyboard.isDown("down")) and (self.xv > 1.25 or self.xv < -1.25) and self.energy > 20 and (self.slide <= 0 or self.slide > 200)) then
            self.col = {12,-40,30,-25}
            if self.timeOnGround < 15 and self.slideMult == 0 then
                self.slideMult = 1.75
                self.maxSpd = 4
            else
                self.slideMult = 1
                self.maxSpd = 3.5
            end
            if self.xv > 0 and self.xv < self.maxSpd then
                self.xv = self.xv + 20*dt*self.slideMult
            elseif self.xv < 0 and self.xv > -self.maxSpd then
                self.xv = self.xv - 20*dt*self.slideMult
            end
            if self.slide <= 0 then
                self.xv = self.xv * (1.5*self.slideMult)
                self.slide = 280
            end
        else
            self.col = {12,-100,30,-25}
        end
        if self.slide > 0 then
            self.slide = self.slide - (dt*240)
            if self.slide < 225 then
                if self.se:detect(0,-90)[1] and self.energy > 0 then
                    self.slide = 255
                    self.energy = self.energy + (40*dt)
                else
                    self.slideMult = 0
                    self.animation = 'run'
                end

            else
                self.energy = self.energy - (80*dt)
                self.animation = 'slide'
            end
        end

        --slide cancels when you're not moving
        if self.slide > 0 and math.abs(self.xv) < 1 then
            self.slide = self.slide - (1200*dt)
        end

        --Ground friction
        self.xv = self.xv * 0.0001^dt

        --Reset max speed if not moving
        if self.facing == 0 or (self.facing / self.xv) < 0 then
            self.maxSpd = 2.1
        end


    --in the air
    else
        self.col = {12,-100,30,-25}
        if self.maxSpd > 2.75 then
            self.maxSpd = self.maxSpd - (0.5*dt)
        end
        if self.maxSpd < 2.6 then
            self.maxSpd = self.maxSpd + (0.5*dt)
        end

        --air movement
        if (love.keyboard.isDown("a" or love.keyboard.isDown("left"))) then
            self.xv = self.xv - 4.5*dt
            self.facing = -1

        elseif (love.keyboard.isDown("d" or love.keyboard.isDown("right"))) then
            self.xv = self.xv + 4.5*dt
            self.facing = 1
        end
        self.xv = self.xv * 0.25^dt 
    end

    --enforce speed cap
    if self.xv > self.maxSpd then
        self.xv = self.xv - 8*dt
    end
    if self.xv < - self.maxSpd then
        self.xv = self.xv + 8*dt
    end
    if self.maxSpd > 3.05 then
        self.maxSpd = self.maxSpd - (0.25*dt)
    end

    --forfeit floatiness with S
    if love.keyboard.isDown('s') then
        self.jCounter = 0
    end
    --maybe do something with W key here

    --apply gravity
    self.yv = self.yv + (self.gravity*dt*7.25)

    --stop if you're very slow & change animation
    if math.abs(self.xv)<0.4 and self.onGround and self.animation~='landed' and self.animation~='hardlanded' then
        self.animation = 'none'
        self.saveAni = 'none'
    end
    if math.abs(self.xv)<0.1 and self.onGround then
        self.xv = self.xv * self.xv
    end

    --cancel wall animations if on ground
    if self.onWall==-1 then
        self.xv = math.max(0,self.xv)
        if self.onGround then
            self.animation = 'none'
        end
    end
    if self.onWall==1 then
        self.xv = math.min(0,self.xv)
        if self.onGround then
            self.animation = 'none'
        end
    end

    --switch to falling animation if you become airborne suddenly
    if self.animation == 'run' and not self.onGround then
        self.animation = 'falling'
    end

    --set display facing used for animations
    if self.facing~=0 then
        self.dFacing = self.facing
    end

    --cap on vertical speed
    if self.yv < -3.5 or self.yv > 8.75 then
        self.yv = self.yv * 0.1^dt
    end

    --updating xpos and ypos (maybe implement quartersteps later?)
    
    local p = self:animate(dt)
    return
end

function Player:tostring()
    return "Player at x="..self.xpos.." y="..self.ypos
end
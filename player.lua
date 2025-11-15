--!file: player.lua
--generic player class

Player = Object:extend()
require "sensor"
require "particle"
require "lib.extraFunc"
require "lib.playerCollision"

local plStats = {
    singleJump = 0.55, --yv
    jumpExt = 22, --*dt
    hoverMul = 0.00015, --^dt, yv mult when hovering
    dblJumpY = 3.5, --yv
    dblJumpX = 1.25, --xv increase when double jump
    jCounterG = 0.25, --gravity multiplier when in jcounter
    wallSlide = 0.125, --^dt
    wallJumpY = -3.75, --yv
    wallJumpX = 2.75, --xv
    diveInitX = 4, --initial xv on dive press
    diveInitY = -0.75, --initial yv on dive press
    diveConY = 1.75, --*dt
    groundAcc = 17.5, --*dt*speedMult
    airAcc = 4.5, --*dt
    slideAcc = 18, --*dt*slideMult
    slideMaxSpd = 3.6,

}

function Player:new(x,y)
    --position
    self.xpos = x
    self.ypos = y
    self.xv = 0
    self.yv = 0
    self.facing = 0
    self.dFacing = 1

    --energy
    self.energy = {25,75}
    self.remEnergy = 100
    self.eRegen = {0,0}

    --variables
    self.gravity = 1
    self.jCounter = 0
    self.spinnyTimer = 0
    self.airSpinnies = 0
    self.abilities = {jump=1,jumpext=15,djump=0,dive=2,spinny=2}
    self.wallClimb = false
    self.timeOnGround = 0
    self.onGround = true
    self.timeOffWall = 0
    self.kunaiInnacuracy = 0

    --self counter
    self.counter = 0

    --slide mechanics
    self.slide = 0
    self.slideMult = 0

    --Hitbox & iframes
    self.iFrame = 0
    self.squished = {0,0,0} --number of squished enemies in a row, timer, cooldown

    --Images
    self.img = ''
    self.imgPos = {'',0}
    self.camBox = nil --init position off the map

    --display characteristics
    self.dFacing = 1
    self.animation = 'falling'
    self.nextAni = 'none'
    self.aniFrame = 1
    self.aniTimer = 0
    self.aniiTimer = 0

    self.speedMult = 1
    self.saveDt = 0

    --misc
    self.maxSpd = 2.5
    self.kunaiAni = -1
    self.lastDir = {'',0}
    self.diveDir = 0

    --sensor
    self.se = Sensor(self)
    self.col = {12,-100,30,-25} --bottom, top, right, left, 1,2,3,4

end

function Player:animate(dt)
    self.counter = self.counter + (dt*60)
    
    if self.aniTimer > 0 then
        self.aniTimer = self.aniTimer - (60*dt)
    end
    if self.aniiTimer > 0 then
        self.aniiTimer = self.aniiTimer - (60*dt)
    end

    --Tumble Landing

    --Normal Landing
    if self.animation == 'landed' then
        if self.aniTimer < 0 then
            self.animation = 'none'
        end
        self.img = love.graphics.newImage("image/Aria/land.png")
        self.imgPos = {-36,-94}

    --Hard landing (11 frame animation that must play out)
    elseif self.animation == 'hardlanded' then
        if self.aniTimer < 0 then
            self.animation = 'none'
        end
        if self.aniTimer > 11 then
            self.img = love.graphics.newImage("image/Aria/hardland1.png")
            self.imgPos = {-34,-94}
        elseif self.aniTimer > 7 then
            self.img = love.graphics.newImage("image/Aria/hardland2.png")
            self.imgPos = {-32,-66}
        else
            self.img = love.graphics.newImage("image/Aria/hardland3.png")
            self.imgPos = {-26,-94}
        end

    --Phone Call

    --Ground Animations

    elseif self.onGround then
        self.nextAni = 'none'

        --Slide loop
        if self.animation == 'slide' and math.abs(self.xv) > 0.5 then
            if self.slide > 221 then
                if self.counter%12 < 6 then
                    self.img = love.graphics.newImage("image/Aria/slide1.png")
                else
                    self.img = love.graphics.newImage("image/Aria/slide2.png")
                end
                self.imgPos = {-36,-86}
            
            --slide exit transition
            else
                if self.slide > 210 then
                    self.img = love.graphics.newImage("image/Aria/slideout1.png")
                elseif self.slide > 200 then
                    self.img = love.graphics.newImage("image/Aria/slideout2.png")
                end
                self.imgPos = {-36,-86}

            end
        
        --Run (17 frame animation)
        elseif self.animation == 'run' or math.abs(self.xv) > 0.5 then
            if self.aniTimer < 0 then
                self.aniFrame = self.aniFrame + 1
                if self.aniFrame == 12 then
                    self.aniFrame = 1
                    table.insert(Particles,Particle(self.xpos,self.ypos,'run',self.dFacing))
                end
                if self.aniFrame == 6 then
                    table.insert(Particles,Particle(self.xpos,self.ypos,'run',self.dFacing))
                end
                self.aniTimer = math.max(4,(7-math.abs(self.xv)))
            end

            --Grab correct frame
            self.img = love.graphics.newImage("image/Aria/run"..self.aniFrame..".png")
            self.imgPos = {-36,-94}

        --Idle (4 frame loop)
        elseif self.animation == 'none' then
            if self.counter%60 < 16 then
                self.img = love.graphics.newImage("image/Aria/idle1.png")
            elseif self.counter%60 < 31 then
                self.img = love.graphics.newImage("image/Aria/idle2.png")
            elseif self.counter%60 < 46 then
                self.img = love.graphics.newImage("image/Aria/idle3.png")
            else
                self.img = love.graphics.newImage("image/Aria/idle4.png")
            end
            self.imgPos = {-26,-108}
        end
    
    --Air Animations
    else

        --Hover
        if self.animation == 'hover' then
            self.nextAni = 'low'
            self.aniiTimer = 11
            self.animation = 'none'
            if self.aniTimer < 0 then
                self.aniFrame = self.aniFrame + 1
                self.aniTimer = 6
            end
            if self.aniFrame > 2 then
                self.aniFrame = 1
            end
            self.img = love.graphics.newImage("image/Aria/hovern"..self.aniFrame..".png") 
            self.imgPos = {-31,-102}
    

        --Air Transitions (awful coding)
        elseif self.yv > -0.5 and (self.nextAni=='high' or self.nextAni=='low') and not self.onGround then --if we have a queued animation
            
            --high transition after jump
            if self.aniiTimer < -1 then
                self.aniiTimer = 13
            end
            if self.nextAni == 'high' then
                if self.aniiTimer < 2 then
                    self.nextAni = 'none'
                    self.animation = 'falling'
                end
                --after 3 frames, go to standard falling animation
                if self.aniiTimer > 7 then
                    self.img = love.graphics.newImage("image/Aria/jumptrans1.png")
                    self.imgPos = {-33,-108}
                else
                    self.img = love.graphics.newImage("image/Aria/jumptrans2.png")
                    self.imgPos = {-33,-116}
                end

            --low transition after hover or dive jump
            elseif self.nextAni == 'low' then
                if self.aniiTimer < 0 then
                    self.nextAni = 'none'
                    self.animation = 'falling'
                end
                --after 3 frames, go to standard falling animation
                if self.aniiTimer > 7 then
                    self.img = love.graphics.newImage("image/Aria/lowtrans1.png")
                    self.imgPos = {-29,-106}
                else
                    self.img = love.graphics.newImage("image/Aria/lowtrans2.png")
                    self.imgPos = {-31,-112}
                end
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
                    self.img = love.graphics.newImage("image/Aria/wallslide.png")
                else
                    self.img = love.graphics.newImage("image/Aria/wallslide2.png")
                end
                if self.dFacing == 1 then
                    self.imgPos = {-24,-102}
                else
                    self.imgPos = {-28,-102}
                end
            end

            --Double Jump
            if self.animation == 'djump' then
                if self.aniTimer < 0 then
                    self.nextAni = 'low'
                    self.aniiTimer = 13
                end
                self.img = love.graphics.newImage("image/Aria/djump.png")
                self.imgPos = {-28,-106}
            
            --Single Jump
            elseif self.animation == 'jump' then
                self.nextAni = 'high'
                self.aniiTimer = 13
                self.aniTimer = 6
                if self.counter%30 < 16 then
                    self.img = love.graphics.newImage("image/Aria/jumpup1.png")
                else
                    self.img = love.graphics.newImage("image/Aria/jumpup2.png")
                end
                self.imgPos = {-31,-106}

            --Dive

            --Hover?

        --Falling Animations

            elseif self.nextAni == 'fastfall' then
                if self.aniTimer < 0 then
                    self.aniFrame = self.aniFrame + 1
                    self.aniTimer = math.floor(14-(1*self.yv))
                end
                if self.aniFrame > 3 then
                    self.aniFrame = 1
                end
                self.img = love.graphics.newImage("image/Aria/flail"..self.aniFrame..".png")
                self.imgPos = {-31,-146}

            elseif self.nextAni == 'fftrans' then
                if self.aniTimer < 0 then
                    self.nextAni = 'fastfall'
                end
                self.img = love.graphics.newImage("image/Aria/fftrans.png")
                self.imgPos = {-31,-146}

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
                self.img = love.graphics.newImage("image/Aria/falling"..self.aniFrame..".png")
                self.imgPos = {-41,-152}
            end
        end
    end

    --Kunai
    if self.nextAni == 'kunai' then
        self.imgPos = {-26,-100}
        if self.kunaiAni > 12 and self.kunaiAni < 14 then 
            self.nextAni = 'low'
        elseif self.kunaiAni > 4 then
            self.img = love.graphics.newImage("image/Aria/kunaithrow1-2.png")
        elseif self.kunaiAni > 0 then
            self.img = love.graphics.newImage("image/Aria/kunaithrow1-1.png")
        end
    end

    --Spinny
    if self.animation == 'spinny' or self.nextAni == 'spinny' then
        self.nextAni = 'spinny'
        if self.aniTimer < 0 then
            self.nextAni = 'low'
            if self.onGround then --fix to end the animation earlier when grounded
                self.animation = 'none'
            else
                self.animation = 'falling'
            end
            self.aniiTimer = 4
        end
        if self.aniTimer >= 10 then
            self.img = love.graphics.newImage("image/Aria/spinnyR.png")
            self.imgPos = {-36,-106}
        elseif self.aniTimer >= 5 then
            self.img = love.graphics.newImage("image/Aria/spinnyB.png")
            self.imgPos = {-36,-108}
        else
            self.img = love.graphics.newImage("image/Aria/spinnyL.png")
            self.imgPos = {-36,-106}

        end
    end
end

function Player:update(dt)
    self.saveDt = dt
    
    if self.spinnyTimer > 0 then
        self.spinnyTimer = self.spinnyTimer - (dt*10)
    end

    --Prevent energy from going out of bounds
        if self.energy[1]>25 then self.energy[1]=25 end
        if self.energy[1]<0 then self.energy[1]=0 end
        if self.energy[2]>75 then self.energy[2]=75 end
        if self.energy[2]<0 then self.energy[2]=0 end

    --Non-solid collision
    for i = self.col[2]+8,self.col[1]-8,24 do
        for j = self.col[4],self.col[3],27.5 do

            --Nonsolid player collision detection
            local ret = self.se:detect(j,i)
            PlColDetect(ret[2],ret[3],dt)

            --Slide hitbox
            if self.slide > 180 and GameCounter > self.iFrame then
                local e = self.se:detectEnemy(j,i,'all')
                if e[1] and e[2].health > 0 then
                    self.slide = self.slide + 60 --extend slide time
                    e[2].health = 0
                    e[2].deathMode = 'kicked'
                end

            --Hitbox for getting hurt
            elseif GameCounter > self.iFrame then
                local e = self.se:detectEnemy(j,i,'hurt')
                if e[1] and e[2].deathMode == 0 then
                    self.xv = (self.dFacing * -0.5) + (e[2].xv/1.25)
                    self.yv = love.math.random()-3
                    --Hurt player
                    --self.animation = 'hurt'
                    local dmgAmt = 1
                    for x=#Health,1,-1 do
                        dmgAmt = Health[x]:takeDmg(dmgAmt)
                    end
                    self.iFrame = GameCounter + 1
                end
            end
        end
    end

    --Reset squish
    if self.squished[2] < GameCounter then
        self.squished[1] = 0
    end

    --Quarterstep Updating
    self.colliderCount = {bottom = 0, left = 0, right = 0, up = 0}
    for j=1,StepSize,1 do
        self.xpos = self.xpos + self.xv*(dt*(240/StepSize)) --230/2
        self.ypos = self.ypos + self.yv*(dt*(240/StepSize))

        --Down collision Detection
        for i = -19, 27, 4 do

            --Enemy (jump on head)
            local e = self.se:detectEnemy(i,self.col[1],'top') --Check collision with the top of enemies
            if e[1] and e[2].health > 0 and GameCounter > self.iFrame then --Can't hit an enemy when you're in iframes
                self.animation = 'jump'
                self.nextAni = 'high'
                self.abilities['jumpext'] = 0
                self.abilities['djump'] = 0
                self.xv = self.xv * 0.875
                self.jCounter = 8 --highest non-spinny jCounter, gives you time to maneuver in air

                --Bounce off enemy
                self.yv = -3.5
                
                --Kill enemy
                e[2].health = 0
                e[2].deathMode = 'squish'

                --Set squishtimer
                if self.squished[3] < GameCounter then
                    self.squished[1] = self.squished[1] + 1
                    self.squished[2] = GameCounter + 1.25
                    if self.squished[1] >= 3 then
                        table.insert(Health,Heart(5,1))
                        HeartJumpCounter = -1000 --Jump hearts
                        self.squished[3] = GameCounter + 6 --6 second cooldown between getting hearts this way
                    end
                end
                break
            end

            --Solid block
            if self.se:detect(i, self.col[1])[1] then
                self.colliderCount['bottom'] = self.colliderCount['bottom'] + 1
            end
        end

        --Right detection
        for i = self.col[2]+10, 0, 8 do
            if self.se:detect(self.col[3],i)[1] then
                self.colliderCount['right'] = self.colliderCount['right'] + 1
            end
        end

        --Left Detection
        for i = self.col[2]+10, 0, 8  do
            if self.se:detect(self.col[4],i)[1] then
                self.colliderCount['left'] = self.colliderCount['left'] + 1
            end
        end

        --Up Detection
        for i = -17, 25, 21 do
            if self.se:detect(i, self.col[2])[1] then
                self.colliderCount['up']= self.colliderCount['up'] + 1
            end
        end

        --Stop quarterstepping if we hit something (also lets us count up right/left detectiosns for wall jumps)
        for i,v in pairs(self.colliderCount) do
            if v > 0 then
                break
            end
        end
    end

    --If you're on the ground
    if self.colliderCount['bottom'] > 0 then

        --Energy Calculations (1 is LTO, 2 is Li-Ion)
        if self.energy[1] < 4 then
            self.eRegen[1] = self.energy[1]/20
        elseif self.energy[1] < 17.5 then
            self.eRegen[1] = 0.2
        else
            self.eRegen[1] = math.max(0.01,(22.5-self.energy[1])/25)
        end

        if self.energy[2] < 4 then
            self.eRegen[2] = self.energy[2]/45
        elseif self.energy[2] < 60 then
            self.eRegen[2] = 0.08
        else
            self.eRegen[2] = math.max(0.01,(75-self.energy[2])/190)
        end

        --Silver Heart calculation
        for i=1,#Health,1 do
            if Health[i].type == 3  then
                self.eRegen[1] = self.eRegen[1] * 1+(0.02*Health[i].amt)
                self.energy[1] = self.energy[1] + (4*dt) * (100-self.energy[1])/100 * Health[i].amt
            end
        end

        --don't sink into the ground
        for i=-19,27,4 do
            if self.se:detect(i, self.col[1]-0.5)[1] then
                self.ypos = self.ypos - 0.5
            end
        end

        --first frame on ground
        if self.onGround == false then
            self.ypos = self.ypos + (dt*120) --make sure we're actually touching the ground
            self.airSpinnies = 0 --reset increasing spinny cost in the air
            self.energy[1] = self.energy[1] + (self.eRegen[1]+self.eRegen[2]) --restore a bit of energy when you first hit the ground
            if self.yv > 0.5 and self.yv < 4.5 then
                self.animation = 'landed'
                self.aniTimer = 1+math.floor(self.yv*2.5)
            elseif self.yv > 4.5 then --Deal fall damage at high speeds
                self.aniTimer = 21
                self.animation = 'hardlanded'
                self.maxSpd = 1.5
                local dmgAmt = 0
                if self.yv > 7.125 then
                    dmgAmt = 3
                elseif self.yv > 6.375 then
                    dmgAmt = 2
                elseif self.yv > 5.375 then
                    dmgAmt = 1
                end
                for i=#Health,1,-1 do --Actually do damage
                    dmgAmt = Health[i]:takeDmg(dmgAmt)
                end
            end
            self.squished[1] = 0 --reset sequential squish
            self.squished[2] = -1
        end

        self.onGround = true
        self.timeOnGround = self.timeOnGround + dt

        --Fix for running off an edge with fastfall animation queued
        if self.nextAni == 'fftrans' or self.nextAni == 'fastfall' then
            self.nextAni = 'none'
        end

        --slowdown if you landed hard
        if self.animation == 'hardlanded' then
            self.xv = self.xv * 0.0075^dt
        end

        self.yv = 0
        self.gravity = 0

        --Reset abilities & jumps
        self.abilities['jump'] = 1 --jump
        self.abilities['jumpext'] = 15 --jump extension
        self.abilities['djump'] = 4 --double jump
        self.abilities['dive'] = 2 --dive

        --Add to energy while on ground based on eregen (not 1st frame)
        self.energy[1] = self.energy[1] + (150*dt*(self.eRegen[1]))+0.001
        self.energy[2] = self.energy[2] + (150*dt*(self.eRegen[2]))+0.001
    
    --If you're not on the ground
    else
        --Innacurate Knives while airborne
        self.kunaiInnacuracy = math.max(self.kunaiInnacuracy,9)

        --falling
        self.onGround = false
        self.timeOnGround = 0
        self.gravity = 1 --No jcounter if you run off an edge

        --slide off an edge
        if self.slide > 0 then
            self.slide = 0 --cancel slide
            self.jCounter = 5
            self.nextAni = 'low'
        end

        --Bonk your head on ceilings
        if self.colliderCount['up'] > 0 then
            self.yv = 0.1
            self.ypos = self.ypos + 1
            self.jCounter = 4
        end
    end

    --Energy calculations
    self.totalEnergy = sum(self.energy)
    self.energyQueue = 0

    --Set remEnergy (light gray bar)
    if self.totalEnergy < self.remEnergy then
        self.remEnergy = self.remEnergy - (dt + (self.remEnergy-self.totalEnergy)/400)
    else
        self.remEnergy = self.totalEnergy
    end

    --Reset variables
    self.onWall = 0
    self.WJEnabled = 0
    self.timeOffWall = self.timeOffWall + dt

    --Push out of right walls
    for i=1,StepSize,1 do
        if self.se:detect(self.col[3]-0.5,math.random(-90,2))[1] then
            self.xpos = self.xpos - (2/StepSize)
        end
    end

    --Collide right
    if self.colliderCount['right'] > 0 then
        self.onWall = 1
        self.timeOffWall = 0
        self.xv = 0
        if self.colliderCount['right'] > 6 then
            self.WJEnabled = 1
        end
    end

    --Push out of left walls
    for i=1,StepSize,1 do
        if self.se:detect(self.col[4]+0.5,math.random(-90,2))[1] then
            self.xpos = self.xpos + (2/StepSize)
        end
    end

    --Collide left
    if self.colliderCount['left'] > 0 then
        self.onWall = -1
        self.timeOffWall = 0
        self.xv = 0
        if self.colliderCount['left'] > 6 then
            self.WJEnabled = -1
        end
    end

    --Keybinds & Actions
    if love.keyboard.isDown(KeyBinds['Jump']) then
        --main single jump
        if self.abilities['jump'] > 0 then
            self.abilities['jump'] = 0
            self.jCounter = 4.5

            --Change YV
            self.yv = self.yv - plStats.singleJump
            if self.slide >= 190 then --jump higher while in slide, more towards the end of the window
                self.yv = self.yv - 0.125 - (275-self.slide)^3 / 750000
            end
            if math.abs(self.lastDir[2]) > 0.075 and math.abs(self.xv) < 0.75 and math.sign(self.xv) == -self.facing then --jump higher when you counterstrafe properly
                self.yv = self.yv - 0.675
                self.jCounter = 12
            end
            self.animation = 'jump'
            self.onGround = false
        end
        --jump extension
        if not self.onGround and self.abilities['jump']<=0 and self.abilities['jumpext']>0 and self.totalEnergy > 0.2 then
            self.yv = self.yv - (dt*plStats.jumpExt) - dt*math.abs(self.xv)*1.5
            if self.abilities['jumpext'] < 12.5 then
                self.energyQueue = self.energyQueue + (30*dt)
            end
            self.abilities['jumpext'] = self.abilities['jumpext'] - (120*dt)
        end

        --Creative hover
        if CreativeMode then
            if self.totalEnergy > 0.1 then
                self.yv = self.yv * 0.02^dt
                self.yv = self.yv - 24*dt
                self.xv = self.xv * math.exp(dt)
                self.abilities['dive'] = 2
                self.maxSpd = 6
                self.jCounter = 7
                self.energyQueue = self.energyQueue + (100-self.energyQueue)*(dt*4)
                self.animation = 'jump'
                self.aniTimer = 6
                self.aniiTimer = 6
            end
                
        --Normal hover
        else
            if self.yv > 0 and self.totalEnergy > 0.1 and self.animation~='djumpdown' and self.diveDir == 0 then
                self.yv = self.yv - 0.0125
                self.yv = self.yv * 0.0001^dt
                self.jCounter = 2
                self.energyQueue = self.energyQueue - (0.0625+(0.015*math.abs(self.xv)))*(150*dt)
                self.maxSpd = math.max(1.75,self.maxSpd-(self.maxSpd/1.5*dt))
                self.animation = 'hover'
            end
        end


        --double jump
        if (self.abilities['djump'] > 0 and self.abilities['djump'] < 4) and not self.onGround and not self.wallClimb and self.abilities['jump']<=0 and self.totalEnergy > 10 and not love.keyboard.isDown(KeyBinds['Dive']) then
            --cancel out some momentum to normalize double jump height
            if self.yv > 0 then
                self.yv = 0
            end
            if self.yv < -0.5 then
                self.yv = self.yv - (0.6*self.yv)
            end
            self.yv = self.yv - (plStats.dblJumpY)
            if self.abilities['dive'] ~= 2 then --slowdown if you jump after dive
                self.xv = self.xv * 0.65
                self.yv = self.yv * 0.4
                self.maxSpd = 1.9
            else
                self.xv = self.xv * 1.05
                self.maxSpd = math.max(self.maxSpd,2.6)
            end
            self.abilities['djump'] = 0
            self.energyQueue = self.energyQueue - 9
            self.jCounter = 4
            self.aniFrame = 1

            --adjust animation
            if self.animation ~= 'djump' then
                self.animation = 'djump'
                self.aniTimer = 8
            end
        end

    --logic when not pressing space
    else

        --lose single jump if you let go of space
        if self.abilities['jump'] > 0 and self.abilities['jump'] < 4 and not self.onGround then 
            self.abilities['jump'] = 0
            self.abilities['jumpext'] = 0
        end

        --activate double jump once you let go of space after normal jump
        if self.abilities['jump'] <= 0 and self.abilities['djump'] == 4 then 
            self.abilities['djump'] = 3
            self.abilities['jumpext'] = 0
        end

        --lose double jump if you let go early
        if self.abilities['djump'] > 0 and self.abilities['djump'] < 3 then
            self.abilities['djump'] = 0
        end

        --hop off wall
        self.wallClimb = false

        --slight hover at the end of jumps (burns jCounter)
        if self.yv > -1 and self.jCounter > 0 then
            self.energyQueue = self.energyQueue - (3*dt)
            self.jCounter = self.jCounter - (36*dt)
            self.gravity = plStats.jCounterG
        end

        --wall slide
        if not self.onGround and self.onWall~=0 and self.facing~=0 and self.totalEnergy > 1 then
            --limit fall speed
            self.yv = self.yv - 0.0025
            if self.yv > 0 then
                self.energyQueue = self.energyQueue - (6*dt)
            else
                self.energyQueue = self.energyQueue - (2*dt)
            end

            if self.yv > 1.5 then
                self.yv = self.yv * plStats.wallSlide^dt
            end
            if self.yv > 3 then
                self.yv = self.yv - (self.yv-3)/180
            end

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
        if self.wallClimb and self.totalEnergy > 6 and (((love.keyboard.isDown(KeyBinds['Left'])) and self.onWall == 1 and self.WJEnabled == 1) or ((love.keyboard.isDown(KeyBinds['Right'])) and self.onWall == -1 and self.WJEnabled == -1)) then
            self.yv = self.yv * 0.25
            self.yv = plStats.wallJumpY
            self.jCounter = 4
            self.xv = -self.onWall * plStats.wallJumpX
            self.xpos = self.xpos + self.dFacing * -6
            self.ypos = self.ypos - 1
            self.energyQueue = self.energyQueue - 6
            self.wallClimb = false
            self.abilities['dive'] = 2
            self.abilities['divejump'] = 2
            self.animation = 'jump' --change to walljump later
            self.lastDir[2] = self.lastDir[2]/4
        end
    end

    --Spinny
    if self.abilities['spinny'] > 0.5 and love.keyboard.isDown(KeyBinds['Spin']) and self.totalEnergy > 12.5 and self.onWall == 0 then --can't spinny while sliding on a wall
        --Aerial Spinny
        if not self.onGround then
            if self.abilities['spinny'] == 2 then --main spinny
                self.yv = (self.yv * 0.5) - 2.325
                self.xv = self.xv * 0.475
                self.abilities['spinny'] = 0
                self.jCounter = 20
                self.spinnyTimer = 8
                self.energyQueue = self.energyQueue - 10
                self.animation = 'spinny'
                self.aniTimer = 15
                for i=1,13,1 do --particles
                    table.insert(Particles,Particle(self.xpos+math.random(-80,80),self.ypos+math.random(-150,50),'sparkle',self.dFacing))
                end
                --End of routine
                self.airSpinnies = self.airSpinnies + 1
                self.abilities['dive'] = 0
                self.abilities['djump'] = 0

            end
            if self.abilities['spinny'] > 0.5 and self.abilities['spinny'] < 1.5 then --sub spinny
                self.yv = (self.yv * 0.875) - 0.875
                self.xv = self.xv * 0.8
                self.abilities['spinny'] = 0
                self.jCounter = 6
                self.spinnyTimer = 4
                self.energyQueue = self.energyQueue - (7.5 + self.airSpinnies*2.5)
                self.animation = 'spinny'
                self.aniTimer = 14
                
                --End of routine
                self.airSpinnies = self.airSpinnies + 1
                self.abilities['dive'] = 0
                self.abilities['djump'] = 0

            end
        
        --Grounded spinny
        elseif self.abilities['spinny'] == 2 and math.abs(self.xv) < 1 then
            self.xv = self.xv * 0.375
            self.jCounter = 20
            self.abilities['spinny'] = 0
            self.spinnyTimer = 4
            self.energyQueue = self.energyQueue - 12.5
            self.animation = 'spinny'
            self.aniTimer = 15
            for i=1,8,1 do --particles
                    table.insert(Particles,Particle(self.xpos+math.random(-80,80),self.ypos+math.random(-140,20),'sparkle',self.dFacing))
            end

        end
    end



    --Spinny Recharge
    if self.onGround then
        if self.abilities['spinny'] < 1.5 then
            self.abilities['spinny'] = self.abilities['spinny'] + dt*1.5
        elseif self.abilities['spinny'] >= 1.5 and self.abilities['spinny'] < 2 then
            table.insert(Particles,Particle(self.xpos,self.ypos,'hiccup',1,8))
            self.abilities['spinny'] = -10
        end
    else
        if self.abilities['spinny'] < 0.5 then
            self.abilities['spinny'] = self.abilities['spinny'] + dt*0.625
        else
            if self.abilities['spinny'] >= 0.5 and self.abilities['spinny'] < 1 then
                self.abilities['spinny'] = 1
            end
        end
    end

    --Spinny Hitbox
    if self.spinnyTimer > 0 then
        for i = -120,120,20 do
            for j = self.col[2],self.col[1],20 do
                local e = self.se:detectEnemy(i,j,'top')
                if e[1] and e[2].health > 0 then
                    self.xv = self.xv * 0.9
                    self.yv = self.yv - 0.25
                    self.jCounter = self.jCounter + 3
                    e[2].health = 0
                    e[2].deathMode = 'kicked'
                end
            end
        end
    end

    --dive
    if love.keyboard.isDown(KeyBinds['Dive']) and self.onWall == 0 and self.abilities['jumpext'] < 5 and self.totalEnergy > 5 and not self.onGround and self.timeOffWall > 0.25 then
        if self.abilities['dive'] > 0 and self.abilities['jump'] <= 0 and self.totalEnergy > 1 and self.onWall == 0 then
            if self.abilities['dive'] == 2 then
                self.energyQueue = self.energyQueue - 4
                self.yv = (self.yv+plStats.diveInitY) * 0.95
                self.diveDir = self.dFacing
            end
            --Adjust stats
            self.xv = self.diveDir * plStats.diveInitX
            self.dFacing = self.diveDir
            self.yv = self.yv * 0.4^dt
            self.yv = self.yv - plStats.diveConY*dt
            self.abilities['djump'] = 3
            self.abilities['dive'] = 1
            self.abilities['spinny'] = math.min(1,self.abilities['spinny']) --can't fully spinny after a dive
            self.maxSpd = plStats.diveInitX + 0.05
            self.energyQueue = self.energyQueue - (19*dt)
            self.animation = 'jump' --change to dive later
            self.aniiTimer = 6
            self.aniTimer = 6
        end
    else
        self.diveDir = 0
        if self.abilities['dive'] == 1 then
            self.abilities['dive'] = 0
        end
    end

    --Decrease kunaiInnacuracy
    if self.kunaiAni == -1 then
        self.kunaiInnacuracy = math.max(0,self.kunaiInnacuracy - (dt*40))
    else
        self.kunaiInnacuracy = math.max(0,self.kunaiInnacuracy - dt*(self.kunaiAni))
    end

    --Initiate Kunai
    if (self.kunaiAni == -1 or self.kunaiAni > 18) and self.totalEnergy > 20 and Kunais > 0 and love.keyboard.isDown(KeyBinds['Throw']) then
        
        --Increase innacruacy
        if self.kunaiAni == -1 then
            self.kunaiInnacuracy = self.kunaiInnacuracy + 6
        else
            self.kunaiInnacuracy = self.kunaiInnacuracy + (1-(self.kunaiInnacuracy/80))*(6 + (40-self.kunaiAni)*0.7)
        end

        self.kunaiAni = 0 --equal to KuAni, initiate main loop, l.09
        self.energyQueue = self.energyQueue - 10
        Kunais = Kunais - 1
        if self.kunaiAni > 18 then
            DKunais = Kunais
        end

        --Spawn kunai
        local tan = TanAngle(MouseX-(self.xpos-CameraX)*GameScale+(0.09*(self.kunaiInnacuracy+1))*(love.math.random()-0.5),MouseY-(self.ypos-CameraY)*GameScale+(0.09*(self.kunaiInnacuracy+1))*(love.math.random()-0.5))
        local dx = tan[1] + (0.05*(self.kunaiInnacuracy+1))*0.1*(love.math.random()-0.5)
        local dy = tan[2] + (0.05*(self.kunaiInnacuracy+1))*0.1*(love.math.random()-0.5)
        table.insert(Entities,Kunai(self.xpos,self.ypos-60,dx*30,dy*30))
    end

    --Update kunaiAnimation
    if self.kunaiAni ~= -1 then
        self.kunaiAni = self.kunaiAni + (60*dt)
        if self.kunaiAni < 9 then
            self.nextAni = 'kunai'

            --Turn around if you're shooting behind you
            if self.dFacing == 1 and MouseX < self.xpos-CameraX then
                self.dFacing = -1
            end
            if self.dFacing == -1 and MouseX > self.xpos-CameraX then
                self.dFacing = 1
            end
        end
    end
    if self.kunaiAni >= 40 then
        self.kunaiAni = -1
        DKunais = Kunais
    end

    --directional inputs
    self.facing = 0

    --high traction on the ground
    if self.onGround then    

        --Walk
        if love.keyboard.isDown(KeyBinds['Spin']) then
            self.speedMult = 1.4
            --Walk left on ground
            if love.keyboard.isDown(KeyBinds['Left']) and self.onWall~=-1 then
                self.xv = self.xv - plStats.groundAcc*dt*0.75
                self.facing = -1
                self.animation = 'run' --walk
                self.maxSpd = 1.3
                self.lastDir[1] = 'left'
                self.lastDir[2] = math.max(-0.25,self.lastDir[2] - dt/2)

            --Run right on ground
            elseif love.keyboard.isDown(KeyBinds['Right']) and self.onWall~=1 then
                self.xv = self.xv + plStats.groundAcc*dt*0.75
                self.facing = 1
                self.animation = 'run' --walk
                self.maxSpd = 1.3
                self.lastDir[1] = 'right'
                self.lastDir[2] = math.min(0.25,self.lastDir[2] + dt/2)
            end
        
        --Run
        else
            --Run left on ground
            if love.keyboard.isDown(KeyBinds['Left']) and self.onWall~=-1 then
                self.xv = self.xv - plStats.groundAcc*dt*self.speedMult*(self.maxSpd/2.9)
                self.facing = -1
                self.animation = 'run'
                if self.maxSpd < 2.2*self.speedMult and self.xv < -0.9*self.maxSpd then
                    self.maxSpd = self.maxSpd + 0.5*dt*self.speedMult
                end
                self.lastDir[1] = 'left'
                self.lastDir[2] = math.max(-0.25,self.lastDir[2] - dt)
                self.speedMult = math.min(1.4,self.speedMult+(dt/2))

            --Run right on ground
            elseif love.keyboard.isDown(KeyBinds['Right']) and self.onWall~=1 then
                self.xv = self.xv + plStats.groundAcc*dt*self.speedMult*(self.maxSpd/2.9)
                self.facing = 1
                self.animation = 'run'
                if self.maxSpd < 2.2*self.speedMult and self.xv > 0.9*self.maxSpd then
                    self.maxSpd = self.maxSpd + 0.5*dt*self.speedMult
                end
                self.lastDir[1] = 'right'
                self.lastDir[2] = math.min(0.25,self.lastDir[2] + dt)
                self.speedMult = math.min(1.4,self.speedMult+(dt/2))
            else
                self.speedMult = 1
            end
        end
        
        --slide (1st case is for continuing slide, 2nd case is for starting slide)
        self.slide = math.max(-1,self.slide-(dt*240))
        --Start slide
        if (love.keyboard.isDown(KeyBinds['Slide']) and self.slide <= 0 and math.abs(self.xv)>1.125) then
            self.slide = 275
            self.xv = self.xv * 1.75
        end

        --Continue slide
        if self.slide > 200 and self.totalEnergy > 5 then
            self.col = {12,-40,30,-25} --shorten hitbox
            self.slideMult = 1.5
            self.maxSpd = plStats.slideMaxSpd
            if self.xv > 0 and self.xv < self.maxSpd then
                self.xv = self.xv + plStats.slideAcc*dt*self.slideMult
            elseif self.xv < 0 and self.xv > -self.maxSpd then
                self.xv = self.xv - plStats.slideAcc*dt*self.slideMult
            end

            --Slide under an obstacle
            if (self.se:detect(-19,-90)[1] or self.se:detect(27,-90)[1]) and self.totalEnergy > 1 then
                self.slide = math.min(230,self.slide+(dt*600))
            else
                self.energyQueue = self.energyQueue - (80*dt) --drain energy
            end
            self.animation = 'slide'
        else
            self.col = {12,-100,30,-25}
        end


        --slide cancels when you're not moving
        if self.slide > 0 and math.abs(self.xv) < 1 then
            self.slide = self.slide - (300*dt)
        end

        --Ground friction
        self.xv = self.xv * 0.0011^dt

        --Reset max speed if not moving
        if self.facing == 0 or (self.facing / self.xv) < 0 then
            self.maxSpd = 2.2
        end


    --in the air
    else
        self.speedMult = 1
        self.col = {12,-100,30,-25}

        --air movement
        if love.keyboard.isDown(KeyBinds['Left']) then
            self.xv = self.xv - plStats.airAcc*dt * (self.spinnyTimer>0 and 1.41 or self.jCounter>0 and 1.1 or 1)
            self.facing = -1
            self.lastDir[1] = 'left'
            self.lastDir[2] = math.max(-0.25,self.lastDir[2] - dt)
        elseif love.keyboard.isDown(KeyBinds['Right']) then
            self.xv = self.xv + plStats.airAcc*dt * (self.spinnyTimer>0 and 1.41 or self.jCounter>0 and 1.1 or 1)
            self.facing = 1
            self.lastDir[1] = 'right'
            self.lastDir[2] = math.min(0.25,self.lastDir[2] + dt)
        end
        self.xv = self.xv * 0.25^dt 
    end

    --enforce speed cap set by maxspd
    if self.xv > self.maxSpd then
        self.xv = self.xv - 8*dt
    end
    if self.xv < - self.maxSpd then
        self.xv = self.xv + 8*dt
    end

    --enforce absolute speed cap
    if self.xv > 6 then
        self.xv = self.xv - 20*dt
    end
    if self.xv < -6 then
        self.xv = self.xv + 20*dt
    end

    --Reduce maxspeed to the cap
    if self.maxSpd > 3.1 then
        self.maxSpd = self.maxSpd - (0.75*dt)
    end
    if self.maxSpd < 2.2 then
        self.maxSpd = self.maxSpd + (0.75*dt)
    end

    --forfeit floatiness with S
    if love.keyboard.isDown(KeyBinds['Slide']) then
        self.jCounter = 0
    end

    --apply gravity
    if self.yv < 0 then
        self.yv = self.yv + (self.gravity * dt * (GlobalGravity+1))
    else
        self.yv = self.yv + (self.gravity * dt * GlobalGravity)
    end

    --Pan camera back to normal if you're stopped
    self.lastDir[2] = self.lastDir[2] * math.min(1,math.max(0.07,(self.xv/2)+0.07))^dt

    --stop if you're very slow & change animation
    if math.abs(self.xv)<0.4 and self.onGround and self.animation~='landed' and self.animation~='hardlanded' then
        if self.spinnyTimer <= 0 then
            self.animation = 'none'
        end
        self.saveAni = 'none'
    end
    if math.abs(self.xv)<0.05 and self.onGround then
        self.xv = self.xv^2 * 6 --stop almost immediately
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
    if self.yv < -4 then
        self.yv = self.yv * 0.1^dt
    end
    if self.yv > 4 then
        self.yv = self.yv * 0.75^dt
    end
    if self.yv > 5 then
        self.yv = self.yv * 0.7^dt
    end

    --Handle energy queue
    if -self.energyQueue > self.energy[1] then
        self.energyQueue = self.energyQueue - self.energy[1]
        self.energy[1] = 0
    else
        self.energy[1] = self.energy[1] + self.energyQueue
        self.energyQueue = 0
    end

    if -self.energyQueue > self.energy[2] then
        self.energyQueue = self.energy[2]
        self.energy[2] = 0
    else
        self.energy[2] = self.energy[2] + self.energyQueue
        self.energyQueue = 0
    end

end

function Player:tostring()
    return "Player at x="..self.xpos.." y="..self.ypos
end

function Player:draw()
    --Draw Player & player shadow

    --Facing left
    if self.dFacing == -1 then
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.draw(self.img,(self.xpos-5-CameraX+self.imgPos[1])*GameScale,(self.ypos+10-CameraY+self.imgPos[2])*GameScale,0,-2*GameScale,2*GameScale,-self.imgPos[1],0)
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(self.img,(self.xpos-CameraX+self.imgPos[1])*GameScale,(self.ypos-CameraY+self.imgPos[2])*GameScale,0,-2*GameScale,2*GameScale,-self.imgPos[1],0)
    --Facing right
    else
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.draw(self.img,(self.xpos-5-CameraX+self.imgPos[1])*GameScale,(self.ypos+10-CameraY+self.imgPos[2])*GameScale,0,2*GameScale,2*GameScale,0,0)
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(self.img,(self.xpos-CameraX+self.imgPos[1])*GameScale,(self.ypos-CameraY+self.imgPos[2])*GameScale,0,2*GameScale,2*GameScale,0,0)
    end

    --Define cam box
    if self.camBox == nil and (math.abs(self.xv) < 0.2 and math.abs(self.yv) < 0.2) and self.onGround then
        self.camBox = {self.xpos, self.ypos}
    end
end
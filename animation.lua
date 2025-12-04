--file: animation.lua
-- handles phone animations & portraits

function PhoneAnimate(dt)

    if TriggerPhone then
        PhoneCounter = PhoneCounter + dt

        --Phone shakes (image)
        if UpdateCounter%2 == 0 then
            PhoneImg = love.graphics.newImage("image/Phone/phone"..round(1+(UpdateCounter%6)/2)..".png")
        end

        --Phone rings out at 8s
        if PhoneCounter > 8 then
            NextCall = 0
            TriggerPhone = false

        --Move phone back to corner at 7.5s
        elseif PhoneCounter > 7.5 then
            PhoneScale = math.min(4,PhoneScale + (4-PhoneScale)/20)
            PhoneX = PhoneX + (WindowWidth-(80*GameScale)-PhoneX)*(20*dt)
            PhoneY = PhoneY + ((10*GameScale)-PhoneY)*(20*dt)
        
        --Move phone to your head at 0.5s
        elseif PhoneCounter > 0.5 then
            PhoneScale = math.max(2,PhoneScale-dt*8)
            PhoneX = PhoneX + (((Pl.xpos-CameraX)*(GameScale*Zoom)-PhoneX-(16*GameScale*Zoom))+love.math.random(-12,12))*(8*dt)
            PhoneY = PhoneY + (((Pl.ypos-CameraY)*(GameScale*Zoom)-PhoneY-(175*GameScale*Zoom))+love.math.random(-12,12))*(8*dt)
        
        --Set phone to top right otherwise
        else
            PhoneX = WindowWidth-(80*GameScale)
            PhoneY = (10*GameScale)
        end

        --Collide
        if PointCollideRect(PhoneRect,MouseX,MouseY) then
            if (love.mouse.isDown(1)) or love.keyboard.isDown(KeyBinds['Throw']) then
                CallInit(NextCall)
            end
        end
    else

        --Set phone to the top right corner
        PhoneScale = 4
        PhoneImg = DefaultPhoneImg
        PhoneX = WindowWidth-(80*GameScale)
        PhoneY = (10*GameScale)

        --If hovering over the phone when not active
        if PointCollideRect(PhoneRect,MouseX,MouseY) then
            
            --Switch phone image
            PhoneImg = PausePhoneImg

            --Pause if phone is clicked on the top right corner
            if DebugPressed == false and NextCall == 0 and love.mouse.isDown(1) then
                DebugPressed = true
                if StateVar.state == 'menu' then
                    ResumeGame()
                else
                    PauseGame()
                end
            end
        end
    end
end

function PhoneDraw() --just handles the hover-over rectangle
    if PointCollideRect(PhoneRect,MouseX,MouseY) then
        love.graphics.setColor(1,0.5,0.5,0.6)
        love.graphics.rectangle('fill',PhoneX,PhoneY,15*GameScale*PhoneScale,40*GameScale*PhoneScale)
        love.graphics.setColor(1,1,1,1)
    end
end

function GlobalAnimate() --run once per frame at the very end of love.draw(), should handle anything with GlAni (stuff here goes on top of everything else)
    --Draw a box when quitting the game
    if StateVar.ani == 'quitting' then
        love.graphics.setColor(0,0,0,1)
        love.graphics.rectangle('fill',0,-20,WindowWidth,math.sqrt(0.5-GlAni)*(WindowHeight*math.sqrt(2)),20,20)
        if GlAni <= 0 then love.event.quit() end
        love.graphics.setColor(1,1,1,1)
    end

    --Box in from the right when starting
    if StateVar.ani == 'levelloadtrans' then
        love.thread.getChannel('status'):clear()
        love.graphics.setColor(0,0,0,1)
        local sigmoid = 1 / (1+math.exp(5-GlAni*14))
        love.graphics.rectangle('fill',sigmoid*WindowWidth,0,WindowWidth,WindowHeight,20,20)
        if GlAni <= 0 then LoadLevel(StateVar.substate) end
        love.graphics.setColor(1,1,1,1)
    end

    --Box from the top when exiting to main menu
    if StateVar.ani == 'totitle' then
        love.graphics.setColor(0,0,0,1)
        love.graphics.rectangle('fill', 0, 0, WindowWidth, WindowHeight*(0.5-GlAni)*2,20,20)
        if GlAni <= 0 then TitleScreen(true) StateVar.ani = 'none' end
        love.graphics.setColor(1,1,1,1)
    end


end
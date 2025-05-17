--!file: camera.lua
--handles camera movement

function normalCamera(mousex,mousey,dt,rxy)
    --get mouse position
    local Camx = mousex
    local Camy = mousey

    --adjust cam parameters
    local tx = Pl.xpos + (Pl.xv*60) + (Pl.dFacing*0) - (WindowWidth/(2*GameScale)) + (Camx-(WindowWidth/2))/(5*GameScale)
    local ty = -(WindowHeight/10) + Pl.ypos + (Pl.yv*10*GameScale) - (WindowHeight/(2*GameScale)) + (Camy-(WindowHeight/2))/(5*GameScale)
    if Pl.lastDir[1] == 'left' then
        tx = tx + math.min(200,math.max(-160,Pl.lastDir[2]*640))
    elseif Pl.lastDir[1] == 'right' then
        tx = tx + math.max(-200,math.min(160,Pl.lastDir[2]*640))
    end

    if love.keyboard.isDown(KeyBinds['Up']) then
        ty = ty - 110*GameScale
    end
    
    local remcx = CameraX
    local remcy = CameraY
    CameraX = CameraX + (tx-CameraX) * 7.5*dt + rxy*GameScale*(love.math.random()-0.5)
    CameraY = CameraY + (ty-CameraY) * 7.5*dt + rxy*GameScale*(love.math.random()-0.5)
    DiffCX = CameraX-remcx
    DiffCY = CameraY-remcy

    --Hud position
end

function hudSetup() 
    local hx = 0
    local hy = 0
    if Pl.xv ~= 0 or Pl.yv ~= 0 then
        table.insert(HudPremov,{Pl.xv+3*(love.math.random()-0.5),Pl.yv+3*(love.math.random()-0.5)})
    else
        table.insert(HudPremov,{Pl.xv*1.5,Pl.yv*1.5})
    end
    
    if #HudPremov > 60 then
        table.remove(HudPremov,1)
    end

    if #HudPremov > 1 then
        for i,v in ipairs(HudPremov) do
            hx = hx + (v[1]*i*2)
            hy = hy + (v[2]*i*2)
        end
        hx = hx/#HudPremov/16
        hy = hy/#HudPremov/16
    else
        hx = Pl.xv*4
        hy = Pl.yv*4
    end

    hy = -math.min(0,hy)
    return hx, hy

end
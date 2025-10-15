--!file: camera.lua
--handles camera movement

function normalCamera(mousex,mousey,dt,rxy)
    --get mouse position
    local Camx = mousex
    local Camy = mousey

    --adjust cam parameters
    local tx = Pl.xpos + (Pl.xv*70) + (Pl.dFacing*0) - (WindowWidth/(2*GameScale)) + (Camx-(WindowWidth/2))/(5*GameScale)
    local ty = -(WindowHeight/10) + Pl.ypos + (Pl.yv*10*GameScale) - (WindowHeight/(2*GameScale)) + (Camy-(WindowHeight/2))/(5*GameScale)
    
    --Move camera to the left or right when you move in that direction
    if Pl.lastDir[1] == 'left' then
        tx = tx + math.min(200,math.max(-160,Pl.lastDir[2]*640))
    elseif Pl.lastDir[1] == 'right' then
        tx = tx + math.max(-200,math.min(160,Pl.lastDir[2]*640))
    end

    --Move camera up if you hold up
    if love.keyboard.isDown(KeyBinds['Up']) then
        ty = ty - 115*GameScale
    end
    
    local remcx = CameraX
    local remcy = CameraY
    CameraX = CameraX + (tx-CameraX) * 6*dt + (0.007/dt)*rxy*GameScale*(love.math.random()-0.5)
    CameraY = CameraY + (ty-CameraY) * 7*dt + (0.007/dt)*rxy*GameScale*(love.math.random()-0.5)
    DiffCX = CameraX-remcx
    DiffCY = CameraY-remcy

    --Hud position
end

function hudSetup() 
    local hx = 0
    local hy = 0
    if StateVar.state == 'menu' then
        table.insert(HudMov,{0,0})
    elseif Pl.xv ~= 0 or Pl.yv ~= 0 then
        table.insert(HudMov,{Pl.xv+5*(love.math.random()-0.5),Pl.yv+5*(love.math.random()-0.5)}) --slight HUD shaking when you're running
    else
        table.insert(HudMov,{Pl.xv*1.5,Pl.yv*1.5})
    end
    
    if #HudMov > 60 then
        table.remove(HudMov,1)
    end

    if #HudMov > 1 then
        for i,v in ipairs(HudMov) do
            hx = hx + (v[1]*i*2)
            hy = hy + (v[2]*i*2)
        end
        hx = hx/#HudMov/16
        hy = hy/#HudMov/16
    else
        hx = Pl.xv*4
        hy = Pl.yv*4
    end

    hx = -hx
    hy = -math.min(0,hy)
    return hx, hy

end
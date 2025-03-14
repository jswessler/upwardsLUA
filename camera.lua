--!file: camera.lua
--handles camera movement

function normalCamera(mousex,mousey,dt,rxy)
    --get mouse position
    local Camx = mousex
    local Camy = mousey

    --adjust cam parameters
    local tx = Pl.xpos + (Pl.xv*60) + (Pl.dFacing*0) - (WindowWidth/(2*GameScale)) + (Camx-(WindowWidth/2))/(3*GameScale)
    local ty = -(WindowHeight/10) + Pl.ypos + (Pl.yv*10*GameScale) - (WindowHeight/(2*GameScale)) + (Camy-(WindowHeight/2))/(3*GameScale)
    if Pl.lastDir[1] == 'left' then
        tx = tx + math.min(200,math.max(-160,Pl.lastDir[2]*640))
    elseif Pl.lastDir[1] == 'right' then
        tx = tx + math.max(-200,math.min(160,Pl.lastDir[2]*640))
    end
    
    local remcx = CameraX
    local remcy = CameraY
    CameraX = CameraX + (tx-CameraX) * 7.5*dt + rxy*GameScale*(love.math.random()-0.5)
    CameraY = CameraY + (ty-CameraY) * 7.5*dt + rxy*GameScale*(love.math.random()-0.5)
    DiffCX = CameraX-remcx
    DiffCY = CameraY-remcy
end
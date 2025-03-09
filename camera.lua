--!file: camera.lua
--handles camera movement

function normalCamera(mousex,mousey,dt,rxy)
    --get mouse position
    Camx = mousex
    Camy = mousey

    --adjust cam parameters
    local tx = Pl.xpos + (Pl.xv*130) + (Pl.dFacing*100) - (WindowWidth/(2*GameScale)) + (Camx-(WindowWidth/2))/(3*GameScale)
    local ty = -(WindowHeight/10) + Pl.ypos + (Pl.yv*10*GameScale) - (WindowHeight/(2*GameScale)) + (Camy-(WindowHeight/2))/(3*GameScale)
    local remcx = CameraX
    local remcy = CameraY
    CameraX = CameraX + (tx-CameraX) * 5*dt + 0.2*GameScale*(love.math.random()-0.5) + rxy*GameScale*(love.math.random()-0.5)
    CameraY = CameraY + (ty-CameraY) * 7.5*dt + 0.2*GameScale*(love.math.random()-0.5) + rxy*GameScale*(love.math.random()-0.5)
    DiffCX = CameraX-remcx
    DiffCY = CameraY-remcy
    return


end
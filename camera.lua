--!file: camera.lua
--handles camera movement

function normalCamera(mousex,mousey,dt)
    --don't move camera as much if mouse is in the middle of the screen
    if mousex>4/10*WindowWidth and mousex<6/10*WindowWidth then
        Camx = (WindowWidth/2+mousex)/2
    else
        Camx = mousex
    end
    if mousey>4/10*WindowHeight and mousey<6/10*WindowHeight then
        Camy = (WindowHeight/2+mousey)/2
    else
        Camy = mousey
    end

    --adjust cam parameters
    local tx = Pl.xpos + (Pl.xv*120) + (Pl.dFacing*120) - (WindowWidth/2) + (Camx-(WindowWidth/2))/2.5
    local ty = -(WindowHeight/10) + Pl.ypos + (math.min(0,Pl.yv*24)) - (WindowHeight/2) + (Camy-(WindowHeight/2))/2.5
    local remcx = CameraX
    local remcy = CameraY
    CameraX = CameraX + (tx-CameraX) * 5*dt + 0.1*(math.random()-0.5)
    CameraY = CameraY + (ty-CameraY) * 8*dt + 0.1*(math.random()-0.5)
    DiffCX = CameraX-remcx
    DiffCY = CameraY-remcy
    return


end
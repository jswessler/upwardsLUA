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
        tx = tx + math.min(200,math.max(-200,Pl.lastDir[2]*400))
    elseif Pl.lastDir[1] == 'right' then
        tx = tx + math.max(-200,math.min(200,Pl.lastDir[2]*400))
    end
    
    local remcx = CameraX
    local remcy = CameraY
    CameraX = CameraX + (tx-CameraX) * 7.5*dt + 0.2*GameScale*(love.math.random()-0.5) + rxy*GameScale*(love.math.random()-0.5)
    CameraY = CameraY + (ty-CameraY) * 7.5*dt + 0.2*GameScale*(love.math.random()-0.5) + rxy*GameScale*(love.math.random()-0.5)
    DiffCX = CameraX-remcx
    DiffCY = CameraY-remcy
    return


end

function basicCam(mousex,mousey)
    --basicCam simply follows the Pl object

    local Cx = CameraX + (Pl.xpos-CameraX)/40 
    local Cy = CameraY + (Pl.ypos-CameraY)/40
    Cx = Cx + Pl.xv

    Cx = Cx + (mousex-(WindowWidth/2))/(3*GameScale)
    Cy = Cy + (mousey-(WindowHeight/2))/(3*GameScale)

    --move based on player direction (STOLEN FROM PAPER MARIO THOUSAND YEAR DOOR)
    if Pl.lastDir[1] == 'left' then
        Cx = Cx + math.max(-6,Pl.lastDir[2]*6)
    elseif Pl.lastDir[1] == 'right' then
        Cx = Cx + math.min(6,Pl.lastDir[2]*6)
    end

    --move based on mouse
    -- Cx = Cx + (mousex-(WindowWidth/2))/200
    -- Cy = Cy + (mousey-(WindowHeight/2))/200

    CameraX = Cx
    CameraY = Cy
end
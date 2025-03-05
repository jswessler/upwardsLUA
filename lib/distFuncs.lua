--!file: distFuncs.lua
--extra stuff


function getOnScreen()
    local xs = math.max(0, math.floor(CameraX-24))
    local xf = math.min(WindowWidth*32, math.floor(CameraX + WindowWidth + 24))
    local ys = math.max(0, math.floor(CameraY-24))
    local yf = math.min(WindowHeight * 32, math.floor(CameraY + WindowHeight + 24))
    local xl = {}
    local yl = {}
    while xs < xf do
        table.insert(xl,xs)
        xs = xs + 32
    end
    while ys < yf do
        table.insert(yl,ys)
        ys = ys + 32
    end
    return xl,yl
end

function tanAngle(relx,rely)
    local dir = math.atan(rely)
    local yf = math.sin(dir)
    local xf = math.cos(dir)
    return xf,yf,dir
end

function getDist(x1,y1,x2,y2)
    return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end


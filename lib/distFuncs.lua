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


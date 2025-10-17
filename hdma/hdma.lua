--!file: hdma.lua
--Generates HDMA style backgrounds from a text file containing instructions
--Function that takes in an index and frametime and outputs a canvas

HDMATable = { --horz = {strength, initial value, period (y offset to repeat), time period}
    [1] = {images = 'grass1', horz={strength = 2, init = 5, period = 50, time = 5}, vert={strength = 0, init = 0, period = 0, time = 0}}, --horizontal sway test
}

HDMAImages = {
    ['grass1'] = love.image.newImageData("hdma/images/grass1.jpg"),
    ['grass2'] = love.image.newImageData("hdma/images/grass2.jpeg"),
}


function HDMAInit(instIndex)
    HDMAImage = nil
    --HDMAImage = HDMAImages[HDMATable[instIndex].images]
    HDMAImage = love.image.newImageData("hdma/images/grass1.jpg")
end

function HDMA(instIndex,time)
    --Clear canvases
    love.graphics.setCanvas(HDMACanvas)
    love.graphics.clear()
    love.graphics.setCanvas(HDMATempCanvas)
    love.graphics.clear()

    --Setup values
    local width = HDMACanvas:getWidth()
    local height = HDMACanvas:getHeight()
    local data = love.image.newImageData(width,height)
    local inst = HDMATable[instIndex]

    --Loop through each pixel
    --For each pixel: move HDMATempCanvas according to instructions, get the pixel at x,y, and paste it onto HDMACanvas
    for y=0,height do
        for x=0,width do

            --Calculate x and y offsets to paste the image
            local xp = inst.horz.strength * (inst.horz.init*inst.horz.period) + inst.horz.time
            local yp = inst.vert.strength * (inst.vert.init*inst.vert.period) + inst.vert.time

            --Paste the image onto HDMATempCanvas
            love.graphics.setCanvas(HDMATempCanvas)
            love.graphics.clear()
            love.graphics.draw(love.graphics.newImage(HDMAImage),xp,yp,0,1,1)

            --Get image data from the canvas
            love.graphics.setCanvas(HDMACanvas)
            local dat = HDMATempCanvas:newImageData()

            --Extract the pixel color
            local r,g,b,a = dat:getPixel(x,y)

            --Draw the point onto the main canvas
            love.graphics.setColor(r,g,b,a)
            love.graphics.points(x,y)
            love.graphics.setColor(1,1,1,1)
        end
    end


    love.graphics.setCanvas(ScreenCanvas)
    love.graphics.draw(HDMACanvas,0,0,0,4,4)
end
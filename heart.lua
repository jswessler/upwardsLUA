--!file: heart.lua
--Health system

Heart = Object:extend()

--LITERALLY directly ported from python
function Heart:new(typ,amt)
    self.type = typ
    self.amt = amt
    self.yp = 0
    self.yv = 0 
    self.move = false
    if typ == 1 then
        self.fileExt = 'red'
        self.maxHp = 4
    elseif typ == 2 then
        self.fileExt = 'blue'
        self.maxHp = 4
    elseif typ == 3 then
        self.fileExt = 'silver'
        self.maxHp = 2
    elseif typ == 4 then
        self.fileExt = 'blood'
        self.maxHp = 1
    end
    self.img = ''
end

function Heart:update(dt)
    if self.move then
        self.yp = self.yp - self.yv * dt
        if self.yp < 0 then
            self.yp = 0
            self.yv = 0
            self.move = false
        end
        self.yv = self.yv + 70 * dt
    end
end

function Heart:takeDmg(amt)
    if amt == 0 then
        return 0
    elseif amt > self.amt then
        local ret = amt - self.amt
        amt = amt - self.amt
        self.amt = 0
        return ret
    else
        self.amt = self.amt - amt
        return 0
    end
end

function Heart:heal(amt)
    if self.type == 1 or self.type == 3 then
        if self.amt == self.maxHp then --if this heart is already full
            return amt
        else
            --Jump hearts
            self.yv = -3

            if amt + self.amt > self.maxHp then
                amt = amt - self.maxHp - self.amt
                self.amt = self.maxHp
                return amt
            else
                self.amt = self.amt + amt
                return 0
            end
        end
    else
        return amt
    end
end

function Heart:tostring()
    return self.fileExt.." Heart with "..self.amt.. " hits"
end

return Heart
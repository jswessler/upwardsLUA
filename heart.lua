--!file: heart.lua
--Health system

Heart = Object:extend()

--LITERALLY directly ported from python
function Heart:new(typ,amt)
    self.type = typ
    self.amt = amt
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

function Heart:takeDmg(amt)
    if amt > self.amt then
        local temp = self.amt
        amt = amt - self.amt
        self.amt = 0
        return temp
    else
        self.amt = self.amt - amt
        return 0
    end
end

function Heart:heal(amt)
    if self.type == 1 or self.type == 2 then
        if self.amt == self.maxHp then
            return amt
        elseif amt + self.amt > self.maxHp then
            amt = amt - self.maxHp - self.amt
            self.amt = self.maxHp
            return amt
        else
            self.amt = self.amt + amt
            return 0
        end
    else
        return amt
    end
end

function Heart:tostring()
    return self.fileExt.." Heart with "..self.amt.. " hits"
end

return Heart
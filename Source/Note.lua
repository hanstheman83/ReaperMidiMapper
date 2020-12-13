-- Is selected, midi index changing on edit, thus cannot update

-- auto update from Lua - keep track of midi changes ?

Note = { 
    length = 0, -- in msec
    startTime = 0,
    startppqpos = 0,
    endppqpos = 0,
    chan = 0,
    pitch = 0,
    vel = 0
}

function Note:New(o)
    o = o or {}
    self.__index = self
    setmetatable(o,self)
    return o 
end

function Note:CalculateLength()
    self.length = 0;
end


   
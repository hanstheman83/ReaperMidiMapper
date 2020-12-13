-- Is selected, midi index changing on edit, thus cannot update

-- auto update from Lua - keep track of midi changes ?

Note = { 
    startTime = 0,
    endTime = 0,
    startppqpos = 0,
    endppqpos = 0,
    chan = 0,
    pitch = 0,
    vel = 0,
    isInitialized = false
}

function Note:New(o)
    o = o or {}
    self.__index = self
    setmetatable(o,self)
    return o 
end

function Note:CalculateStartAndEndInProjTime(activeTake) -- in sec
    self.startTime = reaper.MIDI_GetProjTimeFromPPQPos(activeTake, startppqpos)
    self.endTime = reaper.MIDI_GetProjTimeFromPPQPos(activeTake, endppqpos)
    self.isInitialized = true
end

function Note:GetLengthInProjTime()
    if not self.isInitialized then 
        -- 
        reaper.MB("Note not initialized!","Note.lua error", 0)
        return 0
    end
    return self.endTime - self.startTime
    
end




   
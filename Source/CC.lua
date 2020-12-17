CC = {
    startTime = 0, -- 
    ppqpos = 0,
    chanmsg = 0,
    chan = 0,
    msg2 = 0,
    msg3 = 0,
    isMuted = false,
    isSelected = false,
    isInitialized = false
}

function CC:New(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

function CC:CalculateStartInProjTime(activeTake)
    self.startTime = reaper.MIDI_GetProjTimeFromPPQPos(activeTake, self.ppqpos)
    self.isInitialized = true
end

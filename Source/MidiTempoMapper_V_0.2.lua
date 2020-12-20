reaper.ClearConsole()

-- reaper.MB("Test","Mixer Toolbox",0)

-- Set path Lokasenna GUI
-- commandId = reaper.NamedCommandLookup("_RS1c6ad1164e1d29bb4b1f2c1acf82f5853ce77875")
-- reaper.Main_OnCommand(commandId, 0)

-- Lokasenna GUI
loadfile("C:/Users/pract/Documents/Repos/ReaperPlugins/Lua/GUILibrary/Core.Lua")()
loadfile("C:/Users/pract/Documents/Repos/ReaperPlugins/Lua/GUILibrary/Classes/Class - Button.Lua")()
loadfile("C:/Users/pract/Documents/Repos/ReaperPlugins/Lua/GUILibrary/Classes/Class - Frame.Lua")()
loadfile("C:/Users/pract/Documents/Repos/ReaperPlugins/Lua/GUILibrary/Classes/Class - Knob.Lua")()
loadfile("C:/Users/pract/Documents/Repos/ReaperPlugins/Lua/GUILibrary/Classes/Class - Label.Lua")()
loadfile("C:/Users/pract/Documents/Repos/ReaperPlugins/Lua/GUILibrary/Classes/Class - Listbox.Lua")()
loadfile("C:/Users/pract/Documents/Repos/ReaperPlugins/Lua/GUILibrary/Classes/Class - Menubar.Lua")()
loadfile("C:/Users/pract/Documents/Repos/ReaperPlugins/Lua/GUILibrary/Classes/Class - Menubox.Lua")()
loadfile("C:/Users/pract/Documents/Repos/ReaperPlugins/Lua/GUILibrary/Classes/Class - Options.Lua")()
loadfile("C:/Users/pract/Documents/Repos/ReaperPlugins/Lua/GUILibrary/Classes/Class - Slider.Lua")()
loadfile("C:/Users/pract/Documents/Repos/ReaperPlugins/Lua/GUILibrary/Classes/Class - Tabs.Lua")()
loadfile("C:/Users/pract/Documents/Repos/ReaperPlugins/Lua/GUILibrary/Classes/Class - Textbox.Lua")()
loadfile("C:/Users/pract/Documents/Repos/ReaperPlugins/Lua/GUILibrary/Classes/Class - TextEditor.Lua")()
loadfile("C:/Users/pract/Documents/Repos/ReaperPlugins/Lua/GUILibrary/Classes/Class - Window.Lua")()
loadfile("C:/Users/pract/Documents/Repos/ReaperPlugins/Lua/GUILibrary/Modules/Window - GetUserInputs.Lua")()

-- Custom L-GUI

-- Extra Classes
loadfile("C:/Users/pract/Documents/Repos/ReaperPlugins/Lua/MidiTempoMapper/Source/Note.lua")()
loadfile("C:/Users/pract/Documents/Repos/ReaperPlugins/Lua/MidiTempoMapper/Source/CC.lua")()

-- local Notes = require "classes"

local helper = dofile "C:/Users/pract/Documents/Repos/ReaperPlugins/Lua/MidiTempoMapper/Source/HelperFunctions.lua"

----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------

---[[
----------- Main 
local oldTime = os.time();
local updateTime = 1 -- in sec, cant go lower. Could count frames
local exitChar = 0
--]]

---[[
---------- GUI Ini
local guiName = "Midi Tempo Mapper - Version 0.1"
local guiHeight = 200
local guiWidth = 500

-- Buttons

-- variables
local timeMap
local time_new
local time_zero
local listSelectedNotes
local listAllItems

--]]




---------- 


------------------------------------------------------
---------------- Functions --------------------------
-----------------------------------------------------

local function Msg(param) 
    reaper.ShowConsoleMsg(tostring(param).."\n")
end

--------------- For CalculateBPM() -----------------
local function GetTimeN(activeTake, startppqpos)
    local ppqNextMeasure = reaper.MIDI_GetPPQPos_EndOfMeasure(activeTake, startppqpos)
    return reaper.MIDI_GetProjTimeFromPPQPos(activeTake, ppqNextMeasure)
end

local function CalculateTimeMapFromQuarterNotes(quarterNotesList)
    -- create list start 1st note to start 2nd note
    local timeMap = {};
    local distanceStartToStart
    local startLastNote
    local timeMapIndex = 1
    for i, n in ipairs(quarterNotesList) do 
        if i ~= 1 then
            distanceStartToStart = n.startTime - startLastNote -- beat length in sec
            timeMap[timeMapIndex] = { ["time"] = startLastNote, ["BPM"] = 60/distanceStartToStart} -- calc BPM
            timeMapIndex = timeMapIndex + 1
        end
        startLastNote = quarterNotesList[i].startTime
    end
    -- return timemap : time in sec, BPM
    return timeMap
end

local function GetProjTimeNextMeasure(activeTake, note)
    local startPPQNextMeasure = reaper.MIDI_GetPPQPos_EndOfMeasure(activeTake, listSelectedNotes[1].startppqpos) 
    -- Msg("Start ppq next measure "..startPPQNextMeasure)
    return reaper.MIDI_GetProjTimeFromPPQPos(activeTake, startPPQNextMeasure) 
end

local function GetListAllMidiNotesInItem(item)
    local activeTake = reaper.GetMediaItemTake(item, 0) -- TODO preserve all takes..
    local listAllNotes = {} -- lua index starts at 1
    local retval = reaper.MIDI_GetNote(activeTake, 0) -- bool, check there is a 1st note in take
    local currentNoteIdx = 0
    local midiNote

    while retval do
        midiNote = Note:New()
        retval, midiNote.isSelected, midiNote.isMuted,
        midiNote.startppqpos, midiNote.endppqpos, 
        midiNote.chan, midiNote.pitch, midiNote.vel = reaper.MIDI_GetNote(activeTake, currentNoteIdx)
        -- Msg("Note "..tostring(currentNoteIdx+1).." Start pos "..midiNote.startppqpos)
        -- Msg("retval "..tostring(retval))
        midiNote:CalculateStartAndEndInProjTime(activeTake) -- Ini note
        listAllNotes[currentNoteIdx+1] = midiNote -- lua index starts at 1
        currentNoteIdx = currentNoteIdx + 1
        retval = reaper.MIDI_GetNote(activeTake, currentNoteIdx)
    end
    return listAllNotes
end

local function GetListAllCCInItem(item)
    local listAllCC = {}
    local activeTake = reaper.GetMediaItemTake(item, 0) -- TODO preserve all takes..
    local retval = reaper.MIDI_GetCC(activeTake, 0)
    local currentCC_Idx = 0
    local cc

    while retval do 
        cc = CC:New()
        retval, cc.isSelected, cc.isMuted, cc.ppqpos, cc.chanmsg, 
        cc.chan, cc.msg2, cc.msg3 = 
        reaper.MIDI_GetCC(activeTake, currentCC_Idx)
        retval, cc.shape, cc.beztension = reaper.MIDI_GetCCShape(activeTake, currentCC_Idx) -- add bezier shape and tension to cc
        listAllCC[currentCC_Idx+1] = cc
        cc:CalculateStartInProjTime(activeTake) -- ini CC
        currentCC_Idx = currentCC_Idx + 1
        retval = reaper.MIDI_GetCC(activeTake, currentCC_Idx) -- test if next cc exists
    end

    return listAllCC
end

local function CreateMidiNotesInNewItem(newMediaItem, timeOffset)
    -- local take = reaper.GetMediaItemTake(newMediaItem, 0)
    -- local startppqpos, endppqpos
    
    -- for i,n in ipairs(listAllNotes) do 
    --     startppqpos = reaper.MIDI_GetPPQPosFromProjTime(take, n.startTime + timeOffset)
    --     endppqpos = reaper.MIDI_GetPPQPosFromProjTime(take, n.endTime + timeOffset)
    --     reaper.MIDI_InsertNote(take, n.isSelected, n.isMuted, startppqpos, 
    --         endppqpos, n.chan, n.pitch, n.vel)
    -- end
end

local function CreateCC_DataInNewItem(newMediaItem, timeOffset)
    -- add shape : Lua: boolean reaper.MIDI_SetCCShape(MediaItem_Take take, integer ccidx, integer shape, number beztension, optional boolean noSortIn)




    -- local take = reaper.GetMediaItemTake(newMediaItem, 0)
    -- local ppqpos
    -- for i, cc in ipairs(listAllCC) do 
    --     ppqpos = reaper.MIDI_GetPPQPosFromProjTime(take, cc.startTime + timeOffset)
    --     wasInserted = reaper.MIDI_InsertCC(take, cc.isSelected, cc.isMuted, ppqpos, cc.chanmsg,
    --         cc.chan, cc.msg2, cc.msg3)
    --     --Msg("cc "..i.." inserted : "..helper.BoolToString(wasInserted)) -- inserts also before clip starts!
    --     -- TODO add correct shape to inserted cc
    -- end
end



-------------------------------------------------------------------
------------------------- UI Callbacks ----------------------------
-------------------------------------------------------------------

local function OnCalculateBPM_Pressed()
    -- Msg("Button Calculate BPM pressed")
    -- -- 
    -- local activeMidiEditor = reaper.MIDIEditor_GetActive()
    -- local activeTake = reaper.MIDIEditor_GetTake(activeMidiEditor) -- type MediaItem_Take
    -- listAllNotes = {} -- index starts at 1
    -- listSelectedNotes = {}
    -- listAllNotes, listSelectedNotes = GetListAllMidiNotesAndAllSelected(activeTake)
    -- listAllCC = GetListAllCC(activeTake) -- and initialize
    -- -- cc data 
    -- for i,cc in ipairs(listAllCC) do 
    --     Msg("CC with index "..i.." ")
    -- end

    -- InitializeNotesInList(activeTake, listAllNotes)

    -- -- TODO add more clips!

    -- -- TODO crashes when no notes selected
    -- time_new = GetTimeN(activeTake, listSelectedNotes[1].startppqpos) -- start new BPM from here.. // proj time in sec
    -- time_zero = reaper.MIDI_GetProjTimeFromPPQPos(activeTake, listSelectedNotes[1].startppqpos) -- // proj time in sec
    -- timeMap = CalculateTimeMapFromQuarterNotes(listSelectedNotes) -- all selected notes should be quarter notes.
    
    --[[
    Msg("TimeMap :")
    for i, timeBPM in ipairs(timeMap) do 
        Msg("index "..i)
        Msg("Has time : "..timeBPM["time"].." and BPM "..timeBPM["BPM"])
    end
    --]]
end

local function OnSetBPM_Pressed()
    -- Msg("Set BPM button pressed")
    -- local activeMidiEditor = reaper.MIDIEditor_GetActive()
    -- local activeTake = reaper.MIDIEditor_GetTake(activeMidiEditor) -- type MediaItem_Take
    -- local startFirstMeasurePPQ = reaper.MIDI_GetPPQPos_EndOfMeasure(activeTake, listSelectedNotes[1].startppqpos) -- we will calculate new tempi from here..
    -- local startFirstMeasureQN = reaper.MIDI_GetProjQNFromPPQPos(activeTake, startFirstMeasurePPQ)
    -- local firstMeasure
    -- firstMeasure = reaper.TimeMap_QNToMeasures(0, startFirstMeasureQN) -- which measure QN falls in
    -- local beat = 0
    -- local measure = firstMeasure - 1 -- why ?

    -- for i, timeBPM in ipairs(timeMap) do 
    --     reaper.SetTempoTimeSigMarker(0, -1, -1, measure, beat, timeBPM["BPM"], 0, 0, false)
    --     beat = beat + 1

    --     if beat > 3 then 
    --         beat = 0
    --         measure = measure + 1
    --     end
    -- end
end

local function OnChangeNotes_Pressed()
    -- Msg("Change Notes Pressed")
    -- -- delete media item 
    -- local activeMidiEditor = reaper.MIDIEditor_GetActive()
    -- local activeTake = reaper.MIDIEditor_GetTake(activeMidiEditor) -- type MediaItem_Take
    -- local activeMediaItem = reaper.GetMediaItemTake_Item(activeTake)
    -- local mediaTrack = reaper.GetMediaItem_Track(activeMediaItem)
    
    -- -- Delete media item
    -- ifItemWasDeleted = reaper.DeleteTrackMediaItem(mediaTrack, activeMediaItem)
    -- if(ifItemWasDeleted) then Msg("Media Item deleted!") end
    
    -- -- create new item
    -- -- endtime = startTime nextMeasure from end of last note in 'listAllNotes'
    -- local timeOffset = time_new - time_zero -- add this to all new created notes
    -- local endNewMediaItem = listAllNotes[#listAllNotes].endTime + timeOffset
    -- -- TODO start item 1 beat earlier, ramp up cc data..
    -- local fallInForCC = 1 -- 1 sec earlier than first note start cc data
    -- local tail = 1 -- 1 sec tail for cc data
    -- newMediaItem = reaper.CreateNewMIDIItemInProj(mediaTrack, time_new - fallInForCC, endNewMediaItem + tail, false)
    -- --
    -- CreateMidiNotesInNewItem(newMediaItem, timeOffset)
    -- CreateCC_DataInNewItem(newMediaItem, timeOffset)
end

local function OnSaveMidiItems_Pressed()
    listAllItems = {}
    local item = reaper.GetSelectedMediaItem(0, 0) 
    local count = 0

    while item ~= nil do 
        listAllItems[count+1] = {["Item"] = item, ["Notes"] = GetListAllMidiNotesInItem(item), ["CC"] = GetListAllCCInItem(item)}
        count = count + 1
        item = reaper.GetSelectedMediaItem(0, count)
    end
    Msg("Number of midi items saved : "..count)
end

local function OnSaveQuarterNotes_Pressed()

end

local function OnCreateTimeMapAndSetMidiItems_Pressed()
    
end

------------------------------------------------------------------------------
------------------------------ Exit functions -----------------------------
local function Exit()
    -- Msg("exiting..")
    -- Save()
end

-----------------------------------------------------------------------------------------------------
-------------------------------------- Main and GUI Functions ---------------------------------------
-----------------------------------------------------------------------------------------------------

---- INI GUI ----
local function InitializeGUI()

    ------------------------------------- GUI INI --------------------------------
    GUI.name = guiName
    GUI.x, GUI.y = 0, 0 -- Top Left : Starting point in pixels, make dynamic
    -- with anchor and corner x and y becomes offset coordinates!
    GUI.h = guiHeight
    GUI.w = guiWidth
    GUI.anchor, GUI.corner = "mouse", "C"


    GUI.New("btn_SaveItems", "Button", 1, 30, 30, 165, 24, "Save midi items", OnSaveMidiItems_Pressed)
    GUI.New("btn_SaveQuarterNotes", "Button", 1, 30, 60, 165, 24, "Save Quarter Notes", OnSaveQuarterNotes_Pressed)
    GUI.New("btn_CreateTimeMapAndSetMidiItems", "Button", 1, 30, 90, 165, 24, "Create Time-map and set midi", OnCreateTimeMapAndSetMidiItems_Pressed)

    -- -- Debug Buttons
    -- GUI.New("btn_CalculateBPM", "Button", 1, 30,30, 124,24, "Calculate BPM Time map", OnCalculateBPM_Pressed)
    -- GUI.New("btn_SetBPM", "Button", 1, 30,60, 124,24, "Set BPM", OnSetBPM_Pressed)
    -- GUI.New("btn_ChangeNotes", "Button", 1, 30,90, 124,24, "Change Notes", OnChangeNotes_Pressed)
    
    
  

    
    -------------------------------------- INI GUI --------------------------------------------
    GUI.Init()
    GUI.Main()
end

-------------------------------- Functions for Main ----------------------------------------

local function MouseCursorInWindow()
    return GUI.mouse.x > -1 and GUI.mouse.x < guiWidth and GUI.mouse.y > -30 and GUI.mouse.y < guiHeight -- -30 is window menu padding
end


------------------------------------ MAIN -----------------------------------------------
local function Main()
    local char = gfx.getchar()
    if char ~= 27 and char ~= -1 and exitChar ~= 27 then
        reaper.time_precise()
        -- Msg("main is running!")

        -- Delayed Update Loop --
        if os.time() > oldTime + updateTime then
            -- Msg("Update")
            oldTime = os.time()
            -- check track integrity - compare track name and numbers etc..
        end

        
        
        
        reaper.defer(Main)
    end
end

-- get project time from selected midi note ? 
--[[

--]]

-- sort a list by selected Notes.
-- enum untill -1
--[[

-- get index through loop. 
-- index will always change!





-- make json midi files on hd for persistent data!




--]]
-- calc time between notes. 

InitializeGUI()
-- Start()
Main()


-- Class test!






reaper.atexit(Exit)
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

-- Extra Functions
loadfile("C:/Users/pract/Documents/Repos/ReaperPlugins/Lua/MidiTempoMapper/Source/Note.lua")()

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
local guiHeight = 800
local guiWidth = 500

-- Buttons


--]]




---------- 


------------------------------------------------------
---------------- Functions --------------------------
-----------------------------------------------------

local function Msg(param) 
    reaper.ShowConsoleMsg(tostring(param).."\n")
end

--------------- For CalculateBPM() -----------------

local function GetProjTimeNextMeasure(activeTake, note)
    local startPPQNextMeasure = reaper.MIDI_GetPPQPos_EndOfMeasure(activeTake, listSelectedNotes[1].startppqpos) 
    -- Msg("Start ppq next measure "..startPPQNextMeasure)
    return reaper.MIDI_GetProjTimeFromPPQPos(activeTake, startPPQNextMeasure) 
end


local function InitializeNotesInList(activeTake, notesList)
    for note in notesList do 
        note.CalculateStartAndEndInProjTime()
    end
end

local function GetListAllMidiNotesAndAllSelected(activeTake)
    local listAllNotes = {} -- index starts at 1
    local listSelectedNotes = {}
    local retval = reaper.MIDI_GetNote(activeTake, 0) -- bool, check there is a 1st note in take
    local isSelected
    local isMuted
    local currentNoteIdx = 0
    local selectedIdx = 1 -- lua lists starts at 1
    local midiNote

    while retval do -- list of selected and all notes
        midiNote = Note:New()
        retval, isSelected, isMuted,
        midiNote.startppqpos, midiNote.endppqpos, 
        midiNote.chan, midiNote.pitch, midiNote.vel = reaper.MIDI_GetNote(activeTake, currentNoteIdx)
        Msg("Note "..tostring(currentNoteIdx+1).." Start pos "..midiNote.startppqpos)
        Msg("retval "..tostring(retval))
        if isSelected then
            listSelectedNotes[selectedIdx] = midiNote 
            selectedIdx = selectedIdx + 1
        end
        listAllNotes[currentNoteIdx+1] = midiNote
        currentNoteIdx = currentNoteIdx + 1
        retval = reaper.MIDI_GetNote(activeTake, currentNoteIdx)
    end
    return listAllNotes, listSelectedNotes
end

local function CalculateBPM()
    Msg("Button Calculate BPM pressed")
    local activeMidiEditor = reaper.MIDIEditor_GetActive()
    local activeTake = reaper.MIDIEditor_GetTake(activeMidiEditor) -- type MediaItem_Take
    local listAllNotes = {} -- index starts at 1
    local listSelectedNotes = {}
    listAllNotes, listSelectedNotes = GetListAllMidiNotesAndAllSelected(activeTake)
    --[[ -- print all selected notes start ppq
     for index, note in pairs(listSelectedNotes) do 
        Msg("Selected Note "..index.. " start ppq "..note.startppqpos)
    end
    --]]
    InitializeNotesInList(activeTake, listAllNotes)
    local time_new = GetTimeN() -- start new BPM from here..
    local time_zero = reaper.MIDI_GetProjTimeFromPPQPos(activeTake, listSelectedNotes[1].startppqpos)
    
end




    

    

local function SetBPM()
    Msg("Set BPM button pressed")
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

    -- Debug Buttons
    GUI.New("btn_CalculateBPM", "Button", 1, 30,30, 124,24, "Calculate BPM", CalculateBPM)

    GUI.New("btn_SetBPM", "Button", 1, 30,60, 124,24, "Set BPM", SetBPM)

  

    
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

-- a = Note:new()
-- b = Note:new()
-- c = Note:new()
-- Msg("balance b: "..b.balance)
-- b:deposit(200)
-- Msg("balance b: "..b.balance)
-- Msg("balance a : "..a.balance)
-- Note.balance = 0
-- Msg("balance b: "..b.balance)
-- a:deposit(300)
-- Note.balance = 0
-- Msg("balance a : "..a.balance)
-- Msg("balance b: "..b.balance)
-- a.balance = -10
-- Msg("balance a : "..a.balance)
-- Msg("balance Note : "..Note.balance)




reaper.atexit(Exit)
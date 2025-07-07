-- WoW Lua Quick Reference for MDT Development
-- This file contains common patterns and functions you'll encounter

-- ================================
-- BASIC ADDON STRUCTURE
-- ================================

-- Get addon namespace (this is in every file)
local AddonName, MDT = ...
local L = MDT.L -- Localization table

-- ================================
-- COMMON VARIABLES & FUNCTIONS
-- ================================

-- Table operations
local tinsert, tremove = table.insert, table.remove
local pairs, ipairs = pairs, ipairs -- For iterating tables
local wipe = wipe                   -- Clear table contents

-- String operations
local strsplit = strsplit -- Split strings
local strfind = strfind   -- Find in strings
local format = format     -- String formatting

-- Math operations
local max, min, abs = math.max, math.min, math.abs
local floor, ceil = math.floor, math.ceil

-- ================================
-- FRAME CREATION
-- ================================

-- Create a basic frame
local frame = CreateFrame("Frame", "MyFrameName", UIParent)
frame:SetSize(200, 100)
frame:SetPoint("CENTER")
frame:Show()

-- Create a button
local button = CreateFrame("Button", "MyButton", frame, "UIPanelButtonTemplate")
button:SetText("Click Me")
button:SetPoint("CENTER")
button:SetScript("OnClick", function()
  print("Button clicked!")
end)

-- Create a text widget
local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
text:SetPoint("CENTER")
text:SetText("Hello World")

-- ================================
-- EVENT HANDLING
-- ================================

-- Register for events
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(self, event, ...)
  if event == "ADDON_LOADED" then
    local addonName = ...
    if addonName == AddonName then
      print("My addon loaded!")
    end
  elseif event == "PLAYER_ENTERING_WORLD" then
    print("Player entered world!")
  end
end)

-- ================================
-- COMMON WOW API FUNCTIONS
-- ================================

-- Player information
local playerName = UnitName("player")
local playerClass = UnitClass("player")
local playerLevel = UnitLevel("player")

-- Map and zone information
local mapId = C_Map.GetBestMapForUnit("player")
local isInInstance, instanceType = IsInInstance()
local instanceName, instanceType, difficulty = GetInstanceInfo()

-- Group/party information
local isInGroup = IsInGroup()
local isInRaid = IsInRaid()
local numMembers = GetNumGroupMembers()

-- Chat and communication
SendChatMessage("Hello!", "PARTY")
SendChatMessage("Hello!", "GUILD")

-- ================================
-- MYTHIC+ SPECIFIC FUNCTIONS
-- ================================

-- Get current Mythic+ info
local mapId = C_ChallengeMode.GetActiveChallengeMapID()
local level, affixes = C_ChallengeMode.GetActiveKeystoneInfo()

-- Get affix information
local affixIDs = C_ChallengeMode.GetAffixInfo()
for i, affixID in ipairs(affixIDs) do
  local name, description, filedataid = C_ChallengeMode.GetAffixInfo(affixID)
  print("Affix:", name)
end

-- ================================
-- COMMON PATTERNS IN MDT
-- ================================

-- Iterating through enemies
for i, enemy in pairs(MDT.dungeonEnemies[dungeonIdx]) do
  print("Enemy ID:", enemy.id)
  print("Enemy Name:", enemy.name)
  print("Enemy Count:", enemy.count)
  print("Position:", enemy.x, enemy.y)
end

-- Checking if something exists safely
if MDT.dungeonEnemies and MDT.dungeonEnemies[dungeonIdx] then
  -- Safe to access
  local enemies = MDT.dungeonEnemies[dungeonIdx]
end

-- Creating GUI elements with AceGUI
local AceGUI = LibStub("AceGUI-3.0")
local container = AceGUI:Create("SimpleGroup")
container:SetFullWidth(true)
container:SetFullHeight(true)

local button = AceGUI:Create("Button")
button:SetText("My Button")
button:SetCallback("OnClick", function()
  print("AceGUI button clicked!")
end)
container:AddChild(button)

-- ================================
-- DEBUGGING AND TESTING
-- ================================

-- Basic debug print
print("Debug message:", someVariable)

-- More detailed debug info
local function debugPrint(...)
  if MDT.debug then -- Only print if debug mode is on
    print("|cFFFF0000[DEBUG]|r", ...)
  end
end

-- Check if we're in the right context
local function isInMythicPlus()
  local _, instanceType, difficulty = GetInstanceInfo()
  return instanceType == "party" and difficulty == 8
end

-- Safe function calls
local success, result = pcall(function()
  -- Potentially dangerous code here
  return someRiskyFunction()
end)

if success then
  print("Success:", result)
else
  print("Error:", result)
end

-- ================================
-- LOCALIZATION
-- ================================

-- Always use localized strings for user-facing text
local L = MDT.L

-- In your code, use:
print(L["Hello World"])
frame:SetText(L["Click to continue"])

-- The actual translations are in Locales/ folder
-- L["Hello World"] = "Hello World"  -- English
-- L["Hello World"] = "Hola Mundo"   -- Spanish

-- ================================
-- COMMON MISTAKES TO AVOID
-- ================================

-- DON'T: Create global variables
myGlobalVar = "bad"

-- DO: Always use local
local myLocalVar = "good"

-- DON'T: Modify Blizzard frames directly without checking
WorldMapFrame:Hide() -- This could break things

-- DO: Check if it exists first
if WorldMapFrame and WorldMapFrame:IsShown() then
  WorldMapFrame:Hide()
end

-- DON'T: Use expensive operations in OnUpdate
frame:SetScript("OnUpdate", function()
  -- This runs every frame! Keep it light
  for i = 1, 1000 do
    -- Don't do this!
  end
end)

-- DO: Use timers for periodic tasks
C_Timer.NewTicker(1, function()
  -- This runs every second
  print("Timer tick")
end)

-- ================================
-- USEFUL HELPER FUNCTIONS
-- ================================

-- Check if a table is empty
local function isTableEmpty(t)
  return next(t) == nil
end

-- Deep copy a table
local function deepCopy(orig)
  local copy
  if type(orig) == 'table' then
    copy = {}
    for key, value in next, orig, nil do
      copy[deepCopy(key)] = deepCopy(value)
    end
  else
    copy = orig
  end
  return copy
end

-- Round a number
local function round(num)
  return floor(num + 0.5)
end

-- Safe string formatting
local function safeFormat(str, ...)
  local success, result = pcall(format, str, ...)
  return success and result or str
end

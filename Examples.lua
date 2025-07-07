-- Example: Simple MDT Feature Addition
-- This shows how to add a simple feature to MDT

local AddonName, MDT = ...
local L = MDT.L

-- Example 1: Adding a new slash command
-- This adds a command like /mdt hello that prints a greeting

local function HelloCommand()
  print(L["Hello from MDT!"] or "Hello from MDT!")

  -- Get current dungeon info if in a dungeon
  local isInInstance, instanceType = IsInInstance()
  if isInInstance and instanceType == "party" then
    local name, instanceType, difficulty = GetInstanceInfo()
    print("You are in:", name, "Difficulty:", difficulty)
  end
end

-- Add the command to the existing slash command handler
-- You would modify the SlashCmdList.MYTHICDUNGEONTOOLS function in MythicDungeonTools.lua
-- Add this case to the existing command handler:
-- elseif rqst == "hello" then
--   HelloCommand()

-- Example 2: Adding a simple UI button
-- This shows how to add a button to the main frame

local function CreateHelloButton(parent)
  local button = CreateFrame("Button", "MDTHelloButton", parent, "UIPanelButtonTemplate")
  button:SetText("Say Hello")
  button:SetSize(100, 30)
  button:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)

  button:SetScript("OnClick", function()
    HelloCommand()
  end)

  return button
end

-- Example 3: Adding enemy count feature
-- This shows how to work with enemy data

local function GetTotalEnemyCount(dungeonIdx)
  local count = 0

  if MDT.dungeonEnemies and MDT.dungeonEnemies[dungeonIdx] then
    for _, enemy in pairs(MDT.dungeonEnemies[dungeonIdx]) do
      count = count + (enemy.count or 0)
    end
  end

  return count
end

local function PrintCurrentDungeonInfo()
  local mapId = C_Map.GetBestMapForUnit("player")
  local dungeonIdx = MDT.zoneIdToDungeonIdx and MDT.zoneIdToDungeonIdx[mapId]

  if dungeonIdx then
    local totalCount = GetTotalEnemyCount(dungeonIdx)
    local dungeonName = MDT.dungeonList[dungeonIdx]
    print(string.format("Current dungeon: %s (Total enemies: %d)", dungeonName, totalCount))
  else
    print("Not in a tracked dungeon")
  end
end

-- Example 4: Adding a settings option
-- This shows how to add a new setting to MDT

local function InitializeNewSettings()
  -- This would be called during MDT initialization
  -- Add default values to the database

  if MDT.db and MDT.db.global then
    -- Add a new setting with default value
    if MDT.db.global.showHelloButton == nil then
      MDT.db.global.showHelloButton = true
    end
  end
end

-- Example 5: Event handling for your feature
-- This shows how to respond to game events

local function OnPlayerEnterWorld()
  -- Called when player enters world (login, zone change, etc.)
  C_Timer.After(2, function() -- Wait 2 seconds for data to load
    PrintCurrentDungeonInfo()
  end)
end

local function OnChallengeMode()
  -- Called when entering/leaving Mythic+ mode
  print("Mythic+ mode changed!")
  PrintCurrentDungeonInfo()
end

-- Event frame setup
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("CHALLENGE_MODE_START")
eventFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")

eventFrame:SetScript("OnEvent", function(self, event, ...)
  if event == "PLAYER_ENTERING_WORLD" then
    OnPlayerEnterWorld()
  elseif event == "CHALLENGE_MODE_START" or event == "CHALLENGE_MODE_COMPLETED" then
    OnChallengeMode()
  end
end)

-- Example 6: Working with MDT's existing API
-- This shows how to use MDT's public functions

local function DemoMDTAPI()
  -- Get enemy forces for a specific NPC
  local count, maxCount = MDT:GetEnemyForces(12345) -- Replace with real NPC ID
  if count then
    print("NPC gives", count, "enemy forces out of", maxCount, "total")
  end

  -- Check if MDT is loaded and ready
  if MDT.dungeonList then
    print("MDT has", #MDT.dungeonList, "dungeons loaded")
  end
end

-- Example 7: Creating a simple settings panel
-- This shows how to create a basic options panel

local function CreateSettingsPanel()
  local panel = CreateFrame("Frame", "MDTExampleSettings", UIParent)
  panel:SetSize(300, 200)
  panel:SetPoint("CENTER")
  panel:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
  })
  panel:SetBackdropColor(0, 0, 0, 1)

  -- Title
  local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", 0, -20)
  title:SetText("MDT Example Settings")

  -- Checkbox example
  local checkbox = CreateFrame("CheckButton", "MDTExampleCheckbox", panel, "UICheckButtonTemplate")
  checkbox:SetPoint("TOPLEFT", 20, -60)
  checkbox.text = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
  checkbox.text:SetText("Show Hello Button")

  -- Set checkbox state based on saved setting
  checkbox:SetChecked(MDT.db and MDT.db.global and MDT.db.global.showHelloButton)

  checkbox:SetScript("OnClick", function()
    if MDT.db and MDT.db.global then
      MDT.db.global.showHelloButton = checkbox:GetChecked()
    end
  end)

  -- Close button
  local closeButton = CreateFrame("Button", "MDTExampleCloseButton", panel, "UIPanelButtonTemplate")
  closeButton:SetSize(80, 22)
  closeButton:SetPoint("BOTTOM", 0, 20)
  closeButton:SetText("Close")
  closeButton:SetScript("OnClick", function()
    panel:Hide()
  end)

  return panel
end

-- Example 8: Adding a minimap button feature
-- This shows how to extend the existing minimap functionality

local function OnMinimapClick(button)
  if button == "MiddleButton" then
    -- Custom middle-click behavior
    print("Custom minimap action!")
    return true -- Prevent default behavior
  end
  return false  -- Allow default behavior
end

-- To implement this, you would hook into the existing minimap code in MythicDungeonTools.lua

-- HOW TO USE THESE EXAMPLES:
-- 1. Choose one example that interests you
-- 2. Find the appropriate place in the MDT codebase to add it
-- 3. Modify the existing code to include your feature
-- 4. Test it in-game
-- 5. Submit a pull request!

--[[
COMMON PLACES TO ADD FEATURES:

1. New slash commands: MythicDungeonTools.lua, SlashCmdList.MYTHICDUNGEONTOOLS function
2. UI elements: MythicDungeonTools.lua, in the frame creation functions
3. Settings: MythicDungeonTools.lua, in the initialization code
4. Event handlers: MythicDungeonTools.lua, in the event handling section
5. New modules: Create a new file in Modules/ folder
6. Dungeon-specific features: Add to the appropriate dungeon file in TheWarWithin/

TESTING YOUR CHANGES:
1. Use the dev-helper.ps1 script to copy files to WoW
2. Type /reload in WoW to reload the UI
3. Test your feature with /mdt or whatever command you added
4. Check for Lua errors with /console scriptErrors 1
--]]

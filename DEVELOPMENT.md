https://github.com/geexmmo/python-weakauras-tool


# Mythic Dungeon Tools - Development Guide

## Welcome to WoW Addon Development! 🎮

This guide will help you get started with contributing to the Mythic Dungeon Tools addon, even if you're new to Lua programming.

## What is This Project?

Mythic Dungeon Tools (MDT) is a World of Warcraft addon that helps players plan their routes through Mythic+ dungeons. It provides:
- Interactive maps of all Mythic+ dungeons
- Enemy positioning and information
- Route planning and sharing capabilities
- Enemy forces calculations

## Understanding WoW Addons

Unlike standalone applications, WoW addons:
- **Run inside World of Warcraft** - You can't execute them independently
- **Use WoW's Lua API** - They have access to game functions and data
- **Are event-driven** - They respond to game events like entering dungeons, combat, etc.

## Development Environment Setup

### 1. VS Code Configuration ✅
Your VS Code is now configured with:
- Lua language server for syntax highlighting and error detection
- WoW-specific global functions recognized
- Proper formatting rules (2 spaces, CRLF line endings)
- File associations for .toc and .xml files

### 2. Testing Your Changes

Since you can't "run" the addon outside WoW, you'll need to:

1. **Copy the addon to your WoW folder**:
   ```powershell
   # Copy your fork to WoW's addon directory
   # Replace with your actual WoW path
   Copy-Item -Path "h:\dev\solutions\MythicDungeonTools-fork" -Destination "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\MythicDungeonTools" -Recurse -Force
   ```

2. **Test in-game**:
   - Launch World of Warcraft
   - Create a character or log in
   - Type `/mdt` or `/mplus` to open the addon
   - Test your changes

### 3. Development Workflow

```powershell
# 1. Make changes in your fork
# 2. Copy to WoW (you can create a script for this)
# 3. Reload WoW UI with /reload
# 4. Test your changes
# 5. Repeat
```

## Project Structure

```
MythicDungeonTools/
├── MythicDungeonTools.toc          # Addon metadata and file loading order
├── MythicDungeonTools.lua          # Main addon file
├── init.lua                        # Initialization
├── Modules/                        # Core functionality modules
│   ├── API.lua                     # Public API for other addons
│   ├── DungeonEnemies.lua         # Enemy data and management
│   ├── DungeonSelect.lua          # Dungeon selection interface
│   └── ...
├── TheWarWithin/                   # Current expansion dungeons
│   ├── AraKara.lua                # Individual dungeon data
│   ├── TheStonevault.lua          # Individual dungeon data
│   └── ...
├── Locales/                        # Translations
├── AceGUIWidgets/                  # Custom UI components
└── Developer/                      # Development tools
```

## Understanding the Code

### Key Files to Understand:

1. **MythicDungeonTools.toc** - Addon metadata
2. **MythicDungeonTools.lua** - Main addon logic
3. **Modules/API.lua** - Public functions other addons can use
4. **TheWarWithin/[Dungeon].lua** - Individual dungeon data

### Common Patterns:

```lua
-- This is how the addon is structured
local AddonName, MDT = ...  -- Get addon namespace
local L = MDT.L             -- Localization table

-- Event handling
function MDT:OnInitialize()
  -- Addon initialization
end

-- Creating UI elements
local frame = CreateFrame("Frame", "MyFrame", UIParent)
frame:SetSize(100, 100)
frame:Show()
```

## How to Contribute

### 1. Start Small
- Fix typos in comments or strings
- Add missing localization strings
- Improve existing documentation

### 2. Understanding the Data
Each dungeon file contains:
```lua
-- Enemy data structure
{
  id = 12345,           -- NPC ID from game
  name = "Enemy Name",  -- Display name
  x = 400,              -- X position on map
  y = 300,              -- Y position on map
  count = 4,            -- Enemy forces value
  -- ... other properties
}
```

### 3. Common Tasks for Beginners

#### A. Adding New Dungeon Data
1. Find the dungeon file in `TheWarWithin/`
2. Add enemy data using the in-game editor (`/mdt devmode`)
3. Export the data and update the file

#### B. Fixing UI Issues
1. Look in `MythicDungeonTools.lua` for UI creation
2. Find the relevant frame or widget
3. Make your changes

#### C. Adding Features
1. Study existing similar features
2. Add your code to the appropriate module
3. Test thoroughly

## Lua Basics for WoW

### Variables and Tables
```lua
-- Variables
local myVar = "Hello"
local myNumber = 42

-- Tables (like arrays/objects)
local myTable = {
  name = "Player",
  level = 80,
  items = {"sword", "shield"}
}

-- Accessing table values
print(myTable.name)      -- "Player"
print(myTable.items[1])  -- "sword"
```

### Functions
```lua
-- Basic function
function MyFunction(param1, param2)
  return param1 + param2
end

-- Anonymous function
local myFunc = function(x)
  return x * 2
end
```

### WoW-Specific Patterns
```lua
-- Event handling
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, ...)
  if event == "ADDON_LOADED" then
    print("Addon loaded!")
  end
end)

-- Localization
local L = {}
L["Hello"] = "Hello"
L["Goodbye"] = "Goodbye"
```

## Development Tools

### In-Game Commands
- `/mdt` - Open the addon
- `/mdt devmode` - Enable developer mode
- `/reload` - Reload the UI
- `/console scriptErrors 1` - Show Lua errors

### VS Code Features
- **Syntax highlighting** for Lua
- **Error detection** for common mistakes
- **Auto-completion** for WoW API functions
- **Formatting** on save

## Common Pitfalls

1. **Global variables** - Always use `local` unless you need global scope
2. **Event timing** - Some game data isn't available immediately
3. **Localization** - All user-facing strings should use `L["string"]`
4. **Performance** - Avoid expensive operations in frequently called functions

## Getting Help

1. **Read the contributing guide** - `CONTRIBUTING.md`
2. **Study existing code** - Look at how similar features are implemented
3. **Use the development tools** - `/mdt devmode` has helpful features
4. **Ask questions** - The community is usually helpful

## Next Steps

1. **Make a small change** - Try adding a comment or fixing a typo
2. **Test it in-game** - Copy to WoW and test
3. **Submit a pull request** - Share your contribution
4. **Iterate** - Based on feedback, improve your code

## Useful Resources

- [WoW API Documentation](https://wowpedia.fandom.com/wiki/World_of_Warcraft_API)
- [Lua 5.1 Reference](https://www.lua.org/manual/5.1/)
- [WoW Addon Development](https://wowpedia.fandom.com/wiki/AddOn)

Remember: Every expert was once a beginner. Start small, learn gradually, and don't be afraid to ask questions!

## Understanding MDT Route Data 🔍

MDT route strings are encoded using a 3-layer format:

1. **Serialization**: AceSerializer format (Lua table → binary)
2. **Compression**: LibDeflate compression (reduces size by ~60-80%)
3. **Encoding**: Custom Base64 with alphabet `a-zA-Z0-9()`

### Route String Format
```
!<base64_encoded_compressed_serialized_route_data>
```

The `!` prefix indicates newer deflate compression (vs legacy format).

### Decoding Tools

I've created several tools in the `tools/` folder to help you decode and analyze route strings:

- **Python**: `python tools/mdt_decoder.py example_routes/rt1.txt`
- **Node.js**: `node tools/mdt_decoder.js example_routes/rt1.txt`
- **C#**: `dotnet run --project tools example_routes/rt1.txt`
- **Lua**: `lua tools/mdt_decoder.lua example_routes/rt1.txt`

These tools will convert route strings to JSON format, making it easier to understand the data structure.

### Route Data Contents

Routes typically contain:
- **Dungeon info**: `dungeonIdx`, name, difficulty
- **Affix data**: Current week's Mythic+ affixes
- **Pull assignments**: Which enemies are in each pull
- **Drawing objects**: Lines, circles, notes on the map
- **Settings**: Route preferences and configurations

### Example Usage
```bash
# Decode a route string to JSON
cd tools
node mdt_decoder.js ../example_routes/rt1.txt > decoded_route.json

# View the structure
cat decoded_route.json
```

local ADDON_NAME, addon = ...
AtlasPlus = AtlasPlus or {}
local AP = AtlasPlus

local L = setmetatable({}, {
    __index = function(t, k)
        local v = tostring(k)
        rawset(t, k, v)
        return v
    end
})
AP.L = L

-- Categories
L["Classic Dungeons"] = "Classic Dungeons"
L["Classic Raids"] = "Classic Raids"
L["Burning Crusade Dungeons"] = "Burning Crusade Dungeons"
L["Burning Crusade Raids"] = "Burning Crusade Raids"
L["Wrath of the Lich King Dungeons"] = "Wrath of the Lich King Dungeons"
L["Wrath of the Lich King Raids"] = "Wrath of the Lich King Raids"
L["World Drops"] = "World Drops"
L["World Events"] = "World Events"
L["Vendors"] = "Vendors"
L["Entrances"] = "Entrances"
L["Dungeon Locations"] = "Dungeon Locations"

-- Modes
L["Normal"] = "Normal"
L["Heroic"] = "Heroic"
L["10 Heroic"] = "10 Heroic"
L["25 Heroic"] = "25 Heroic"

-- Classes
L["Warrior"] = "Warrior"
L["Paladin"] = "Paladin"
L["Hunter"] = "Hunter"
L["Rogue"] = "Rogue"
L["Priest"] = "Priest"
L["Death Knight"] = "Death Knight"
L["Shaman"] = "Shaman"
L["Mage"] = "Mage"
L["Warlock"] = "Warlock"
L["Druid"] = "Druid"

-- Top bar & tabs
L["World map"] = "World map"
L["Atlas"] = "Atlas"
L["Game map"] = "Game map"
L["Settings"] = "Settings"
L["Search an instance, a boss or loot..."] = "Search an instance, a boss or loot..."

-- Map header & instance info
L["Level %s"] = "Level %s"
L["min. %s"] = "min. %s"
L["%d players"] = "%d players"
L["Entrance map"] = "Entrance map"
L["Instances"] = "Instances"

-- Instance list bar
L["Drag: list wider or narrower"] = "Drag: list wider or narrower"
L["Right-click: back to the first width"] = "Right-click: back to the first width"

-- Legend & loot panel
L["Click a boss (|r%s>|r|cff888888) to see its loot|r"] = "Click a boss (|r%s>|r|cff888888) to see its loot|r"
L["Click a list (|r%s>|r|cff888888) to see its items|r"] = "Click a list (|r%s>|r|cff888888) to see its items|r"
L["Trash mobs"] = "Trash mobs"
L["loot >"] = "loot >"
L["Items for this class"] = "Items for this class"
L["Click: fold"] = "Click: fold"
L["Click: open"] = "Click: open"
L["Click: open this map"] = "Click: open this map"
L["Click: see its loot"] = "Click: see its loot"
L["Drop chance: %s%%"] = "Drop chance: %s%%"
L["(hard mode)"] = "(hard mode)"
L["Cost: free"] = "Cost: free"
L["Cost: "] = "Cost: "
L["Sold by: %s"] = "Sold by: %s"
L["Quest reward: %s"] = "Quest reward: %s"
L["Quest"] = "Quest"
L["World drop: creatures of level %s can drop this."] = "World drop: creatures of level %s can drop this."
L["Alliance only"] = "Alliance only"
L["Horde only"] = "Horde only"
L["Requires a personal arena rating of %d"] = "Requires a personal arena rating of %d"
L["Type at least 2 letters."] = "Type at least 2 letters."
L["No loot for this mode."] = "No loot for this mode."
L["Nothing found."] = "Nothing found."
L["Nothing on this continent."] = "Nothing on this continent."
L["Click a result to open its boss.  Shift-click: link in chat.  Ctrl-click: try on."] = "Click a result to open its boss.  Shift-click: link in chat.  Ctrl-click: try on."
L["Prices from the game data.  Shift-click: link.  Ctrl-click: try on."] = "Prices from the game data.  Shift-click: link.  Ctrl-click: try on."
L["Chances per kill, for a typical creature of the level.  Lx-y = creature levels.  Shift-click: link."] = "Chances per kill, for a typical creature of the level.  Lx-y = creature levels.  Shift-click: link."
L["Drop chances from the 3.3.5a database (the server can differ).  HM = hard mode.  |cff4a9effA|r / |cffff4a4aH|r = Alliance / Horde only.  Shift-click: link.  Ctrl-click: try on."] = "Drop chances from the 3.3.5a database (the server can differ).  HM = hard mode.  |cff4a9effA|r / |cffff4a4aH|r = Alliance / Horde only.  Shift-click: link.  Ctrl-click: try on."

-- Search count strings
L["%d instance"] = "%d instance"
L["%d instances"] = "%d instances"
L["%d boss"] = "%d boss"
L["%d bosses"] = "%d bosses"
L["%d item"] = "%d item"
L["%d items"] = "%d items"
L["%d list"] = "%d list"
L["%d lists"] = "%d lists"
L[" found"] = " found"
L[" (first 200)"] = " (first 200)"

-- Settings: columns
L["Window"] = "Window"
L["Map markers"] = "Map markers"

-- Settings: column 1 (Window)
L["Open on the map of where you are"] = "Open on the map of where you are"
L["In a dungeon or raid: its map and wing, with the loot of your difficulty. Outdoors: the world map, on your zone."] = "In a dungeon or raid: its map and wing, with the loot of your difficulty. Outdoors: the world map, on your zone."
L["Open by itself in dungeons and raids"] = "Open by itself in dungeons and raids"
L["Minimap button"] = "Minimap button"
L["Lock the window"] = "Lock the window"
L["It can't be moved by its title bar."] = "It can't be moved by its title bar."
L["Fade while moving"] = "Fade while moving"
L["See-through while you move, unless the mouse is over it."] = "See-through while you move, unless the mouse is over it."
L["Opacity while moving"] = "Opacity while moving"
L["Window size"] = "Window size"
L["Window opacity"] = "Window opacity"
L["Move the window: drag its title. Resize it: drag its bottom right corner."] = "Move the window: drag its title. Resize it: drag its bottom right corner."

-- Settings: column 2 (World map)
L["The map key (M) opens Atlas Plus"] = "The map key (M) opens Atlas Plus"
L["The game's map opens inside Atlas Plus, quests and map addons included. Untick to get the game's map back on M."] = "The game's map opens inside Atlas Plus, quests and map addons included. Untick to get the game's map back on M."
L["Game instance maps"] = "Game instance maps"
L["In a dungeon or raid with a game map (Ulduar, Icecrown Citadel...): open it, on your floor. The Atlas map stays in the Atlas tab."] = "In a dungeon or raid with a game map (Ulduar, Icecrown Citadel...): open it, on your floor. The Atlas map stays in the Atlas tab."
L["No fog of war"] = "No fog of war"
L["Show the areas you have not explored yet."] = "Show the areas you have not explored yet."
L["Darken unexplored areas"] = "Darken unexplored areas"
L["So you can still tell them apart."] = "So you can still tell them apart."
L["Zone panel (top left of the map)"] = "Zone panel (top left of the map)"
L["Zone info under the cursor"] = "Zone info under the cursor"
L["Coordinates (yours and the cursor's)"] = "Coordinates (yours and the cursor's)"
L["Quest icon size"] = "Quest icon size"
L["Game map opacity"] = "Game map opacity"
L["Game small map size"] = "Game small map size"
L["These two: the game's map opened on its own (Game map button)."] = "These two: the game's map opened on its own (Game map button)."

-- Settings: column 3 (Map markers)
L["Dungeons (blue)"] = "Dungeons (blue)"
L["Raids (green)"] = "Raids (green)"
L["World bosses"] = "World bosses"
L["Portals"] = "Portals"
L["Boats"] = "Boats"
L["Zeppelins"] = "Zeppelins"
L["Deeprun Tram"] = "Deeprun Tram"
L["Flight masters"] = "Flight masters"
L["Innkeepers"] = "Innkeepers"
L["Mailboxes"] = "Mailboxes"
L["Banks"] = "Banks"
L["Auction houses"] = "Auction houses"
L["Markers on continent maps"] = "Markers on continent maps"
L["Not the town ones (flight masters, inns...)."] = "Not the town ones (flight masters, inns...)."
L["Hide Questie's dungeon and raid icons"] = "Hide Questie's dungeon and raid icons"
L["While the Atlas Plus ones are on. They come back when you turn these off."] = "While the Atlas Plus ones are on. They come back when you turn these off."
L["Only my faction's"] = "Only my faction's"
L["Transports, portals and town markers. Neutral ones always show."] = "Transports, portals and town markers. Neutral ones always show."
L["Marker size"] = "Marker size"
L["Town marker size"] = "Town marker size"

-- Settings credits
L["Atlas Plus %s (Circle Edition) by Saranwrap & dadec666. Instance maps and legends from Atlas (GPL v2). Zone levels from LibTourist-3.0 (MIT). Database aligned with wowroad.info.\\n/ap - open / close     /ap here - map of where you are     /ap world - world map     /ap search <item>     /ap reset - window position and size"] = "Atlas Plus %s (Circle Edition) by Saranwrap & dadec666. Instance maps and legends from Atlas (GPL v2). Zone levels from LibTourist-3.0 (MIT). Database aligned with wowroad.info.\\n/ap - open / close     /ap here - map of where you are     /ap world - world map     /ap search <item>     /ap reset - window position and size"

-- Interface options panel
L["Open Atlas Plus"] = "Open Atlas Plus"
L["Instance maps with every boss and its loot, item search, and world map zone info.\\n\\n/ap - open / close     /ap here - map of where you are     /ap settings"] = "Instance maps with every boss and its loot, item search, and world map zone info.\\n\\n/ap - open / close     /ap here - map of where you are     /ap settings"

-- World Map coords & combat notice
L["Player"] = "Player"
L["Cursor"] = "Cursor"
L["Map controls disabled in combat"] = "Map controls disabled in combat"
L["could not %s the game's map (%s). It opens on its own instead; please report this message."] = "could not %s the game's map (%s). It opens on its own instead; please report this message."

-- Markers
L["Dungeon"] = "Dungeon"
L["Raid"] = "Raid"
L["World boss"] = "World boss"
L["Boat"] = "Boat"
L["Zeppelin"] = "Zeppelin"
L["Tram"] = "Tram"
L["Portal"] = "Portal"
L["Click: map, bosses and loot"] = "Click: map, bosses and loot"
L["Click: go to %s"] = "Click: go to %s"
L["Show on the map"] = "Show on the map"
L["Transports and portals"] = "Transports and portals"
L["Only my faction's"] = "Only my faction's"
L["Find on the map"] = "Find on the map"
L["Search a name or a zone..."] = "Search a name or a zone..."
L["All"] = "All"
L["Dungeons"] = "Dungeons"
L["Raids"] = "Raids"
L["Bosses"] = "Bosses"
L["Boats"] = "Boats"
L["Zeppelins"] = "Zeppelins"
L["Portals"] = "Portals"

-- Slash commands & bindings
L["Open / close Atlas Plus"] = "Open / close Atlas Plus"
L["Window position, size and opacity reset."] = "Window position, size and opacity reset."
L["/ap - open / close    /ap here - map of where you are    /ap world - world map    /ap search <item>    /ap settings    /ap reset"] = "/ap - open / close    /ap here - map of where you are    /ap world - world map    /ap search <item>    /ap settings    /ap reset"

-- Additional strings
L["In combat: the map comes back when the fight ends.\\nThe map key (M) opens the game's map meanwhile."] = "In combat: the map comes back when the fight ends.\\nThe map key (M) opens the game's map meanwhile."
L["In towns"] = "In towns"
L["Transports, portals, towns"] = "Transports, portals, towns"
L["Flights"] = "Flights"
L["Inns"] = "Inns"
L["Auction"] = "Auction"
L["Mail"] = "Mail"
L["Flight master"] = "Flight master"
L["Innkeeper"] = "Innkeeper"
L["Mailbox"] = "Mailbox"
L["Bank"] = "Bank"
L["Auction house"] = "Auction house"

-- WorldView strings
L["< Zoom out"] = "< Zoom out"
L["Zone > continent > world. Right-click on the map does the same."] = "Zone > continent > world. Right-click on the map does the same."
L["Zone"] = "Zone"
L["Find me"] = "Find me"
L["The map of your zone, with a pulse on your arrow."] = "The map of your zone, with a pulse on your arrow."
L["Game map"] = "Game map"
L["The game's full screen map, with the quest list."] = "The game's full screen map, with the quest list."
L["Quests"] = "Quests"
L["Show or hide quest objectives on the map."] = "Show or hide quest objectives on the map."
L["Find"] = "Find"
L["Find a dungeon, raid, world boss, boat, zeppelin, tram or portal and show it on the map."] = "Find a dungeon, raid, world boss, boat, zeppelin, tram or portal and show it on the map."
L["Markers"] = "Markers"
L["Choose which markers the map shows."] = "Choose which markers the map shows."
L["Left-click: zoom in    Right-click: zoom out"] = "Left-click: zoom in    Right-click: zoom out"

-- UI additions
L["Location: "] = "Location: "
L["Drops in: "] = "Drops in: "
L["Honor Points"] = "Honor Points"
L["Arena Points"] = "Arena Points"
L["Gold"] = "Gold"
L["Click: open / close"] = "Click: open / close"
L["Right-click: settings"] = "Right-click: settings"
L["Drag: move button"] = "Drag: move button"
L["Resize: drag this corner"] = "Resize: drag this corner"

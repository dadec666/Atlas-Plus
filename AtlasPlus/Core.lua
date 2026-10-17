--[[
    Atlas Plus - core: saved settings, auto-select, slash commands, events
    Authors: Saranwrap, dadec666

    Instance maps and their legends come from Atlas (GPL v2, Dan Gilbert and contributors).
    Loot and drop chances based on standard 3.3.5a WotLK database (wowroad.info).
]]

local ADDON_NAME = ...
AtlasPlus = AtlasPlus or {}
local AP = AtlasPlus
AP.VERSION = "1.10.1-circle"
AP.MEDIA = "Interface\\AddOns\\" .. ADDON_NAME .. "\\"
AP.MAPS = AP.MEDIA .. "Images\\Maps\\"
AP.ACCENT = "|cfffc7a2b" 

local DEFAULTS = {
    autoSelect = true,      -- open on the map of the instance (or entrance) you are in
    autoOpen = false,       -- open by itself when you enter a dungeon or raid
    minimap = { hide = false, angle = 200 },
    locked = false,
    scale = 1,
    alpha = 1,
    worldZoneInfo = true,   -- world map: level range and instances of the zone under the cursor
    worldCoords = true,     -- world map: player and cursor coordinates
    zoneBlock = true,       -- world map page: info of the zone shown (top left)
    markers = { dungeon = true, raid = true, worldboss = true, boat = true, zepp = true, tram = true, portal = true,
                flight = true, inn = true, mail = true, bank = true, auction = true },
    townScale = 1,          -- size of the town markers (flight masters, inns, mailboxes, banks, auction houses)
    fadeAlpha = 0.5,        -- window opacity while moving
    myFactionOnly = true,   -- transports and portals: only yours and neutral ones
    pinScale = 1,           -- size of the map markers
    continentMarkers = true,-- markers on continent maps too
    questScale = 1,         -- size of the game's quest icons on the map
    gameInstanceMaps = true,-- in an instance: the game's interactive map when it has one
    hideQuestieInstances = true, -- Atlas Plus dungeon / raid icons replace Questie's
    fadeMoving = true,      -- the window fades to 50% while you move (mouse away)
    showUnexplored = true,  -- no fog of war: unexplored areas are drawn
    darkenUnexplored = true,
    replaceWorldMap = true, -- the world map key (M) opens Atlas Plus on its world map page
    gameMapAlpha = 1,       -- the game's own world map (when opened from Atlas Plus)
    gameSmallScale = 1,     -- the game's small world map
    listW = 175,            -- width of the instance list (drag the bar between the list and the map)
    lastMap = "TheDeadmines",
    modes = {},             -- last loot mode per map
    collapsed = {},         -- collapsed categories in the list
}

-- Categories, in list order
AP.CATEGORIES = {
    "Classic Dungeons", "Classic Raids",
    "Burning Crusade Dungeons", "Burning Crusade Raids",
    "Wrath of the Lich King Dungeons", "Wrath of the Lich King Raids",
    "World Drops", "World Events", "Vendors",
    "Entrances", "Dungeon Locations",
}
-- icon of the pages that have no map
AP.CAT_ICON = {
    ["World Drops"] = "Interface\\Icons\\INV_Misc_Bag_10_Blue",
    ["World Events"] = "Interface\\Icons\\INV_Misc_Gift_02",
    ["Vendors"] = "Interface\\Icons\\INV_Misc_Coin_02",
}

AP.MODE_LABEL = { N = AP.L["Normal"], H = AP.L["Heroic"], ["10"] = "10", ["25"] = "25", ["10H"] = AP.L["10 Heroic"], ["25H"] = AP.L["25 Heroic"] }

local function CopyDefaults(dst, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) ~= "table" then dst[k] = {} end
            CopyDefaults(dst[k], v)
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
end

function AP:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(AP.ACCENT .. "Atlas Plus|r: " .. tostring(msg))
end

---------------------------------------------------------------------------
-- Map list (sorted per category)
---------------------------------------------------------------------------
local function MinLevel(m)
    return tonumber((m.lvl or ""):match("^(%d+)")) or 99
end

function AP:BuildIndex()
    local byCat = {}
    for _, c in ipairs(self.CATEGORIES) do byCat[c] = {} end
    for key, m in pairs(AtlasPlus_Maps) do
        m.key = key
        local list = byCat[m.cat]
        if list then list[#list + 1] = key end
    end
    for cat, list in pairs(byCat) do
        table.sort(list, function(a, b)
            local ma, mb = AtlasPlus_Maps[a], AtlasPlus_Maps[b]
            if ma.order or mb.order then return (ma.order or 0) < (mb.order or 0) end
            if cat ~= "Entrances" and cat ~= "Dungeon Locations" then
                local la, lb = MinLevel(ma), MinLevel(mb)
                if la ~= lb then return la < lb end
            end
            return ma.name < mb.name
        end)
    end
    self.byCategory = byCat

    -- area id -> map key (entrance legends link to instance maps)
    self.byArea = {}
    for key, m in pairs(AtlasPlus_Maps) do
        if m.area and m.cat ~= "Entrances" and not self.byArea[m.area] then self.byArea[m.area] = key end
    end
end

---------------------------------------------------------------------------
-- Auto-select: the map of the instance (or the entrance of the zone) you are in
---------------------------------------------------------------------------
local function ZoneShortName(m)
    -- "Auchindoun: Mana-Tombs" -> "Mana-Tombs", "Ulduar [A] (The Siege)" -> "Ulduar"
    local z = m.full or m.name or ""
    z = z:gsub("%s*%b[]", ""):gsub("%s*%b()", "")
    return z:match(":%s*(.+)$") or z
end

-- zone names that differ from the map names
local ZONE_FIX = { ["Tempest Keep"] = "TempestKeepTheEye" }

function AP:FindMapForLocation()
    local A = AtlasPlus_Assoc
    local zone = GetRealZoneText() or ""
    zone = A.substitutions[zone] or zone
    local sub = GetSubZoneText() or ""
    local inInstance = IsInInstance()

    -- multi-map instances (Ulduar, Icecrown Citadel, Karazhan, Dire Maul...): pick the wing by subzone
    local defaultWing = A.defaults[zone] or (AP.L and A.defaults[AP.L[zone]])
    if defaultWing then
        local key = A.subzones[sub] or (AP.L and A.subzones[AP.L[sub]])
        if key and AtlasPlus_Maps[key] and (A.zoneOf[key] == zone or (AP.L and AP.L[A.zoneOf[key]] == zone)) then return key end
        -- staying in the same instance: keep the wing already shown
        local cur = self.db.lastMap
        if cur and (A.zoneOf[cur] == zone or (AP.L and AP.L[A.zoneOf[cur]] == zone)) then return cur end
        return defaultWing
    end

    if inInstance then
        if ZONE_FIX[zone] then return ZONE_FIX[zone] end
        for key, m in pairs(AtlasPlus_Maps) do
            if m.cat ~= "Entrances" and m.cat ~= "Dungeon Locations" and not m.nomap then
                local full = (m.full or ""):gsub("%s*%b[]", ""):gsub("%s*%b()", "")
                local short = ZoneShortName(m)
                if full == zone or short == zone or (AP.L and (AP.L[full] == zone or AP.L[short] == zone or AP.L[m.name] == zone)) then
                    return key
                end
            end
        end
    end

    return nil
end

-- Map of an instance from its zone name ("Utgarde Keep", "Ulduar", "Ahn'kahet: The Old Kingdom")
function AP:KeyForZoneName(zone)
    local A = AtlasPlus_Assoc
    zone = A.substitutions[zone] or zone
    if A.defaults[zone] then return A.defaults[zone] end
    if AP.L and A.defaults[AP.L[zone]] then return A.defaults[AP.L[zone]] end
    if ZONE_FIX[zone] then return ZONE_FIX[zone] end
    for key, m in pairs(AtlasPlus_Maps) do
        if m.cat ~= "Entrances" and m.cat ~= "Dungeon Locations" and not m.nomap then
            local full = (m.full or ""):gsub("%s*%b[]", ""):gsub("%s*%b()", "")
            local short = ZoneShortName(m)
            if full == zone or short == zone or (AP.L and (AP.L[full] == zone or AP.L[short] == zone or AP.L[m.name] == zone)) then
                return key
            end
        end
    end
end

-- Group size of an instance: "5", "10", "10/25"... (Atlas data, then the zone data)
local SIZE_FIX = { ["Blackrock Spire"] = "5/10", ["Scarlet Monastery"] = "5", ["Tempest Keep"] = "5/25" }  -- BRS: Lower 5, Upper 10
local sizeCache = {}
function AP:GroupSize(name)
    if sizeCache[name] ~= nil then return sizeCache[name] or nil end
    local size = SIZE_FIX[name]
    if not size then
        local key = self:KeyForZoneName(name)
        local m = key and AtlasPlus_Maps[key]
        if m and m.players and m.players ~= "" then size = m.players end
    end
    if not size then
        local z = AtlasPlus_Zones[name]
        if z and z[5] and z[5] > 0 then size = tostring(z[5]) end
    end
    sizeCache[name] = size or false
    return size
end

-- a raid: more than 5 players (Blackrock Spire counts as a dungeon)
function AP:IsRaid(name)
    local s = self:GroupSize(name)
    return s and (tonumber(s:match("^(%d+)")) or 0) > 5 or false
end

-- Loot mode that matches the difficulty you are in
function AP:CurrentMode(key)
    local m = AtlasPlus_Maps[key]
    if not (m and m.modes) then return nil end
    if not IsInInstance() then return nil end
    local diff = GetInstanceDifficulty and GetInstanceDifficulty() or 1
    local want
    if m.modes[1] == "N" then
        want = (diff >= 2) and "H" or "N"
    else
        want = ({ "10", "25", "10H", "25H" })[diff] or "10"
    end
    for _, md in ipairs(m.modes) do if md == want then return want end end
    return nil
end

-- In an instance: its map. Outdoors: the world map page on your zone.
function AP:AutoSelect(force)
    if not (self.db.autoSelect or force) then return end
    local inInst = IsInInstance()
    local key = inInst and self:FindMapForLocation()
    -- the game's own instance map (World map page, follows your floor) when there is one (WotLK or WDM-patch)
    if inInst and self.db.gameInstanceMaps and self.WorldMap:InstanceMapAvailable() then
        self.UI:ShowWorld()
        return
    end
    if key then
        local mode = self:CurrentMode(key)
        if mode then self.db.modes[key] = mode end
        self.UI:OpenInstance(key)
    else
        self.UI:ShowWorld()
    end
end

---------------------------------------------------------------------------
-- Dungeon & Raid Game Map IDs (Classic & TBC WDM-patch + Native WotLK)
---------------------------------------------------------------------------
AP.GAME_MAP_IDS = AP.GAME_MAP_IDS or {}
local GAME_MAP_IDS_DEF = {
    -- Classic Dungeons (WDM-patch: 680..765)
    ["RagefireChasm"] = 680, ["Ragefire Chasm"] = 680,
    ["ZulFarrak"] = 686, ["Zul'Farrak"] = 686,
    ["SunkenTemple"] = 687, ["The Temple of Atal'Hakkar"] = 687,
    ["BlackfathomDeeps"] = 688, ["Blackfathom Deeps"] = 688,
    ["TheStockade"] = 690, ["The Stockade"] = 690,
    ["Gnomeregan"] = 691,
    ["Uldaman"] = 692,
    ["DireMaulEast"] = 699, ["DireMaulNorth"] = 699, ["DireMaulWest"] = 699, ["Dire Maul"] = 699,
    ["BlackrockDepths"] = 704, ["Blackrock Depths"] = 704,
    ["BlackrockSpireLower"] = 721, ["BlackrockSpireUpper"] = 721, ["Blackrock Spire"] = 721,
    ["WailingCaverns"] = 749, ["Wailing Caverns"] = 749,
    ["Maraudon"] = 750,
    ["TheDeadmines"] = 756, ["Deadmines"] = 756, ["The Deadmines"] = 756,
    ["RazorfenDowns"] = 760, ["Razorfen Downs"] = 760,
    ["RazorfenKraul"] = 761, ["Razorfen Kraul"] = 761,
    ["ScarletMonastery"] = 762, ["ScarletMonasteryGraveyard"] = 762, ["ScarletMonasteryLibrary"] = 762,
    ["ScarletMonasteryArmory"] = 762, ["ScarletMonasteryCathedral"] = 762,
    ["Scholomance"] = 763,
    ["ShadowfangKeep"] = 764, ["Shadowfang Keep"] = 764,
    ["Stratholme"] = 765,

    -- Classic Raids (WDM-patch: 696..766)
    ["MoltenCore"] = 696, ["Molten Core"] = 696,
    ["ZulGurub"] = 697, ["Zul'Gurub"] = 697,
    ["RuinsOfAhnQiraj"] = 717, ["Ruins of Ahn'Qiraj"] = 717,
    ["BlackwingLair"] = 755, ["Blackwing Lair"] = 755,
    ["TempleOfAhnQiraj"] = 766, ["Ahn'Qiraj"] = 766,

    -- TBC Dungeons (WDM-patch: 710..798)
    ["HellfireRamparts"] = 797, ["Hellfire Ramparts"] = 797,
    ["TheBloodFurnace"] = 725, ["The Blood Furnace"] = 725,
    ["TheShatteredHalls"] = 710, ["The Shattered Halls"] = 710,
    ["TheSlavePens"] = 728, ["The Slave Pens"] = 728,
    ["TheUnderbog"] = 726, ["The Underbog"] = 726,
    ["TheSteamvault"] = 727, ["The Steamvault"] = 727,
    ["ManaTombs"] = 732, ["Mana-Tombs"] = 732,
    ["AuchenaiCrypts"] = 722, ["Auchenai Crypts"] = 722,
    ["SethekkHalls"] = 723, ["Sethekk Halls"] = 723,
    ["ShadowLabyrinth"] = 724, ["Shadow Labyrinth"] = 724,
    ["OldHillsbrad"] = 734, ["Old Hillsbrad Foothills"] = 734,
    ["TheBlackMorass"] = 733, ["The Black Morass"] = 733,
    ["TheBotanica"] = 729, ["The Botanica"] = 729,
    ["TheMechanar"] = 730, ["The Mechanar"] = 730,
    ["TheArcatraz"] = 731, ["The Arcatraz"] = 731,
    ["MagistersTerrace"] = 798, ["Magisters' Terrace"] = 798,

    -- TBC Raids (WDM-patch + native: 775..799)
    ["Karazhan"] = 799,
    ["GruulsLair"] = 776, ["Gruul's Lair"] = 776,
    ["MagtheridonsLair"] = 779, ["Magtheridon's Lair"] = 779,
    ["SerpentshrineCavern"] = 780, ["Serpentshrine Cavern"] = 780,
    ["TheEye"] = 782, ["The Eye"] = 782, ["Tempest Keep"] = 782,
    ["BattleForMountHyjal"] = 775, ["Hyjal Summit"] = 775,
    ["BlackTemple"] = 796, ["Black Temple"] = 796,
    ["SunwellPlateau"] = 789, ["Sunwell Plateau"] = 789,

    -- WotLK Dungeons (Native: 520..603)
    ["UtgardeKeep"] = 523, ["Utgarde Keep"] = 523,
    ["TheNexus"] = 520, ["The Nexus"] = 520,
    ["AzjolNerub"] = 533, ["Azjol-Nerub"] = 533,
    ["Ahnkahet"] = 522, ["Ahn'kahet: The Old Kingdom"] = 522,
    ["DrakTharonKeep"] = 534, ["Drak'Tharon Keep"] = 534,
    ["TheVioletHold"] = 536, ["The Violet Hold"] = 536,
    ["Gundrak"] = 530,
    ["HallsOfStone"] = 526, ["Halls of Stone"] = 526,
    ["HallsOfLightning"] = 525, ["Halls of Lightning"] = 525,
    ["TheOculus"] = 528, ["The Oculus"] = 528,
    ["UtgardePinnacle"] = 524, ["Utgarde Pinnacle"] = 524,
    ["CullingOfStratholme"] = 521, ["The Culling of Stratholme"] = 521,
    ["TrialOfTheChampion"] = 542, ["Trial of the Champion"] = 542,
    ["TheForgeOfSouls"] = 601, ["The Forge of Souls"] = 601,
    ["PitOfSaron"] = 602, ["Pit of Saron"] = 602,
    ["HallsOfReflection"] = 603, ["Halls of Reflection"] = 603,

    -- WotLK Raids (Native: 527..718)
    ["Naxxramas"] = 535,
    ["TheObsidianSanctum"] = 531, ["The Obsidian Sanctum"] = 531,
    ["TheEyeOfEternity"] = 527, ["The Eye of Eternity"] = 527,
    ["VaultOfArchavon"] = 532, ["Vault of Archavon"] = 532,
    ["Ulduar"] = 529,
    ["TrialOfTheCrusader"] = 543, ["Trial of the Crusader"] = 543,
    ["OnyxiasLair"] = 718, ["Onyxia's Lair"] = 718,
    ["IcecrownCitadel"] = 604, ["Icecrown Citadel"] = 604,
    ["TheRubySanctum"] = 609, ["The Ruby Sanctum"] = 609,

    -- Battlegrounds (Native: 401..540)
    ["AlteracValley"] = 401, ["Alterac Valley"] = 401,
    ["WarsongGulch"] = 443, ["Warsong Gulch"] = 443,
    ["ArathiBasin"] = 461, ["Arathi Basin"] = 461,
    ["EyeOfTheStorm"] = 482, ["Eye of the Storm"] = 482,
    ["StrandOfTheAncients"] = 512, ["Strand of the Ancients"] = 512,
    ["IsleOfConquest"] = 540, ["Isle of Conquest"] = 540,
}
for k, v in pairs(GAME_MAP_IDS_DEF) do
    if not AP.GAME_MAP_IDS[k] then AP.GAME_MAP_IDS[k] = v end
end

function AP:DetectWDMPatch()
    if self.hasWDMPatch ~= nil then return self.hasWDMPatch end
    -- Check if WDM patch is installed (e.g. Deadmines mapID 756 exists in client WorldMapArea.dbc)
    local orig = GetCurrentMapAreaID and GetCurrentMapAreaID()
    SetMapByID(756)
    local info = GetMapInfo()
    self.hasWDMPatch = (info == "TheDeadmines" or info == "Deadmines")
    if orig and orig > 0 then SetMapByID(orig - 1) else SetMapToCurrentZone() end
    return self.hasWDMPatch
end

function AP:GetGameMapID(keyOrName)
    if not keyOrName then return nil end
    local id = self.GAME_MAP_IDS[keyOrName]
    if not id and AP.L then
        id = self.GAME_MAP_IDS[AP.L[keyOrName]]
    end
    if not id and AtlasPlus_Maps then
        local m = AtlasPlus_Maps[keyOrName]
        if m then
            id = (m.name and self.GAME_MAP_IDS[m.name]) or (m.full and self.GAME_MAP_IDS[m.full])
            if not id and AP.L then
                id = (m.name and self.GAME_MAP_IDS[AP.L[m.name]]) or (m.full and self.GAME_MAP_IDS[AP.L[m.full]])
            end
        end
    end
    return id
end

function AP:IsGameMapAvailable(mapID)
    if not mapID then return false end
    if mapID < 680 or mapID == 718 then return true end
    return self:DetectWDMPatch()
end


---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
events:RegisterEvent("ZONE_CHANGED")
events:RegisterEvent("ZONE_CHANGED_INDOORS")
events:RegisterEvent("PLAYER_ENTERING_WORLD")

local lastInstanceZone
events:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        AtlasPlusDB = AtlasPlusDB or {}
        if AtlasPlusDB.instancePins == false then AtlasPlusDB.dungeonPins, AtlasPlusDB.raidPins = false, false end
        AtlasPlusDB.instancePins = nil
        if AtlasPlusDB.dungeonPins ~= nil or AtlasPlusDB.raidPins ~= nil then
            AtlasPlusDB.markers = AtlasPlusDB.markers or {}
            if AtlasPlusDB.dungeonPins == false then AtlasPlusDB.markers.dungeon = false end
            if AtlasPlusDB.raidPins == false then AtlasPlusDB.markers.raid = false end
            AtlasPlusDB.dungeonPins, AtlasPlusDB.raidPins = nil, nil
        end
        CopyDefaults(AtlasPlusDB, DEFAULTS)
        AP.db = AtlasPlusDB
        if not AtlasPlus_Maps[AP.db.lastMap] then AP.db.lastMap = DEFAULTS.lastMap end
        AP:BuildIndex()
    elseif event == "PLAYER_LOGIN" then
        AP:DetectWDMPatch()
        AP.UI:Create()
        AP.UI:CreateMinimapButton()
        if AP.WorldMap then AP.WorldMap:Init() end
        AP.Markers:Init()
        AP.Fog:Init()
        AP.UI:CreateInterfacePanel()
    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        if not AP.db then return end
        local inInstance, kind = IsInInstance()
        local zone = GetRealZoneText()
        if AP.db.autoOpen and inInstance and (kind == "party" or kind == "raid") and zone ~= lastInstanceZone then
            lastInstanceZone = zone
            AP.UI:Show()
        end
        if not inInstance then lastInstanceZone = nil end
        if event == "PLAYER_ENTERING_WORLD" and AP.UI.frame and AP.UI.frame:IsShown() then AP:AutoSelect() end
    elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" then
        -- new wing / floor of a multi-map instance
        if AP.UI.frame and AP.UI.frame:IsShown() and IsInInstance() and AP.db.autoSelect then
            local key = AP:FindMapForLocation()
            if key and key ~= AP.UI.mapKey and AtlasPlus_Assoc.zoneOf[key] and AP.UI.page == "instance" then AP.UI:SelectMap(key) end
        end
    end
end)

---------------------------------------------------------------------------
-- Slash commands / key binding
---------------------------------------------------------------------------
BINDING_HEADER_ATLASPLUS = "Atlas Plus"
BINDING_NAME_ATLASPLUS_TOGGLE = AP.L["Open / close Atlas Plus"]

function AtlasPlus_Toggle() AP.UI:Toggle() end

SLASH_ATLASPLUS1 = "/atlasplus"
SLASH_ATLASPLUS2 = "/ap"
SlashCmdList.ATLASPLUS = function(msg)
    msg = strlower(strtrim(msg or ""))
    if msg == "" then
        AP.UI:Toggle()
    elseif msg == "settings" or msg == "options" or msg == "config" then
        AP.UI:ShowSettings()
    elseif msg == "here" or msg == "current" then
        AP.UI:Show()
        AP:AutoSelect(true)
    elseif msg == "world" or msg == "map" then
        AP.UI:Show()
        AP.UI:ShowWorld()
    elseif msg == "reset" then
        AP.db.pos = nil
        AP.db.scale, AP.db.alpha = 1, 1
        AP.db.gameMapAlpha, AP.db.gameSmallScale = 1, 1
        if AP.WorldMap then AP.WorldMap:Update() end
        AP.UI:ApplyLayout()
        AP:Print(AP.L["Window position, size and opacity reset."])
    elseif msg:match("^search ") then
        AP.UI:Show()
        AP.UI:Search(msg:match("^search (.+)$"))
    else
        AP:Print(AP.L["/ap - open / close    /ap here - map of where you are    /ap world - world map    /ap search <item>    /ap settings    /ap reset"])
    end
end

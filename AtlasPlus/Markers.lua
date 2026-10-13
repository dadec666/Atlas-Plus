--[[
    Atlas Plus - world map markers
    Dungeons and raids (click: their map and loot), world bosses, boats, zeppelins, the tram and portals
    (click: the map of the destination). Filter menu, "Find" list, and a pulse to show a spot or yourself.
    Author: Saranwrap
]]

local AP = AtlasPlus
local W = AP.W
local C = W.C
local MK = {}
AP.Markers = MK

local MAP_W, MAP_H = 1002, 668
local CONT = { ["Kalimdor"] = 1, ["Eastern Kingdoms"] = 2, ["Outland"] = 3, ["Northrend"] = 4 }
local ICONS = AP.MEDIA .. "Images\\MarkerIcons"
local SLOT = { boat = 0, zepp = 1, tram = 2, portal = 3, worldboss = 4 }
local RING = 5
local FACTION_COLOR = { Alliance = { 0.30, 0.55, 1 }, Horde = { 0.90, 0.22, 0.18 }, Neutral = { 0.95, 0.75, 0.25 } }

MK.TYPES = {
    { key = "dungeon",   label = "Dungeons" },
    { key = "raid",      label = "Raids" },
    { key = "worldboss", label = "World bosses" },
    { key = "boat",      label = "Boats" },
    { key = "zepp",      label = "Zeppelins" },
    { key = "tram",      label = "Tram" },
    { key = "portal",    label = "Portals" },
    { key = "flight",    label = "Flight masters", town = true },
    { key = "inn",       label = "Innkeepers", town = true },
    { key = "mail",      label = "Mailboxes", town = true },
    { key = "bank",      label = "Banks", town = true },
    { key = "auction",   label = "Auction houses", town = true },
}
local TYPE_LABEL = { dungeon = "Dungeon", raid = "Raid", worldboss = "World boss", boat = "Boat", zepp = "Zeppelin", tram = "Tram", portal = "Portal",
                     flight = "Flight master", inn = "Innkeeper", mail = "Mailbox", bank = "Bank", auction = "Auction house" }
-- town markers: the game's own minimap tracking icons
local TOWN = { flight = "FlightMaster", inn = "Innkeeper", mail = "Mailbox", bank = "Banker", auction = "Auctioneer" }
local TOWN_CODE = { f = "flight", i = "inn", m = "mail", b = "bank", a = "auction" }
local FAC_CODE = { A = "Alliance", H = "Horde", N = "Neutral" }
MK.TOWN = TOWN
local TRAVEL = { boat = true, zepp = true, tram = true, portal = true }

---------------------------------------------------------------------------
-- Marker list
---------------------------------------------------------------------------
local all, byZone

local function Build()
    all, byZone = {}, {}
    local function add(m)
        all[#all + 1] = m
        byZone[m.zone] = byZone[m.zone] or {}
        table.insert(byZone[m.zone], m)
    end
    for _, e in ipairs(AtlasPlus_Markers) do
        local dest = {}
        for _, d in ipairs(e[10]) do dest[#dest + 1] = { cont = d[1], zone = d[2], x = d[3], y = d[4], floor = d[5] } end
        add({ type = e[1], fac = e[2], name = e[3], note = e[4] ~= "" and e[4] or nil, cont = e[5], zone = e[6],
              x = e[7], y = e[8], floor = e[9], dest = dest })
    end
    for _, e in ipairs(AtlasPlus_Town or {}) do
        add({ type = TOWN_CODE[e[1]], fac = FAC_CODE[e[2]], name = e[3], cont = e[4], zone = e[5], x = e[6], y = e[7], floor = e[8], dest = {}, town = true })
    end
    local SKIP = { ["Scarlet Monastery"] = true, ["Tempest Keep"] = true, ["Hellfire Citadel"] = true,
                   ["Coilfang Reservoir"] = true, ["Caverns of Time"] = true, ["Ring of Observance"] = true }   -- groups of wings
    for iname, iz in pairs(AtlasPlus_Zones) do
        local ent = not SKIP[iname] and (AtlasPlus_EntranceFix[iname] or iz[9])
        local key = ent and AP:KeyForZoneName(iname)
        local cont = ent and AtlasPlus_Zones[ent[1]] and CONT[AtlasPlus_Zones[ent[1]][3]]
        if key and cont then
            add({ type = AP:IsRaid(iname) and "raid" or "dungeon", fac = "Neutral", name = iname, key = key,
                  cont = cont, zone = ent[1], x = ent[2], y = ent[3], floor = 0, low = iz[1], high = iz[2], size = AP:GroupSize(iname) })
        end
    end
end

function MK:All() if not all then Build() end return all end

function MK:Visible(m)
    local db = AP.db
    if not db.markers[m.type] then return false end
    if db.myFactionOnly and (TRAVEL[m.type] or m.town) and m.fac ~= "Neutral" and m.fac ~= UnitFactionGroup("player") then return false end
    return true
end

---------------------------------------------------------------------------
-- Pins on the game's map
---------------------------------------------------------------------------
local pool = {}

local function Levels(m)
    if not m.low or m.low == 0 then return nil end
    local r = (m.low == m.high) and tostring(m.low) or (m.low .. "-" .. m.high)
    return AP.WorldView.LevelColor(m.low, m.high) .. "Level " .. r .. "|r" .. (m.size and ("  " .. m.size .. "-man") or "")
end
MK.Levels = Levels

local function PinOnEnter(self)
    local m = self.m
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(m.name, 1, 1, 1)
    local fc = FACTION_COLOR[m.fac]
    local kind = TYPE_LABEL[m.type] .. (((TRAVEL[m.type] or m.town) and m.fac ~= "Neutral") and (" (" .. m.fac .. ")") or "")
    GameTooltip:AddLine(kind, fc[1], fc[2], fc[3])
    if Levels(m) then GameTooltip:AddLine(Levels(m)) end
    if m.note then GameTooltip:AddLine(m.note, 0.8, 0.8, 0.8) end
    if m.key then
        GameTooltip:AddLine("Click: map, bosses and loot", 0.6, 0.6, 0.6)
    elseif m.dest and m.dest[1] then
        GameTooltip:AddLine("Click: go to " .. m.dest[1].zone, 0.6, 0.6, 0.6)
    end
    GameTooltip:Show()
end

local function PinOnClick(self, button)
    local m = self.m
    if button == "RightButton" then AP.WorldView:ZoomOut() return end
    if m.key then
        if not AP.WorldMap.embedded and WorldMapFrame:IsShown() then HideUIPanel(WorldMapFrame) end
        AP.UI:OpenInstance(m.key)
    elseif m.dest and m.dest[1] then
        local d = m.dest[1]
        MK:GoTo(d.cont, d.zone, d.x, d.y, d.floor)
    end
end

local function Pin(i)
    local p = pool[i]
    if p then return p end
    p = CreateFrame("Button", nil, WorldMapButton)
    p:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    p.tex = p:CreateTexture(nil, "ARTWORK")
    p.tex:SetAllPoints()
    p.ring = p:CreateTexture(nil, "OVERLAY")
    p.ring:SetAllPoints()
    p.ring:SetTexture(ICONS)
    p.ring:SetTexCoord(RING * 64 / 512, (RING + 1) * 64 / 512, 0, 1)
    local hl = p:CreateTexture(nil, "HIGHLIGHT")
    hl:SetPoint("TOPLEFT", -6, 6)
    hl:SetPoint("BOTTOMRIGHT", 6, -6)
    hl:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    hl:SetBlendMode("ADD")
    p:SetScript("OnClick", PinOnClick)
    p:SetScript("OnEnter", PinOnEnter)
    p:SetScript("OnLeave", function() GameTooltip:Hide() end)
    pool[i] = p
    return p
end

function MK:Draw()
    for _, p in ipairs(pool) do p:Hide() end
    if not (WorldMapButton and AP.db and all) then return end
    local c, z = GetCurrentMapContinent(), GetCurrentMapZone()
    if not (c and c > 0 and c <= 4) then return end
    local onContinent = not (z and z > 0)
    local list, level = {}, GetCurrentMapDungeonLevel and GetCurrentMapDungeonLevel() or 0
    if onContinent then
        if not AP.db.continentMarkers then return end
        for _, m in ipairs(all) do
            local r = m.cont == c and not m.town and AtlasPlus_ZoneRects[m.zone]
            if r and self:Visible(m) then
                list[#list + 1] = { m = m, x = r[2] + m.x * r[4], y = r[3] + m.y * r[5] }
            end
        end
    else
        local zone = select(z, GetMapZones(c))
        for _, m in ipairs(zone and byZone[zone] or {}) do
            if self:Visible(m) and (m.floor == 0 or m.floor == level) then list[#list + 1] = { m = m, x = m.x, y = m.y } end
        end
    end
    local scale = (AP.db.pinScale or 1) * (onContinent and 0.75 or 1)
    local n = 0
    for _, e in ipairs(list) do
        local m = e.m
        do
            n = n + 1
            local p = Pin(n)
            p.m = m
            local size = m.town and 16 * (AP.db.townScale or 1) or (m.key and 21 or 19) * scale
            W.Size(p, size, size)
            p:SetFrameLevel(WorldMapButton:GetFrameLevel() + 3)
            if m.town then
                p.tex:SetTexture("Interface\\Minimap\\Tracking\\" .. TOWN[m.type])
                p.tex:SetTexCoord(0, 1, 0, 1)
                p.ring:Hide()
            elseif m.key then
                p.tex:SetTexture(AP.MEDIA .. "Images\\InstanceIcons")
                if m.type == "raid" then p.tex:SetTexCoord(37 / 64, 59 / 64, 5 / 32, 27 / 32) else p.tex:SetTexCoord(5 / 64, 27 / 64, 5 / 32, 27 / 32) end
                p.ring:Hide()
            else
                local s = SLOT[m.type]
                p.tex:SetTexture(ICONS)
                p.tex:SetTexCoord(s * 64 / 512, (s + 1) * 64 / 512, 0, 1)
                local fc = FACTION_COLOR[m.fac]
                p.ring:SetVertexColor(fc[1], fc[2], fc[3])
                p.ring:Show()
            end
            p.px, p.py, p.size, p.town = e.x / 100 * MAP_W, e.y / 100 * MAP_H, size, m.town
            p:Show()
        end
    end
    -- markers at the same spot side by side (Frozen Halls, city portals...)
    local groups = {}
    for i = 1, n do
        local p = pool[i]
        local g
        if p.town then g = { x = p.px, y = p.py, town = true }; groups[#groups + 1] = g end   -- town markers stay exactly in place
        for _, grp in ipairs(p.town and {} or groups) do
            if not grp.town and math.abs(grp.x - p.px) < p.size and math.abs(grp.y - p.py) < p.size then g = grp break end
        end
        if not g then g = { x = p.px, y = p.py }; groups[#groups + 1] = g end
        g[#g + 1] = p
    end
    for _, g in ipairs(groups) do
        for i, p in ipairs(g) do
            p:ClearAllPoints()
            p:SetPoint("CENTER", WorldMapButton, "TOPLEFT", g.x + (i - (#g + 1) / 2) * (p.size + 2), -g.y)
        end
    end
end

---------------------------------------------------------------------------
-- Go to a map, pulse a spot or the player
---------------------------------------------------------------------------
function MK:GoTo(cont, zone, x, y, floor)
    local function go()
        local idx
        for i, name in ipairs({ GetMapZones(cont) }) do if name == zone then idx = i end end
        if idx then SetMapZoom(cont, idx) else SetMapZoom(cont) end
        if floor and floor > 0 and SetDungeonMapLevel then SetDungeonMapLevel(floor) end
        if x and y then MK:Pulse(x / 100, y / 100) end
    end
    if AP.WorldMap.embedded or WorldMapFrame:IsVisible() then go() else AP.WorldMap:WhenShown(go) end
end

local pulse
local function PulseFrame()
    if pulse then return pulse end
    pulse = CreateFrame("Frame", nil, WorldMapButton)
    local t = pulse:CreateTexture(nil, "OVERLAY")
    t:SetAllPoints()
    t:SetTexture(AP.MEDIA .. "Images\\Pulse")
    t:SetBlendMode("ADD")
    pulse.tex = t
    pulse:Hide()
    pulse:SetScript("OnUpdate", function(self, elapsed)
        self.t = self.t + elapsed
        if self.t > 3 then self:Hide() return end
        local p = (self.t % 1)
        local s = self.base * (0.5 + 1.8 * p)
        W.Size(self, s, s)
        self.tex:SetAlpha(1 - p)
    end)
    return pulse
end

local function StartPulse(anchor, x, y, color)
    local f = PulseFrame()
    f:SetParent(WorldMapButton)
    f:SetFrameStrata(WorldMapFrame:GetFrameStrata())
    f:SetFrameLevel(290)
    f:ClearAllPoints()
    if anchor then f:SetPoint("CENTER", anchor, "CENTER") else f:SetPoint("CENTER", WorldMapButton, "TOPLEFT", x * MAP_W, -y * MAP_H) end
    f.tex:SetVertexColor(color[1], color[2], color[3])
    f.t, f.base = 0, 60
    f:Show()
end

function MK:Pulse(x, y) StartPulse(nil, x, y, C.accent) end

-- "Find me": the map of your zone, then a pulse on your arrow
function MK:FindMe()
    SetMapToCurrentZone()
    if WorldMapPlayer then StartPulse(WorldMapPlayer, nil, nil, { 1, 0.85, 0.2 }) end
    if WorldMapFrame_PingPlayerPosition then WorldMapFrame_PingPlayerPosition() end
end

---------------------------------------------------------------------------
-- Filter menu
---------------------------------------------------------------------------
function MK:FilterMenu(btn)
    local db = AP.db
    local menu = { { text = "Show on the map", isTitle = true, notCheckable = true } }
    for _, t in ipairs(MK.TYPES) do
        local key = t.key
        if key == "flight" then menu[#menu + 1] = { text = "In towns", isTitle = true, notCheckable = true } end
        menu[#menu + 1] = { text = t.label, checked = db.markers[key] and true or false, keepShownOnClick = true,
            func = function() db.markers[key] = not db.markers[key]; MK:Refresh() end }
    end
    menu[#menu + 1] = { text = "Transports, portals, towns", isTitle = true, notCheckable = true }
    menu[#menu + 1] = { text = "Only my faction's", checked = db.myFactionOnly and true or false, keepShownOnClick = true,
        func = function() db.myFactionOnly = not db.myFactionOnly; MK:Refresh() end }
    W.ShowMenu(menu, btn)
end

-- Questie draws its own dungeon and raid icons: hide them while ours are on, give them back otherwise
function MK:SyncQuestie(force)
    local Q = _G.Questie
    local p = Q and Q.db and Q.db.profile
    if not p then return end
    local db = AP.db
    local wantD, wantR
    if db.hideQuestieInstances then
        wantD, wantR = not db.markers.dungeon, not db.markers.raid
    elseif force then
        wantD, wantR = true, true
    else
        return
    end
    if p.showDungeonLocations == wantD and p.showRaidLocations == wantR then return end
    p.showDungeonLocations, p.showRaidLocations = wantD, wantR
    local IL = _G.QuestieLoader and QuestieLoader.ImportModule and QuestieLoader:ImportModule("InstanceLocations")
    if IL and IL.Refresh then pcall(IL.Refresh, IL) end
end

function MK:Refresh()
    self:SyncQuestie()
    self:Draw()
    if self.find and self.find:IsShown() then self:FillFind() end
end

---------------------------------------------------------------------------
-- Find panel (over the right side of the map)
---------------------------------------------------------------------------
local FIND_ROWS, FIND_ROW_H = 18, 18

function MK:CreateFind(parent, holder)
    local f = CreateFrame("Frame", nil, parent)
    f:SetFrameStrata("DIALOG")                       -- above the game's map
    f:SetPoint("TOPRIGHT", holder, "TOPRIGHT", -6, -6)
    f:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", -6, 6)
    f:SetWidth(330)
    f:EnableMouse(true)
    W.Backdrop(f, C.bg, C.line)
    f:Hide()
    self.find = f
    self.findCont, self.findType = 1, "all"

    local title = W.Text(f, "GameFontNormal")
    title:SetPoint("TOPLEFT", 10, -9)
    title:SetText(AP.ACCENT .. "Find on the map|r")
    local close = W.Button(f, "X", 22, 18)
    close:SetPoint("TOPRIGHT", -6, -6)
    close:SetScript("OnClick", function() f:Hide() end)

    -- a row of buttons filling 314 px: small font, each as wide as its text plus an equal share of the rest
    local function Row(buttons, labels, y, width, onClick)
        local row, textW = {}, 0
        for i, l in ipairs(labels) do
            local b = W.Button(f, l[2], width, 18)
            b:GetFontString():SetFontObject("GameFontHighlightSmall")
            b:SetText(l[2])
            b.textW = b:GetFontString():GetStringWidth() or 0
            textW = textW + b.textW
            b:SetScript("OnClick", function() onClick(l[1]) end)
            buttons[l[1]] = b
            row[i] = b
        end
        local extra = math.max(0, (314 - 3 * (#row - 1) - textW) / #row)
        local prev
        for _, b in ipairs(row) do
            b:SetWidth(b.textW + extra)
            if prev then b:SetPoint("LEFT", prev, "RIGHT", 3, 0) else b:SetPoint("TOPLEFT", 8, y) end
            prev = b
        end
    end
    self.contBtns, self.typeBtns = {}, {}
    local conts = {}
    for i, name in ipairs({ GetMapContinents() }) do conts[i] = { i, name } end
    Row(self.contBtns, conts, -30, 77, function(i)
        MK.findCont = i
        if MK.findText then MK.findText = nil; MK.findSearch:SetText("") end
        MK:FillFind()
    end)
    Row(self.typeBtns, { { "all", "All" }, { "dungeon", "Dungeons" }, { "raid", "Raids" }, { "worldboss", "Bosses" } }, -52, 77,
        function(k) MK.findType = k; MK:FillFind() end)
    Row(self.typeBtns, { { "boat", "Boats" }, { "zepp", "Zeppelins" }, { "tram", "Tram" }, { "portal", "Portals" } }, -74, 77,
        function(k) MK.findType = k; MK:FillFind() end)
    Row(self.typeBtns, { { "flight", "Flights" }, { "inn", "Inns" }, { "bank", "Banks" }, { "auction", "Auction" }, { "mail", "Mail" } }, -96, 60,
        function(k) MK.findType = k; MK:FillFind() end)

    local search = W.EditBox(f, 314, 20, "Search a name or a zone...")
    search:SetPoint("TOPLEFT", 8, -120)
    search:SetScript("OnTextChanged", function(eb)
        local t = strtrim(eb:GetText() or "")
        if t == "" then eb.placeholder:Show(); eb.clear:Hide() else eb.placeholder:Hide(); eb.clear:Show() end
        MK.findText = t ~= "" and strlower(t) or nil
        FauxScrollFrame_SetOffset(MK.findScroll, 0)
        MK.findScroll:SetVerticalScroll(0)
        MK:FillFind()
    end)
    self.findSearch = search

    local empty = W.Text(f, "GameFontDisableSmall")
    empty:SetPoint("TOP", 0, -162)
    self.findEmpty = empty

    self.findRows = {}
    for i = 1, FIND_ROWS do
        local r = CreateFrame("Button", nil, f)
        r:SetHeight(FIND_ROW_H)
        r:SetPoint("TOPLEFT", 6, -146 - (i - 1) * FIND_ROW_H)
        r:SetPoint("RIGHT", f, "RIGHT", -20, 0)
        local hl = r:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetTexture(C.accent[1], C.accent[2], C.accent[3], 0.15)
        r.name = W.Text(r, "GameFontHighlightSmall")
        r.name:SetPoint("LEFT", 4, 0)
        r.name:SetJustifyH("LEFT")
        r.zone = W.Text(r, "GameFontDisableSmall")
        r.zone:SetPoint("RIGHT", -4, 0)
        r.zone:SetJustifyH("RIGHT")
        r:SetScript("OnClick", function(self)
            local m = self.m
            if not m then return end
            f:Hide()
            MK:GoTo(m.cont, m.zone, m.x, m.y, m.floor)
        end)
        r:SetScript("OnEnter", function(self) if self.m then PinOnEnter(self) end end)
        r:SetScript("OnLeave", function() GameTooltip:Hide() end)
        self.findRows[i] = r
    end
    local sf = CreateFrame("ScrollFrame", "AtlasPlusFindScroll", f, "FauxScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 6, -146)
    sf:SetPoint("BOTTOMRIGHT", -20, 8)
    sf:SetScript("OnVerticalScroll", function(s, offset)
        FauxScrollFrame_OnVerticalScroll(s, offset, FIND_ROW_H, function() MK:FillFind() end)
    end)
    W.FlatScroll(sf)
    self.findScroll = sf
    f:SetScript("OnShow", function()
        local c = GetCurrentMapContinent()
        if c and c >= 1 and c <= 4 then MK.findCont = c end
        FauxScrollFrame_SetOffset(sf, 0)
        sf:SetVerticalScroll(0)
        MK:FillFind()
    end)
    f:SetScript("OnSizeChanged", function() MK:FillFind() end)
end

function MK:FillFind()
    local f = self.find
    if not f then return end
    for i, b in pairs(self.contBtns) do b:SetSelected(i == self.findCont and not self.findText) end
    -- what this continent (or this search) has, before the type buttons; Find ignores the map's on / off
    -- filter (it is for finding things), but keeps "only my faction's"
    local db = AP.db
    local pool, count = {}, { all = 0 }
    for _, m in ipairs(self:All()) do
        local text = self.findText
        local ok
        if text then   -- search: every continent, name or zone
            ok = (strlower(m.name):find(text, 1, true) or strlower(m.zone):find(text, 1, true)) and true
        else
            ok = m.cont == self.findCont
        end
        if ok and db.myFactionOnly and (TRAVEL[m.type] or m.town) and m.fac ~= "Neutral" and m.fac ~= UnitFactionGroup("player") then ok = false end
        if ok then
            pool[#pool + 1] = m
            count[m.type] = (count[m.type] or 0) + 1
            count.all = count.all + 1
        end
    end
    if self.findType ~= "all" and not count[self.findType] then self.findType = "all" end
    for k, b in pairs(self.typeBtns) do
        local has = (count[k] or 0) > 0
        b:SetSelected(k == self.findType)
        if has then b:Enable(); b:GetFontString():SetTextColor(1, 1, 1) else b:Disable(); b:GetFontString():SetTextColor(0.35, 0.35, 0.35) end
    end
    local list = {}
    for _, m in ipairs(pool) do
        if self.findType == "all" or m.type == self.findType then list[#list + 1] = m end
    end
    self.findEmpty:SetText(#list == 0 and (self.findText and "Nothing found." or "Nothing on this continent.") or "")
    table.sort(list, function(a, b)
        if a.type ~= b.type and self.findType == "all" then return a.type < b.type end
        if (a.low or 0) ~= (b.low or 0) then return (a.low or 0) < (b.low or 0) end
        if a.name ~= b.name then return a.name < b.name end
        return a.zone < b.zone
    end)
    local h = f:GetHeight() or 0
    if h < 150 then h = (AP.WorldView.holder:GetHeight() or 400) - 12 end   -- not laid out yet
    local visible = math.max(1, math.min(FIND_ROWS, math.floor((h - 154) / FIND_ROW_H)))
    FauxScrollFrame_Update(self.findScroll, #list, visible, FIND_ROW_H)
    local off = FauxScrollFrame_GetOffset(self.findScroll)
    for i, r in ipairs(self.findRows) do
        local m = i <= visible and list[off + i]
        r.m = m or nil
        if m then
            local lv = m.low and m.low > 0 and (" " .. AP.WorldView.LevelColor(m.low, m.high) .. ((m.low == m.high) and m.low or (m.low .. "-" .. m.high)) .. "|r") or ""
            local fc = FACTION_COLOR[m.fac]
            local nameText = m.name
            if (TRAVEL[m.type] or m.town) and m.fac ~= "Neutral" then nameText = string.format("|cff%02x%02x%02x%s|r", fc[1] * 255, fc[2] * 255, fc[3] * 255, m.name) end
            r.name:SetText(nameText .. lv)
            r.zone:SetText(m.zone)
            r:Show()
        else
            r:Hide()
        end
    end
end

function MK:ToggleFind()
    if self.find:IsShown() then self.find:Hide() else self.find:Show() end
end

---------------------------------------------------------------------------
function MK:Init()
    Build()
    -- Questie sets itself up after login: sync a few seconds later, and after each loading screen
    local qf = CreateFrame("Frame")
    qf:RegisterEvent("PLAYER_ENTERING_WORLD")
    qf:SetScript("OnEvent", function(self) self.t = 0 self:Show() end)
    qf:SetScript("OnUpdate", function(self, e)
        self.t = (self.t or 0) + e
        if self.t > 5 then self:Hide(); MK:SyncQuestie() end
    end)
    local ev = CreateFrame("Frame")
    ev:RegisterEvent("WORLD_MAP_UPDATE")
    ev:SetScript("OnEvent", function() MK:Draw() end)
    self:Draw()
end

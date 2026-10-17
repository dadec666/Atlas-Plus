--[[
    Atlas Plus - main window: instance list, map, legend, loot, item search, settings
    Author: Saranwrap
]]

local AP = AtlasPlus
local W = AP.W
local C = W.C

local UI = { listRows = {}, rows = {}, lootCache = {} }
AP.UI = UI
local L = AP.L

local FRAME_W, FRAME_H = 1124, 571        -- 19 px under the content: footer text and resize corner
local LIST_W, MAP_S, RIGHT_W = 175, 512, 395
local TOP = 38                         -- content starts under the title bar
local LIST_ROW_H = 18
local ROW_H, ROWS = 20, 20
local ICON = "Interface\\Icons\\INV_Misc_Map_01"
local LIST_MIN, LIST_MAX = 120, 420
local function ListW() return math.max(LIST_MIN, math.min(LIST_MAX, AP.db.listW or LIST_W)) end

---------------------------------------------------------------------------
-- Loot data
---------------------------------------------------------------------------
-- "45100:4.4:h,47241:100:x2,..." -> { {id=, pct=, ...}, ... }
--   h = hard mode, x2 = two at once, l52-56 = creature levels (world drops),
--   e123 / g500 = sold for a cost / for copper, q123 = quest reward, p / f = emblem of the current / a later phase
local function Parse(str)
    local list = {}
    for entry in str:gmatch("[^,]+") do
        local id, pct, flags = entry:match("^(%d+):([%d%.]+):?(.*)$")
        if id then
            local count, hm, phase, copper, cost, quest, lv
            if flags and flags ~= "" then
                for flag in flags:gmatch("[^:]+") do
                    local x = flag:match("^x(%d+)$")
                    local c = flag:match("^g(%d+)$")
                    local e = flag:match("^e(%d+)$")
                    local q = flag:match("^q(%d+)$")
                    local l = flag:match("^l([%d%-]+)$")
                    if x then count = tonumber(x)
                    elseif flag == "h" then hm = true
                    elseif flag == "p" then phase = "curr"
                    elseif flag == "f" then phase = "future"
                    elseif c then copper = tonumber(c)
                    elseif e then cost = tonumber(e)
                    elseif q then quest = tonumber(q)
                    elseif l then lv = l end
                end
            end
            list[#list + 1] = {
                id = tonumber(id), pct = tonumber(pct), count = count,
                hm = hm, phase = phase, copper = copper, cost = cost, quest = quest, lv = lv,
            }
        end
    end
    return list
end

-- loads a map's loot string on first use and saves the table in lootCache
function UI:GetLoot(key)
    local cached = self.lootCache[key]
    if cached then return cached end
    local raw = AtlasPlus_Loot[key]
    if not raw then return nil end
    local parsed = {}
    for line, str in pairs(raw) do parsed[line] = Parse(str) end
    self.lootCache[key] = parsed
    return parsed
end

local function PctText(pct)
    if not pct then return "" end
    if pct >= 99.5 then return "100%" end
    if pct >= 10 then return string.format("%.0f%%", pct) end
    return string.format("%.1f%%", pct)
end

local function CostText(d)
    if d.cost then
        local c = AtlasPlus_Costs and AtlasPlus_Costs[d.cost]
        if c and c.points then
            local pts = c.points[1]
            if pts then return pts[1] .. " " .. pts[2]:sub(1, 1) end
        end
    end
    if d.copper then
        local g = math.floor(d.copper / 10000)
        local s = math.floor((d.copper % 10000) / 100)
        local c = d.copper % 100
        local t = ""
        if g > 0 then t = t .. g .. "|cffffd100g|r " end
        if s > 0 or g > 0 then t = t .. s .. "|cffe6e6e6s|r " end
        t = t .. c .. "|cffc78240c|r"
        return t
    end
    return ""
end

-- the name of an item from the cache, or queries the server for it
local function ItemInfo(id)
    local name, link, quality, _, _, typ, sub, _, eq, _, _, _, _, _, _, _, _ = GetItemInfo(id)
    local fac = AtlasPlus_Items and AtlasPlus_Items[id]
    if not name then
        GameTooltip:SetHyperlink("item:" .. id)
        GameTooltip:Hide()
        name, link, quality, _, _, typ, sub, _, eq = GetItemInfo(id)
    end
    return name or ("item " .. id), link, quality or 1, typ or "", sub or "", fac, eq
end

local FACTION_TAG = { A = " |cff4a9eff[A]|r", H = " |cffff4a4a[H]|r" }

-- color code removed: "|cff112233Boss|r" -> "Boss"
local function StripColor(s)
    return (s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))
end

local function LineTitle(key, line)
    if line == "trash" then return L["Trash mobs"] end
    local m = AtlasPlus_Maps and AtlasPlus_Maps[key]
    local l = m and m.lines and m.lines[line]
    local t = strtrim(StripColor(l and l[1] or ""))
    t = t:gsub("^%w+'?%)%s*", "")
    return L[t] or t
end

---------------------------------------------------------------------------
-- Main window
---------------------------------------------------------------------------
function UI:Create()
    if self.frame then return end

    local f = CreateFrame("Frame", "AtlasPlusFrame", UIParent)
    self.frame = f
    W.Size(f, FRAME_W, FRAME_H)
    f:SetPoint("CENTER")
    f:SetFrameStrata("HIGH")
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    W.Backdrop(f, C.bg)
    f:Hide()
    tinsert(UISpecialFrames, "AtlasPlusFrame")
    f:SetScript("OnShow", function() UI:OnShow() end)
    f:SetScript("OnHide", function() f:StopMovingOrSizing(); UI:SavePosition(); AP.WorldMap:Detach(); UI.lastHide = GetTime() end)

    -- Title bar (drag to move)
    local title = CreateFrame("Frame", nil, f)
    title:SetPoint("TOPLEFT", 1, -1)
    title:SetPoint("TOPRIGHT", -1, -1)
    title:SetHeight(30)
    W.Backdrop(title, C.panel, C.panel)
    title:EnableMouse(true)
    title:RegisterForDrag("LeftButton")
    title:SetScript("OnMouseDown", function()
        if not AP.db.locked then
            f:StartMoving()
            f.isMoving = true
        end
    end)
    title:SetScript("OnMouseUp", function()
        if f.isMoving then
            f:StopMovingOrSizing()
            f.isMoving = nil
            UI:SavePosition()
        end
    end)

    local icon = title:CreateTexture(nil, "ARTWORK")
    W.Size(icon, 18, 18)
    icon:SetPoint("LEFT", 8, 0)
    icon:SetTexture(ICON)

    local tfs = W.Text(title, "GameFontNormal")
    tfs:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    tfs:SetText("|cffffffffAtlas Plus|r")
    local ver = W.Text(title, "GameFontDisableSmall")
    ver:SetPoint("LEFT", tfs, "RIGHT", 6, -1)
    ver:SetText("v" .. AP.VERSION .. "  -  by Saranwrap, dadec666")

    local close = W.Button(title, "X", 26, 22)
    close:SetPoint("RIGHT", -4, 0)
    close:SetScript("OnClick", function() f:Hide() end)

    local sett = W.Button(title, "O", 26, 22)
    sett:SetPoint("RIGHT", close, "LEFT", -3, 0)
    sett:SetScript("OnClick", function() UI:ShowSettings() end)
    sett:SetScript("OnEnter", function(b) W.Tip(b, L["Settings"]) end)
    sett:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Search box
    local search = W.EditBox(title, 240, 22)
    search:SetPoint("RIGHT", sett, "LEFT", -12, 0)
    search.placeholder:SetText(L["Search an instance, a boss or loot..."])

    -- Tabs: World map / Atlas
    local worldTab = W.Tab(title, L["World map"])
    worldTab:SetPoint("LEFT", ver, "RIGHT", 14, 1)
    worldTab:SetScript("OnClick", function() UI:ShowWorld() end)
    local instTab = W.Tab(title, L["Atlas"])
    instTab:SetPoint("LEFT", worldTab, "RIGHT", 4, 0)
    instTab:SetScript("OnClick", function() UI:OpenInstance(UI.mapKey or AP.db.lastMap) end)
    self.worldTab, self.instTab = worldTab, instTab
    search:SetScript("OnTextChanged", function(eb)
        local t = eb:GetText() or ""
        if t == "" then eb.placeholder:Show(); eb.clear:Hide() else eb.placeholder:Hide(); eb.clear:Show() end
        UI:OnSearchChanged(t)
    end)
    self.searchBox = search

    -- Content (the world map page is taller: its map fills the width)
    self.worldH = AP.WorldView:Create(f, FRAME_W - LIST_W - 30)
    self:CreateList(f)
    self:CreateMap(f)
    self:CreateRight(f)
    AP.WorldView.panel:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -TOP)
    self.worldW = FRAME_W - LIST_W - 10            -- the World map page has no list: the window is narrower

    -- fades to 50% while you move, unless the mouse is over it
    f:SetScript("OnUpdate", function(self, elapsed)
        self.fadeT = (self.fadeT or 0) + elapsed
        if self.fadeT < 0.05 then return end
        self.fadeT = 0
        local base = AP.db.alpha or 1
        local target = base
        if AP.db.fadeMoving and GetUnitSpeed and GetUnitSpeed("player") > 0 and not MouseIsOver(self) then target = base * (AP.db.fadeAlpha or 0.5) end
        local cur = self:GetAlpha()
        if math.abs(cur - target) > 0.01 then self:SetAlpha(cur + (target - cur) * 0.4) else self:SetAlpha(target) end
    end)
    self:CreateGrip(f)

    local foot = W.Text(f, "GameFontDisableSmall")
    foot:SetPoint("BOTTOMLEFT", 12, 5)
    foot:SetPoint("RIGHT", f, "RIGHT", -24, 0)      -- clear of the resize corner
    foot:SetHeight(12)                               -- one line: stays inside the bottom strip
    foot:SetJustifyH("LEFT")
    self.foot = foot

    self:CreateSettings(f)
    self:ApplyLayout()
end

-- position saved as the top left corner in screen units, so it stays put when the size changes
function UI:SavePosition()
    local f = self.frame
    if not (f and f:GetLeft()) then return end
    local s = f:GetEffectiveScale() / UIParent:GetEffectiveScale()
    AP.db.pos = { left = f:GetLeft() * s, top = f:GetTop() * s }
end

function UI:ApplyLayout()
    local f = self.frame
    if not f then return end
    local scale = AP.db.scale or 1
    f:SetScale(scale)
    f:SetAlpha(AP.db.alpha or 1)
    f:ClearAllPoints()
    local p = AP.db.pos
    if p and p.left then
        f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", p.left / scale, p.top / scale)
    else
        f:SetPoint("CENTER")
    end
    if AP.WorldMap then AP.WorldMap:Layout() end
end

-- bottom right corner: drag to resize the window (keeps its shape)
function UI:CreateGrip(f)
    local g = CreateFrame("Button", nil, f)
    W.Size(g, 16, 16)
    g:SetPoint("BOTTOMRIGHT", -2, 2)
    g:SetFrameLevel(f:GetFrameLevel() + 30)
    for i = 0, 2 do
        local d = g:CreateTexture(nil, "OVERLAY")
        d:SetTexture("Interface\\Buttons\\WHITE8X8")
        d:SetVertexColor(0.6, 0.6, 0.6, 0.8)
        W.Size(d, 2, 2)
        d:SetPoint("BOTTOMRIGHT", -(i * 4) - 2, 2)
        local e = g:CreateTexture(nil, "OVERLAY")
        e:SetTexture("Interface\\Buttons\\WHITE8X8")
        e:SetVertexColor(0.6, 0.6, 0.6, 0.8)
        W.Size(e, 2, 2)
        e:SetPoint("BOTTOMRIGHT", -2, (i * 4) + 2)
    end
    g:SetScript("OnEnter", function(self) W.Tip(self, L["Resize"], L["Drag to make the window bigger or smaller."]) end)
    g:SetScript("OnLeave", function() GameTooltip:Hide() end)
    g:SetScript("OnMouseDown", function(self)
        UI:SavePosition()
        local scale = AP.db.scale or 1
        local sx, sy = GetCursorPosition()
        self:SetScript("OnUpdate", function()
            local cx, cy = GetCursorPosition()
            local dx = (cx - sx) / UIParent:GetEffectiveScale()
            local dy = (sy - cy) / UIParent:GetEffectiveScale()
            local d = (dx + dy) / 2
            local curW = f:GetWidth() * scale
            local targetW = math.max(650, math.min(1900, curW + d))
            local newScale = math.max(0.6, math.min(1.5, targetW / f:GetWidth()))
            newScale = math.floor(newScale * 40 + 0.5) / 40
            if newScale ~= scale then
                scale = newScale
                AP.db.scale = scale
                UI:ApplyLayout()
            end
        end)
    end)
    g:SetScript("OnMouseUp", function(self) self:SetScript("OnUpdate", nil); UI:SavePosition() end)
    g:SetScript("OnHide", function(self) self:SetScript("OnUpdate", nil) end)
end

---------------------------------------------------------------------------
-- Left panel: instance list
---------------------------------------------------------------------------
local CAT_SHORT = {
    ["Wrath of the Lich King Dungeons"] = "Wrath Dungeons", ["Wrath of the Lich King Raids"] = "Wrath Raids",
}

function UI:CreateList(f)
    local panel = CreateFrame("Frame", nil, f)
    panel:SetPoint("TOPLEFT", 10, -TOP)
    W.Size(panel, ListW(), MAP_S)
    W.Backdrop(panel, C.panel)
    self.listPanel = panel

    -- the bar between the list and the map: drag it to make the list wider or narrower
    local bar = CreateFrame("Button", nil, f)
    bar:SetPoint("TOPLEFT", panel, "TOPRIGHT", 1, 0)
    bar:SetPoint("BOTTOMLEFT", panel, "BOTTOMRIGHT", 1, 0)
    bar:SetWidth(8)
    bar:SetFrameLevel(panel:GetFrameLevel() + 5)
    local line = bar:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOP", 0, 0); line:SetPoint("BOTTOM", 0, 0); line:SetWidth(1)
    line:SetTexture("Interface\\Buttons\\WHITE8X8")
    line:SetVertexColor(0.25, 0.25, 0.25, 0.8)
    local grip = bar:CreateTexture(nil, "OVERLAY")
    W.Size(grip, 4, 18)
    grip:SetPoint("CENTER", 0, 0)
    grip:SetTexture("Interface\\Buttons\\WHITE8X8")
    grip:SetVertexColor(0.5, 0.5, 0.5, 0.6)
    bar:EnableMouse(true)
    bar:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    bar:SetScript("OnEnter", function(self)
        grip:SetVertexColor(1, 0.82, 0, 0.9)
        W.Tip(self, L["Drag: list wider or narrower"], L["Right-click: back to the first width"])
    end)
    bar:SetScript("OnLeave", function() grip:SetVertexColor(0.5, 0.5, 0.5, 0.6); GameTooltip:Hide() end)
    bar:SetScript("OnClick", function(_, btn) if btn == "RightButton" then UI:SetListWidth(LIST_W) end end)
    bar:SetScript("OnMouseDown", function(self, btn)
        if btn ~= "LeftButton" then return end
        local startX = GetCursorPosition() / UIParent:GetEffectiveScale()
        local startW = panel:GetWidth()
        self:SetScript("OnUpdate", function()
            local curX = GetCursorPosition() / UIParent:GetEffectiveScale()
            local dx = (curX - startX) / (AP.db.scale or 1)
            UI:SetListWidth(startW + dx)
        end)
    end)
    bar:SetScript("OnMouseUp", function(self) self:SetScript("OnUpdate", nil) end)
    bar:SetScript("OnHide", function(self) self:SetScript("OnUpdate", nil) end)
    self.listSplitter = bar

    local sf = CreateFrame("ScrollFrame", "AtlasPlusListScroll", panel, "FauxScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 0, -2)
    sf:SetPoint("BOTTOMRIGHT", -22, 2)
    sf:SetScript("OnVerticalScroll", function(self, off)
        FauxScrollFrame_OnVerticalScroll(self, off, LIST_ROW_H, function() UI:RefreshList() end)
    end)
    self.listScroll = sf

    local rows = math.floor((MAP_S - 4) / LIST_ROW_H)
    for i = 1, rows do
        local r = CreateFrame("Button", nil, panel)
        r:SetHeight(LIST_ROW_H)
        r:SetPoint("TOPLEFT", panel, "TOPLEFT", 2, -2 - ((i - 1) * LIST_ROW_H))
        r:SetPoint("RIGHT", panel, "RIGHT", -22, 0)
        local sel = r:CreateTexture(nil, "BACKGROUND")
        sel:SetAllPoints()
        sel:SetTexture("Interface\\Buttons\\WHITE8X8")
        sel:SetVertexColor(1, 0.82, 0, 0.18)
        sel:Hide()
        r.sel = sel
        local hl = r:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetTexture("Interface\\Buttons\\WHITE8X8")
        hl:SetVertexColor(1, 1, 1, 0.08)
        local fs = W.Text(r, "GameFontHighlightSmall")
        fs:SetPoint("LEFT", 4, 0)
        fs:SetPoint("RIGHT", -4, 0)
        fs:SetJustifyH("LEFT")
        r.fs = fs
        r:SetScript("OnClick", function(self)
            local e = self.entry
            if not e then return end
            if e.cat then
                AP.db.collapsed[e.cat] = not AP.db.collapsed[e.cat]
                UI:RefreshList()
            else
                UI:SelectMap(e.key)
            end
        end)
        r:SetScript("OnEnter", function(r)
            local e = r.entry
            if not (e and e.key) then return end
            local m = AtlasPlus_Maps[e.key]
            GameTooltip:SetOwner(r, "ANCHOR_RIGHT")
            GameTooltip:AddLine(m.full or m.name, 1, 1, 1)
            if m.lvl then GameTooltip:AddLine(string.format(L["Level %s"], m.lvl) .. (m.players and ("  -  " .. string.format(L["%s players"], m.players)) or ""), 0.8, 0.8, 0.8) end
            if m.loc then GameTooltip:AddLine(m.loc, 0.8, 0.8, 0.8) end
            GameTooltip:Show()
        end)
        r:SetScript("OnLeave", function() GameTooltip:Hide() end)
        self.listRows[i] = r
    end
end

-- the list of rows currently shown: categories with their instances indented under them
function UI:ListEntries()
    local out = {}
    local filter = self.listFilter
    if filter and filter ~= "" then
        for _, cat in ipairs(AP.CATEGORIES) do
            local keys = AP.byCategory[cat]
            if keys then
                for _, k in ipairs(keys) do
                    local m = AtlasPlus_Maps[k]
                    if m and (strlower(m.name):find(filter, 1, true) or strlower(m.full or ""):find(filter, 1, true)) then
                        out[#out + 1] = { key = k }
                    end
                end
            end
        end
        return out
    end
    for _, cat in ipairs(AP.CATEGORIES) do
        local keys = AP.byCategory[cat]
        if keys and #keys > 0 then
            out[#out + 1] = { cat = cat }
            if not AP.db.collapsed[cat] then
                for _, k in ipairs(keys) do out[#out + 1] = { key = k } end
            end
        end
    end
    return out
end

-- width of the instance list (the window grows or shrinks with it)
function UI:SetListWidth(w)
    w = math.floor(math.max(LIST_MIN, math.min(LIST_MAX, w)) + 0.5)
    if w == ListW() and self.listPanel:GetWidth() == w then return end
    AP.db.listW = w
    self.listPanel:SetWidth(w)
    if self.page == "instance" then self.frame:SetWidth(FRAME_W + w - LIST_W) end
end

function UI:RefreshList()
    local entries = self:ListEntries()
    self.listEntries = entries
    local visible = self.listVisible
    FauxScrollFrame_Update(self.listScroll, #entries, visible, LIST_ROW_H)
    local off = FauxScrollFrame_GetOffset(self.listScroll)
    for i, row in ipairs(self.listRows) do
        local e = i <= visible and entries[off + i] or nil
        row.entry = e
        if e then
            if e.cat then
                local open = not AP.db.collapsed[e.cat]
                local catTitle = L[CAT_SHORT[e.cat] or e.cat] or CAT_SHORT[e.cat] or e.cat
                row.fs:SetText(AP.ACCENT .. (open and "-  " or "+  ") .. catTitle .. "|r")
                row.fs:SetFontObject("GameFontNormalSmall")
                row.sel:Hide()
            else
                local m = AtlasPlus_Maps[e.key]
                if m then
                    local lvl = m.lvl and ("|cff888888 " .. m.lvl .. "|r") or ""
                    row.fs:SetFontObject("GameFontHighlightSmall")
                    row.fs:SetText("   " .. (L[m.name] or m.name) .. lvl)
                    if e.key == self.mapKey and self.page == "instance" then row.sel:Show() else row.sel:Hide() end
                end
            end
            row:Show()
        else
            row:Hide()
        end
    end
end

---------------------------------------------------------------------------
-- Map: 512x512 tile
---------------------------------------------------------------------------
function UI:CreateMap(f)
    local holder = CreateFrame("Frame", nil, f)
    holder:SetPoint("TOPLEFT", self.listPanel, "TOPRIGHT", 10, 0)
    W.Size(holder, MAP_S, MAP_S)
    W.Backdrop(holder, C.panel)
    self.mapHolder = holder

    local tex = holder:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    self.mapTex = tex
end

---------------------------------------------------------------------------
-- Right panel: header, mode buttons, bosses, loot, item search
---------------------------------------------------------------------------
function UI:CreateRight(f)
    local panel = CreateFrame("Frame", nil, f)
    panel:SetPoint("TOPLEFT", self.mapHolder, "TOPRIGHT", 10, 0)
    panel:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 19)
    W.Backdrop(panel, C.panel)
    self.right = panel

    -- Header (map name, info, location)
    local name = W.Text(panel, "GameFontNormalLarge")
    name:SetPoint("TOPLEFT", 4, -4)
    name:SetPoint("RIGHT", panel, "RIGHT", -4, 0)
    name:SetJustifyH("LEFT")
    self.hName = name

    local info = W.Text(panel, "GameFontHighlightSmall")
    info:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -3)
    info:SetPoint("RIGHT", panel, "RIGHT", -4, 0)
    info:SetJustifyH("LEFT")
    self.hInfo = info

    local loc = W.Text(panel, "GameFontDisableSmall")
    loc:SetPoint("TOPLEFT", info, "BOTTOMLEFT", 0, -2)
    loc:SetPoint("RIGHT", panel, "RIGHT", -190, 0)
    loc:SetJustifyH("LEFT")
    self.hLoc = loc
    local ent = W.Button(panel, L["Entrance"], 90, 18)
    ent:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, -34)
    ent:SetScript("OnClick", function(b) UI:GoEntrance(b) end)
    self.entBtn = ent

    local gameMapBtn = W.Button(panel, L["Game map"], 90, 18)
    gameMapBtn:SetPoint("RIGHT", ent, "LEFT", -4, 0)
    gameMapBtn:SetScript("OnClick", function()
        local mapID = AP:GetGameMapID(UI.mapKey)
        if mapID and AP.WorldMap then
            AP.WorldMap:OpenGameInstanceMap(mapID)
        end
    end)
    gameMapBtn:SetScript("OnEnter", function(b)
        W.Tip(b, L["Game map"], L["Show the interactive game map for this dungeon (supports WDM-patch)."])
    end)
    gameMapBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    self.gameMapBtn = gameMapBtn

    -- Modes: 4 buttons on the right, top: Normal / Heroic / 10H / 25H
    self.modeBtns = {}
    for i = 1, 4 do
        local b = W.Tab(panel, "")
        b:SetHeight(20)
        if i == 1 then b:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, -56)
        else b:SetPoint("RIGHT", self.modeBtns[i - 1], "LEFT", -3, 0) end
        b:SetScript("OnClick", function(btn) UI:SetMode(btn.mode) end)
        self.modeBtns[i] = b
    end
    local back = W.Button(panel, L["< Back"], 64, 20)
    back:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, -56)
    back:SetScript("OnClick", function() UI:Back() end)
    self.backBtn = back

    -- Section title: "Bosses", "Loot: Kurinnaxx", "Search: 12 items"
    local sub = W.Text(panel, "GameFontNormal")
    sub:SetPoint("TOPLEFT", 4, -60)
    sub:SetPoint("RIGHT", panel, "RIGHT", -4, 0)
    sub:SetJustifyH("LEFT")
    self.sub = sub

    local div = panel:CreateTexture(nil, "ARTWORK")
    div:SetPoint("TOPLEFT", 0, -78)
    div:SetPoint("RIGHT", panel, "RIGHT", 0, 0)
    div:SetHeight(1)
    div:SetTexture("Interface\\Buttons\\WHITE8X8")
    div:SetVertexColor(0.2, 0.2, 0.2, 0.8)

    -- Rows: bosses, loot items, search results
    local sf = CreateFrame("ScrollFrame", "AtlasPlusRowScroll", panel, "FauxScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 0, -82)
    sf:SetPoint("BOTTOMRIGHT", -22, 2)
    sf:SetScript("OnVerticalScroll", function(self, off)
        FauxScrollFrame_OnVerticalScroll(self, off, ROW_H, function() UI:RefreshRows() end)
    end)
    self.rowScroll = sf

    for i = 1, ROWS do
        local r = CreateFrame("Button", nil, panel)
        r:SetHeight(ROW_H)
        r:SetPoint("TOPLEFT", panel, "TOPLEFT", 2, -82 - ((i - 1) * ROW_H))
        r:SetPoint("RIGHT", panel, "RIGHT", -22, 0)
        local hl = r:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetTexture("Interface\\Buttons\\WHITE8X8")
        hl:SetVertexColor(1, 1, 1, 0.08)
        r.hl = hl

        local icon = r:CreateTexture(nil, "ARTWORK")
        W.Size(icon, 16, 16)
        icon:SetPoint("LEFT", 4, 0)
        r.icon = icon

        local left = W.Text(r, "GameFontHighlightSmall")
        left:SetPoint("LEFT", icon, "RIGHT", 4, 0)
        left:SetJustifyH("LEFT")
        r.left = left

        local right = W.Text(r, "GameFontDisableSmall")
        right:SetPoint("RIGHT", -4, 0)
        right:SetJustifyH("RIGHT")
        r.right = right

        local mid = W.Text(r, "GameFontDisableSmall")
        mid:SetPoint("RIGHT", right, "LEFT", -6, 0)
        mid:SetJustifyH("RIGHT")
        r.mid = mid

        r:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        r:SetScript("OnClick", function(self, btn) UI:OnRowClick(self, btn) end)
        r:SetScript("OnEnter", function(self) UI:OnRowEnter(self) end)
        r:SetScript("OnLeave", function() GameTooltip:Hide() end)
        self.rows[i] = r
    end
end

---------------------------------------------------------------------------
-- Navigation & display
---------------------------------------------------------------------------
function UI:SetPage(page)
    self.page = page
    local inst = page == "instance"
    self.listVisible = math.floor((MAP_S + 2 - 4) / LIST_ROW_H)
    if inst then
        AP.WorldMap:Detach()
        self.listPanel:Show(); self.mapHolder:Show(); self.right:Show(); AP.WorldView.panel:Hide()
    else
        self.listPanel:Hide(); self.mapHolder:Hide(); self.right:Hide(); AP.WorldView.panel:Show()
        self.foot:SetText("")
        AP.WorldMap:Attach()
    end
    self.worldTab:SetSelected(not inst)
    self.instTab:SetSelected(inst)
    self:RefreshList()
end

function UI:OpenInstance(key)
    if not self.frame:IsShown() then self.opening = true; self.frame:Show(); self.opening = nil end
    self:SetPage("instance")
    self:SelectMap(key)
end

function UI:ShowWorld(keepMap)
    if not self.frame:IsShown() then self.opening = true; self.frame:Show(); self.opening = nil end
    self:SetPage("world")
    if not keepMap then SetMapToCurrentZone() end
end

-- the world map as it was before an instance was opened
function UI:BackToWorld()
    AP.WorldMap.restore = true
    self:ShowWorld(true)
end

function UI:SetMode(mode)
    self.mode = mode
    AP.db.modes[self.mapKey] = mode
    self:RefreshRight()
end

function UI:OpenLoot(line)
    self.view, self.lootLine = "loot", line
    FauxScrollFrame_SetOffset(self.rowScroll, 0)
    self.rowScroll:SetVerticalScroll(0)
    self:RefreshRight()
end

function UI:Back()
    if self.view == "loot" then
        self.view, self.lootLine = "legend", nil
        FauxScrollFrame_SetOffset(self.rowScroll, 0)
        self.rowScroll:SetVerticalScroll(0)
        self:RefreshRight()
    elseif self.view == "search" then
        self.searchBox:SetText("")
        self:OnSearchChanged("")
    end
end

function UI:SelectMap(key, keepView)
    if not key or not AtlasPlus_Maps[key] then return end
    self.mapKey = key
    AP.db.lastMap = key
    local m = AtlasPlus_Maps[key]

    -- Map tile (custom images: Atlas/Images/..., game tiles: original game paths)
    local texPath = m.custom and (AP.MEDIA .. "Images\\" .. m.custom) or ("Interface\\WorldMap\\" .. (m.file or key) .. "\\" .. (m.file or key))
    self.mapTex:SetTexture(texPath)
    if not keepView then self.view, self.lootLine = "legend", nil end

    -- Mode: picks the last one used for this map, or the first available one
    local loot = self:GetLoot(key)
    local avail = {}
    if loot then for mode, _ in pairs(loot) do avail[mode] = true end end
    local mode = AP.db.modes[key]
    if not (mode and avail[mode]) then
        for _, def in ipairs(AP.MODE_ORDER) do if avail[def] then mode = def break end end
    end
    self.mode = mode or "norm"
    self.modesAvailable = avail

    FauxScrollFrame_SetOffset(self.rowScroll, 0)
    self.rowScroll:SetVerticalScroll(0)
    self:RefreshRight()
    self:RefreshList()

    -- bottom bar: total items of this map
    local info = self.foot
    if loot then
        local n, items = 0, 0
        for line, modes in pairs(loot) do
            n = n + 1
            for _, str in pairs(modes) do for _ in str:gmatch("[^,]+") do items = items + 1 end end
        end
        local nLists = AP.FormatLists(n)
        local nItems = AP.FormatItems(items)
        info.count:SetText(nLists .. \", \" .. nItems)
        info:Show()
    else
        info:Hide()
    end
end

-- the Entrance button: links between an instance and its entrance map (Caverns of Time, Blackrock Mountain...)
function UI:GoEntrance(btn)
    local key = self.mapKey
    local A = AtlasPlus_Assoc
    if A.instToEnt[key] then
        self:SelectMap(A.instToEnt[key])
    elseif A.entToInst[key] then
        local insts = A.entToInst[key]
        if #insts == 1 then self:SelectMap(insts[1]) return end
        local menu = {}
        for _, k in ipairs(insts) do
            local m = AtlasPlus_Maps[k]
            if m then menu[#menu + 1] = { text = m.name, notCheckable = true, func = function() UI:SelectMap(k) end } end
        end
        W.Menu(btn, menu)
    end
end

---------------------------------------------------------------------------
-- Right panel content
---------------------------------------------------------------------------
function UI:RefreshHeader()
    local key = self.mapKey
    local m = AtlasPlus_Maps[key]
    self.hName:SetText(L[m.name] or m.name)
    local bits = {}
    if m.lvl then bits[#bits + 1] = string.format(L["Level %s"], m.lvl) end
    if m.minlvl then bits[#bits + 1] = string.format(L["min. %s"], m.minlvl) end
    if m.players then bits[#bits + 1] = string.format(L["%s players"], m.players) end
    if m.nomap then bits[#bits + 1] = "|cff888888" .. (L[m.cat] or m.cat) .. "|r" end
    if m.acr and m.acr ~= "" then bits[#bits + 1] = "|cff888888" .. m.acr .. "|r" end
    self.hInfo:SetText(table.concat(bits, "   "))
    local hub = m.full and m.full:match("^(.-):") or nil
    local locText = m.loc and (L["Location: "] .. (L[m.loc] or m.loc)) or ""
    if hub and hub ~= m.name then locText = (L[hub] or hub) .. (locText ~= "" and ("  -  " .. locText) or "") end
    self.hLoc:SetText(locText)

    local A = AtlasPlus_Assoc
    if A.instToEnt[key] then
        self.entBtn:SetText(L["Entrance map"]); self.entBtn:Show()
    elseif A.entToInst[key] then
        self.entBtn:SetText(L["Instances"]); self.entBtn:Show()
    else
        self.entBtn:Hide()
    end

    if self.gameMapBtn then
        local mapID = AP:GetGameMapID(key)
        if mapID then
            self.gameMapBtn:Show()
        else
            self.gameMapBtn:Hide()
        end
    end
end

function UI:RefreshModes()
    local avail = self.modesAvailable or {}
    local shown = {}
    for _, mode in ipairs(AP.MODE_ORDER) do if avail[mode] then shown[#shown + 1] = mode end end
    for i, b in ipairs(self.modeBtns) do
        local mode = shown[i]
        if mode and self.view ~= "search" and not (self.view == "legend" and #shown <= 1) then
            b:SetText(AP.MODE_LABEL[mode] or mode)
            b.mode = mode
            b:SetSelected(mode == self.mode)
            b:Show()
        else
            b:Hide()
        end
    end
    self.backBtn:SetShown(self.view == "loot")
end

-- the rows of the current view: legend of the map, loot items of a boss, or search results
function UI:GetRows()
    local rows = {}
    local m = AtlasPlus_Maps[self.mapKey]
    if self.view == "loot" then
        local loot = self:GetLoot(self.mapKey)
        local list = loot and loot[self.lootLine] and loot[self.lootLine][self.mode]
        if list then
            for _, d in ipairs(list) do
                if not (AP.db.classFilter and AP.db.myClass and not AP:ItemForClass(d.id, AP.db.myClass)) then
                    rows[#rows + 1] = { kind = "item", id = d.id, pct = d.pct, count = d.count, hm = d.hm, cost = d.cost, copper = d.copper, quest = d.quest, lv = d.lv }
                end
            end
        end
    elseif self.view == "search" then
        return self.results or {}
    else
        local loot = self:GetLoot(self.mapKey)
        local curLoot = loot and loot[self.mode]
        local lines = m.lines or {}
        local col = m.legendColor and W.LEGEND_COLOR[m.legendColor]
        for line, data in ipairs(lines) do
            local hasLoot = curLoot and curLoot[line] ~= nil
            local t = data[1] or ""
            local hex = col and string.format("|cff%02x%02x%02x", col.r * 255, col.g * 255, col.b * 255) or "|cffffffff"
            local letter, rest = t:match("^(%w+'?%)%s*)(.+)$")
            if letter then t = hex .. letter .. "|r" .. rest else t = hex .. t .. "|r" end
            rows[#rows + 1] = { kind = "legend", line = line, text = t, loot = hasLoot, type = data[2], id = data[3] }
        end
        if curLoot and curLoot.trash then
            rows[#rows + 1] = { kind = "legend", line = "trash", text = "|cff888888'|r " .. L["Trash mobs"], loot = true }
        end
    end
    return rows
end

function UI:RefreshRight()
    if not self.mapKey then return end
    self:RefreshHeader()
    self:RefreshModes()
    local m = AtlasPlus_Maps[self.mapKey]
    if self.view == "loot" then
        local t = LineTitle(self.mapKey, self.lootLine)
        self.sub:SetText((L[t] or t) .. (m.nomap and "" or ("  |cff888888" .. (AP.MODE_LABEL[self.mode] or "") .. "|r")))
    elseif self.view == "search" then
        local f = self.found or { places = 0, bosses = 0, items = #(self.results or {}) }
        local parts = {}
        if f.places > 0 then
            parts[#parts + 1] = AP.FormatInstances(f.places)
        end
        if f.bosses > 0 then
            parts[#parts + 1] = AP.FormatBosses(f.bosses)
        end
        parts[#parts + 1] = AP.FormatItems(f.items) .. (self.resultsCapped and L[" (first 200)"] or "")
        self.sub:SetText(table.concat(parts, ", ") .. L[" found"])
    else
        local hasLoot = AtlasPlus_Loot[self.mapKey] ~= nil
        self.sub:SetText(hasLoot and (m.nomap and string.format(L["Click a list (|r%s>|r|cff888888) to see its items|r"], AP.ACCENT) or string.format(L["Click a boss (|r%s>|r|cff888888) to see its loot|r"], AP.ACCENT)) or "")
    end
    self:RefreshRows()
end

function UI:RefreshRows()
    local rows = self:GetRows()
    self.currentRows = rows
    FauxScrollFrame_Update(self.rowScroll, #rows, ROWS, ROW_H)
    local off = FauxScrollFrame_GetOffset(self.rowScroll)
    local w = self.right:GetWidth() - 26
    for i = 1, ROWS do
        local r = self.rows[i]
        local d = rows[off + i]
        r.data = d
        if d then
            r.icon:Hide()
            r.left:ClearAllPoints(); r.left:SetPoint("LEFT", 6, 0)
            r.mid:SetText("")
            if d.kind == "sep" then
                r.left:SetText(AP.ACCENT .. d.text .. "|r")
                r.right:SetText("")
                r.hl:Hide()
            elseif d.kind == "note" then
                r.left:SetText("|cff888888" .. d.text .. "|r")
                r.right:SetText("")
                r.hl:Hide()
            elseif d.kind == "empty" then
                r.left:SetText("|cff888888" .. d.text .. "|r")
                r.right:SetText("")
                r.hl:Show()
            elseif d.kind == "legend" then
                r.left:SetText(d.text or "")
                r.right:SetText(d.loot and (AP.ACCENT .. L["loot >"] .. "|r") or "")
                local clickable = d.loot or (d.type == 1 and d.id and AP.byArea[d.id])
                if clickable then row.hl:Show() else row.hl:Hide() end
            elseif d.kind == "item" then
                local name, _, q, typ, _, fac = ItemInfo(d.id)
                row.icon:SetTexture(GetItemIcon(d.id) or "Interface\\Icons\\INV_Misc_QuestionMark")
                row.left:SetText((d.count and ("|cffffffff" .. d.count .. "x|r ") or "") .. (W.QUALITY_HEX[q] or "") .. name .. "|r" .. (FACTION_TAG[fac or ""] or "") .. (d.hm and " |cffff8040HM|r" or "") or "")
                local mid = AP.FormatItemType and AP.FormatItemType(typ) or (L[typ] or typ)
                if d.lv then mid = mid .. " |cff888888L" .. d.lv .. "|r" end
                row.mid:SetText(mid)
                if d.cost or d.copper then row.right:SetText(CostText(d))
                elseif d.quest then row.right:SetText("|cffffd100" .. L["Quest"] .. "|r")
                else row.right:SetText(PctText(d.pct)) end
                row.hl:Show()
            elseif d.kind == "place" or d.kind == "boss" then
                row.icon:SetTexture(d.kind == "place" and ICON or "Interface\\Icons\\INV_Misc_Bone_HumanSkull_01")
                row.left:SetText(AP.ACCENT .. d.text .. "|r")
                row.mid:SetText(d.where)
                row.right:SetText("")
                row.hl:Show()
            else
                local name, _, q = ItemInfo(d.id)
                row.icon:SetTexture(GetItemIcon(d.id) or "Interface\\Icons\\INV_Misc_QuestionMark")
                row.left:SetText((W.QUALITY_HEX[q] or "") .. name .. "|r")
                row.mid:SetText(d.where)
                row.right:SetText(PctText(d.pct))
                row.hl:Show()
            end
            if d.kind == "item" or d.kind == "place" or d.kind == "boss" then
                row.icon:Show()
                row.left:ClearAllPoints(); row.left:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
            end
            local rw = row.right:GetStringWidth() or 0
            local mw = row.mid:GetStringWidth() or 0
            row.left:SetWidth(math.max(80, w - rw - mw - 30))
            row:Show()
        else
            row:Hide()
        end
    end
end

---------------------------------------------------------------------------
-- Row clicks and tooltips
---------------------------------------------------------------------------
function UI:OnRowClick(row, btn)
    local d = row.data
    if not d then return end
    if d.kind == "legend" then
        if d.loot then
            self:OpenLoot(d.line)
        elseif d.type == 1 and d.id and AP.byArea[d.id] then
            self:SelectMap(AP.byArea[d.id])
        end
    elseif d.kind == "item" then
        local _, link = ItemInfo(d.id)
        if IsModifiedClick("CHATLINK") and link then
            ChatEdit_InsertLink(link)
        elseif IsModifiedClick("DRESSUP") and link then
            DressUpItemLink(link)
        end
    elseif d.kind == "place" then
        self:SelectMap(d.key, true)
    elseif d.kind == "boss" then
        self:SelectMap(d.key, true)
        self:OpenLoot(d.line)
    elseif d.key then
        self:SelectMap(d.key, true)
        if d.line then self:OpenLoot(d.line) end
    end
end

local function CostParts(d)
    local parts = {}
    local rating
    if d.cost then
        local c = AtlasPlus_Costs and AtlasPlus_Costs[d.cost]
        if c then
            rating = c.rating
            if c.points then
                for _, pt in ipairs(c.points) do
                    local n = pt[2] == "Honor" and L["Honor Points"] or (pt[2] == "Arena" and L["Arena Points"] or pt[2])
                    parts[#parts + 1] = { pt[1], n }
                end
            end
            if c.items then
                for _, it in ipairs(c.items) do
                    local name, _, q = ItemInfo(it[2])
                    local icon = GetItemIcon(it[2])
                    local tex = icon and ("|T" .. icon .. ":14:14:0:0|t ") or ""
                    parts[#parts + 1] = { it[1], tex .. (W.QUALITY_HEX[q] or "") .. name .. "|r" }
                end
            end
        end
    end
    if d.copper and d.copper > 0 then
        parts[#parts + 1] = { CostText(d), "" }
    end
    return parts, rating
end

function UI:OnRowEnter(row)
    local d = row.data
    if not d then return end
    if d.kind == "legend" then
        GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
        if d.type == 2 and d.id then
            GameTooltip:SetHyperlink("item:" .. d.id)
        else
            GameTooltip:AddLine(strtrim(StripColor(d.text)), 1, 1, 1)
            if d.loot then GameTooltip:AddLine(L["Click: see its loot"], 0.6, 0.6, 0.6)
            elseif d.type == 1 and d.id and AP.byArea[d.id] then GameTooltip:AddLine(L["Click: open this map"], 0.6, 0.6, 0.6) end
        end
        GameTooltip:Show()
        return
    end
    if d.kind == "sep" or d.kind == "note" then return end
    if not d.id then return end

    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink("item:" .. d.id)

    if self.view == "loot" then
        if d.cost or d.copper then
            local parts, rating = CostParts(d)
            if #parts == 0 then GameTooltip:AddLine(L["Cost: free"], 1, 0.82, 0) end
            for i, p in ipairs(parts) do
                GameTooltip:AddLine((i == 1 and L["Cost: "] or "          ") .. p[1] .. "  " .. p[2], 1, 0.82, 0)
            end
            if rating and rating > 0 then GameTooltip:AddLine(string.format(L["Requires a personal arena rating of %d"], rating), 1, 0.3, 0.3) end
            GameTooltip:AddLine(string.format(L["Sold by: %s"], LineTitle(self.mapKey, self.lootLine)), 0.8, 0.8, 0.8, true)
        elseif d.quest then
            GameTooltip:AddLine(string.format(L["Quest reward: %s"], (AtlasPlus_Quests[d.quest] or (L["Quest"] .. " " .. d.quest))), 1, 0.82, 0, true)
        else
            GameTooltip:AddLine(string.format(L["Drop chance: %s%%"], d.pct) .. (d.count and ("  " .. string.format(L["(%d at once)"], d.count)) or "") .. (d.hm and ("  " .. L["(hard mode)"]) or ""), 1, 0.82, 0)
        end
        if d.lv then
            GameTooltip:AddLine(string.format(L["World drop: creatures of level %s can drop this."], d.lv:gsub("%-", " - ")), 0.8, 0.8, 0.8, true)
        end

    else
        GameTooltip:AddLine(d.where, 1, 1, 1)
        if d.modes and not d.nomap then GameTooltip:AddLine(L["Drops in: "] .. d.modes, 0.8, 0.8, 0.8) end
    end
    local fac = select(6, ItemInfo(d.id))
    if fac == "A" then GameTooltip:AddLine(L["Alliance only"], 0.29, 0.62, 1)
    elseif fac == "H" then GameTooltip:AddLine(L["Horde only"], 1, 0.29, 0.29) end
    GameTooltip:AddLine(L["Shift-click: link   Ctrl-click: try on"], 0.6, 0.6, 0.6)
    GameTooltip:Show()
end

---------------------------------------------------------------------------
-- Item search
---------------------------------------------------------------------------
function UI:OnSearchChanged(text)
    text = strtrim(text or "")
    self.listFilter = text ~= "" and strlower(text) or nil
    self:RefreshList()
    if text:len() < 2 then
        if self.view == "search" then
            self.view = "legend"
            self.results, self.resultsCapped = nil, nil
            self:RefreshRight()
        end
        return
    end
    self:Search(text, true)
end

function UI:BuildSearchIndex()
    if self.searchIndex then return end
    local index = {}
    for mapKey, lines in pairs(AtlasPlus_Loot) do
        for line, modes in pairs(lines) do
            for mode, str in pairs(modes) do
                for entry in str:gmatch("[^,]+") do
                    local id, pct = entry:match("^(%d+):([%d%.]+)")
                    if id then
                        id = tonumber(id)
                        local rec = index[id]
                        if not rec then rec = {}; index[id] = rec end
                        rec[#rec + 1] = { key = mapKey, line = line, mode = mode, pct = tonumber(pct) }
                    end
                end
            end
        end
    end
    self.searchIndex = index
end

function UI:Search(text, fromBox)
    if not fromBox then
        self.searchBox:SetText(text)          -- also fires OnTextChanged in game
        if self.searchText ~= strlower(strtrim(text)) then self:OnSearchChanged(text) end
        return
    end
    if self.page ~= "instance" then
        self:SetPage("instance")
        if not self.mapKey then self:SelectMap(AP.db.lastMap, true) end
    end
    self:BuildSearchIndex()
    local results, groups = {}, {}
    -- instances and bosses first (2 letters are enough: "OS", "EoE", "ICC")
    local places, bosses = {}, {}
    if text:len() >= 2 then
        for key, m in pairs(AtlasPlus_Maps) do
            local acr = strlower(m.acr or "")
            local hit = strlower(m.name or ""):find(text, 1, true) or strlower(m.full or ""):find(text, 1, true)
            for a in acr:gmatch("[^,%s]+") do if a == text or (text:len() >= 3 and a:find(text, 1, true)) then hit = true end end
            if hit then places[#places + 1] = { kind = "place", key = key, text = m.name, where = m.loc or "" } end
            if m.lines then
                local loot = self:GetLoot(key)
                local curLoot = loot and (loot.norm or loot.heroic or loot["10h"] or loot["25h"])
                for line, data in ipairs(m.lines) do
                    local rawName = strtrim(StripColor(data[1] or ""))
                    local cleanName = rawName:gsub("^%w+'?%)%s*", "")
                    if strlower(cleanName):find(text, 1, true) and curLoot and curLoot[line] then
                        bosses[#bosses + 1] = { kind = "boss", key = key, line = line, text = cleanName, where = m.name }
                    end
                end
            end
        end
    end
    table.sort(places, function(a, b) return a.text < b.text end)
    table.sort(bosses, function(a, b) return a.text < b.text end)
    local MAX_ITEMS = 200
    local count = 0
    local capped = false
    for id, entries in pairs(self.searchIndex) do
        local name = GetItemInfo(id)
        if name and strlower(name):find(text, 1, true) then
            count = count + 1
            if count <= MAX_ITEMS then
                local byMap = {}
                for _, e in ipairs(entries) do
                    local k = e.key .. ":" .. tostring(e.line)
                    local g = byMap[k]
                    if not g then g = { key = e.key, line = e.line, modes = {}, bestPct = 0 }; byMap[k] = g; groups[#groups + 1] = { id = id, g = g } end
                    g.modes[e.mode] = true
                    if e.pct and e.pct > g.bestPct then g.bestPct = e.pct end
                end
            else
                capped = true
            end
        end
    end
    table.sort(groups, function(a, b)
        local na = GetItemInfo(a.id) or ""
        local nb = GetItemInfo(b.id) or ""
        if na ~= nb then return na < nb end
        return a.g.bestPct > b.g.bestPct
    end)
    if #places > 0 then
        for _, p in ipairs(places) do results[#results + 1] = p end
    end
    if #bosses > 0 then
        for _, b in ipairs(bosses) do results[#results + 1] = b end
    end
    for _, item in ipairs(groups) do
        local g = item.g
        local m = AtlasPlus_Maps[g.key]
        local modesList = {}
        for _, mode in ipairs(AP.MODE_ORDER) do if g.modes[mode] then modesList[#modesList + 1] = AP.MODE_LABEL[mode] or mode end end
        local where = (m and m.name or g.key)
        if g.line and g.line ~= "trash" and m and m.lines and m.lines[g.line] then
            where = where .. " - " .. LineTitle(g.key, g.line)
        end
        results[#results + 1] = {
            id = item.id, key = g.key, line = g.line, pct = g.bestPct,
            where = where, modes = table.concat(modesList, ", "), nomap = m and m.nomap,
        }
    end
    self.results = results
    self.resultsCapped = capped
    self.found = { places = #places, bosses = #bosses, items = count }
    self.view = "search"
    FauxScrollFrame_SetOffset(self.rowScroll, 0)
    self.rowScroll:SetVerticalScroll(0)
    self:RefreshRight()
end

function UI:OnShow()
    -- the list starts folded every time the window opens
    for _, cat in ipairs(AP.CATEGORIES) do AP.db.collapsed[cat] = true end
    FauxScrollFrame_SetOffset(self.listScroll, 0)
    self.listScroll:SetVerticalScroll(0)
    if self.opening then return end      -- OpenInstance / ShowWorld choose the page
    if AP.db.autoSelect then
        AP:AutoSelect()
        return
    end
    if self.page == "world" then self:SetPage("world") else self:OpenInstance(self.mapKey or AP.db.lastMap) end
end

function UI:Show() self.frame:Show() end
function UI:Toggle() if self.frame:IsShown() then self.frame:Hide() else self.frame:Show() end end

---------------------------------------------------------------------------
-- Settings (replaces the content while open)
---------------------------------------------------------------------------
--- Settings: a window of its own, so the map stays visible while you change things
function UI:CreateSettings(f)
    local win = CreateFrame("Frame", "AtlasPlusSettings", UIParent)
    W.Size(win, FRAME_W - 20, FRAME_H - TOP + 83)
    win:SetFrameStrata("DIALOG")
    win:SetToplevel(true)
    win:SetClampedToScreen(true)
    win:SetMovable(true)
    win:EnableMouse(true)
    W.Backdrop(win, C.bg)
    win:Hide()
    tinsert(UISpecialFrames, "AtlasPlusSettings")
    self.settings = win
    local bar = CreateFrame("Frame", nil, win)
    bar:SetPoint("TOPLEFT", 1, -1)
    bar:SetPoint("TOPRIGHT", -1, -1)
    bar:SetHeight(30)
    W.Backdrop(bar, C.panel, C.panel)
    bar:EnableMouse(true)
    bar:RegisterForDrag("LeftButton")
    bar:SetScript("OnMouseDown", function() win:StartMoving() end)
    bar:SetScript("OnMouseUp", function() win:StopMovingOrSizing() end)
    local icon = bar:CreateTexture(nil, "ARTWORK")
    W.Size(icon, 18, 18)
    icon:SetPoint("LEFT", 8, 0)
    icon:SetTexture(ICON)
    local t = W.Text(bar, "GameFontNormal")
    t:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    t:SetText(L["Settings"])
    local close = W.Button(bar, "X", 26, 22)
    close:SetPoint("RIGHT", -4, 0)
    close:SetScript("OnClick", function() win:Hide() end)

    local g = CreateFrame("Button", nil, win)
    W.Size(g, 16, 16)
    g:SetPoint("BOTTOMRIGHT", -2, 2)
    g:SetFrameLevel(win:GetFrameLevel() + 30)
    for i = 0, 2 do
        local d = g:CreateTexture(nil, "OVERLAY")
        d:SetTexture("Interface\\Buttons\\WHITE8X8"); d:SetVertexColor(0.6, 0.6, 0.6, 0.8)
        W.Size(d, 2, 2); d:SetPoint("BOTTOMRIGHT", -(i * 4) - 2, 2)
        local e = g:CreateTexture(nil, "OVERLAY")
        e:SetTexture("Interface\\Buttons\\WHITE8X8"); e:SetVertexColor(0.6, 0.6, 0.6, 0.8)
        W.Size(e, 2, 2); e:SetPoint("BOTTOMRIGHT", -2, (i * 4) + 2)
    end
    g:SetScript("OnEnter", function(self) W.Tip(self, L["Resize: drag this corner"]) end)
    g:SetScript("OnLeave", function() GameTooltip:Hide() end)
    g:SetScript("OnMouseDown", function(self)
        local scale = AP.db.scale or 1
        local sx, sy = GetCursorPosition()
        self:SetScript("OnUpdate", function()
            local cx, cy = GetCursorPosition()
            local dx = (cx - sx) / UIParent:GetEffectiveScale()
            local dy = (sy - cy) / UIParent:GetEffectiveScale()
            local d = (dx + dy) / 2
            local curW = f:GetWidth() * scale
            local targetW = math.max(650, math.min(1900, curW + d))
            local newScale = math.max(0.6, math.min(1.5, targetW / f:GetWidth()))
            newScale = math.floor(newScale * 40 + 0.5) / 40
            if newScale ~= scale then
                scale = newScale
                AP.db.scale = scale
                UI:ApplyLayout()
            end
        end)
    end)
    g:SetScript("OnMouseUp", function(self) self:SetScript("OnUpdate", nil) end)
    g:SetScript("OnHide", function(self) if self:GetScript("OnUpdate") then self:SetScript("OnUpdate", nil) end end)

    local s = CreateFrame("Frame", nil, win)
    s:SetPoint("TOPLEFT", 0, -30)
    s:SetPoint("BOTTOMRIGHT", 0, 0)

    -- Three columns: 1. Window, 2. World map, 3. Map markers
    local c1 = CreateFrame("Frame", nil, s)
    c1:SetPoint("TOPLEFT", 12, -8); c1:SetPoint("BOTTOMLEFT", 12, 10); c1:SetWidth(350)
    local c2 = CreateFrame("Frame", nil, s)
    c2:SetPoint("TOPLEFT", c1, "TOPRIGHT", 14, 0); c2:SetPoint("BOTTOMLEFT", c1, "BOTTOMRIGHT", 14, 0); c2:SetWidth(350)
    local c3 = CreateFrame("Frame", nil, s)
    c3:SetPoint("TOPLEFT", c2, "TOPRIGHT", 14, 0); c3:SetPoint("BOTTOMLEFT", c2, "BOTTOMRIGHT", 14, 0); c3:SetWidth(350)

    local function Section(parent, title, y)
        local t = W.Text(parent, "GameFontNormalLarge")
        t:SetPoint("TOPLEFT", 4, y)
        t:SetText(title)
        local line = parent:CreateTexture(nil, "ARTWORK")
        line:SetPoint("TOPLEFT", 0, y - 20)
        line:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
        line:SetHeight(1)
        line:SetTexture("Interface\\Buttons\\WHITE8X8")
        line:SetVertexColor(0.25, 0.25, 0.25, 0.8)
        return y - 30
    end

    -----------------------------------------------------------------------
    -- Column 1: Window
    -----------------------------------------------------------------------
    local y = Section(c1, L["Window"], 0)
    local cb1 = W.CheckBox(c1, L["Open on the map of where you are"], AP.db.autoSelect, function(v) AP.db.autoSelect = v end,
                           L["In a dungeon or raid: its map and wing, with the loot of your difficulty. Outdoors: the world map, on your zone."])
    cb1:SetPoint("TOPLEFT", 4, y)
    local cb2 = W.CheckBox(c1, L["Open by itself in dungeons and raids"], AP.db.autoOpen, function(v) AP.db.autoOpen = v end)
    cb2:SetPoint("TOPLEFT", 4, y - 24)
    local cb3 = W.CheckBox(c1, L["Minimap button"], AP.db.minimap, function(v)
        AP.db.minimap = v
        if UI.minimapBtn then UI.minimapBtn:SetShown(v) end
    end)
    cb3:SetPoint("TOPLEFT", 4, y - 48)
    local cb4 = W.CheckBox(c1, L["Lock the window"], AP.db.locked, function(v) AP.db.locked = v end,
                           L["It can't be moved by its title bar."])
    cb4:SetPoint("TOPLEFT", 4, y - 72)
    local cb5 = W.CheckBox(c1, L["Fade while moving"], AP.db.fadeMoving, function(v) AP.db.fadeMoving = v end,
                           L["See-through while you move, unless the mouse is over it."])
    cb5:SetPoint("TOPLEFT", 4, y - 96)

    local slFade = W.Slider(c1, L["Opacity while moving"], 0.2, 0.9, AP.db.fadeAlpha or 0.5, 0.05, function(v) AP.db.fadeAlpha = v end)
    slFade:SetPoint("TOPLEFT", 12, y - 138)
    slFade:SetWidth(320)

    local slScale = W.Slider(c1, L["Window size"], 0.7, 1.4, AP.db.scale or 1, 0.05, function(v)
        AP.db.scale = v
        UI:ApplyLayout()
    end)
    slScale:SetPoint("TOPLEFT", 12, y - 188)
    slScale:SetWidth(320)

    local slAlpha = W.Slider(c1, L["Window opacity"], 0.4, 1.0, AP.db.alpha or 1, 0.05, function(v)
        AP.db.alpha = v
        f:SetAlpha(v)
    end)
    slAlpha:SetPoint("TOPLEFT", 12, y - 238)
    slAlpha:SetWidth(320)

    local help = W.Text(c1, "GameFontDisableSmall")
    help:SetPoint("TOPLEFT", 8, y - 280)
    help:SetPoint("RIGHT", c1, "RIGHT", -8, 0)
    help:SetJustifyH("LEFT")
    help:SetText(L["Move the window: drag its title. Resize it: drag its bottom right corner."])

    -----------------------------------------------------------------------
    -- Column 2: World map
    -----------------------------------------------------------------------
    y = Section(c2, L["World map"], 0)
    local cbM = W.CheckBox(c2, L["The map key (M) opens Atlas Plus"], AP.db.hookWorldMap, function(v) AP.db.hookWorldMap = v end,
                           L["The game's map opens inside Atlas Plus, quests and map addons included. Untick to get the game's map back on M."])
    cbM:SetPoint("TOPLEFT", 4, y)
    local cbInst = W.CheckBox(c2, L["Game instance maps"], AP.db.dungeonMaps, function(v) AP.db.dungeonMaps = v end,
                              L["In a dungeon or raid with a game map (Ulduar, Icecrown Citadel...): open it, on your floor. The Atlas map stays in the Atlas tab."])
    cbInst:SetPoint("TOPLEFT", 4, y - 24)
    local cbFog = W.CheckBox(c2, L["No fog of war"], AP.db.noFog, function(v)
        AP.db.noFog = v
        AP.Fog:Refresh()
    end, L["Show the areas you have not explored yet."])
    cbFog:SetPoint("TOPLEFT", 4, y - 48)
    local cbDark = W.CheckBox(c2, L["Darken unexplored areas"], AP.db.fogDarken, function(v)
        AP.db.fogDarken = v
        AP.Fog:Refresh()
    end, L["So you can still tell them apart."])
    cbDark:SetPoint("TOPLEFT", 4, y - 72)
    local cbZone = W.CheckBox(c2, L["Zone panel (top left of the map)"], AP.db.showZoneInfo, function(v)
        AP.db.showZoneInfo = v
        AP.WorldView:RefreshInfo()
    end, L["Zone info under the cursor"])
    cbZone:SetPoint("TOPLEFT", 4, y - 96)
    local cbCoords = W.CheckBox(c2, L["Coordinates (yours and the cursor's)"], AP.db.showCoords, function(v)
        AP.db.showCoords = v
        AP.WorldView:RefreshCoords()
    end)
    cbCoords:SetPoint("TOPLEFT", 4, y - 120)

    local slQ = W.Slider(c2, L["Quest icon size"], 0.7, 1.4, AP.db.questScale or 1, 0.05, function(v)
        AP.db.questScale = v
        if AP.WorldMap then AP.WorldMap:RescaleQuestIcons() end
    end)
    slQ:SetPoint("TOPLEFT", 12, y - 160)
    slQ:SetWidth(320)

    local slMapAlpha = W.Slider(c2, L["Game map opacity"], 0.3, 1.0, AP.db.mapAlpha or 1, 0.05, function(v)
        AP.db.mapAlpha = v
        if AP.WorldMap and not AP.WorldMap.embedded then WorldMapFrame:SetAlpha(v) end
    end)
    slMapAlpha:SetPoint("TOPLEFT", 12, y - 206)
    slMapAlpha:SetWidth(320)

    local slSmall = W.Slider(c2, L["Game small map size"], 0.6, 1.0, AP.db.smallMapScale or 0.8, 0.05, function(v)
        AP.db.smallMapScale = v
        if AP.WorldMap and not AP.WorldMap.embedded and not GetCVarBool("miniWorldMap") then
            WorldMapFrame:SetScale(v)
        end
    end)
    slSmall:SetPoint("TOPLEFT", 12, y - 252)
    slSmall:SetWidth(320)

    local mapHelp = W.Text(c2, "GameFontDisableSmall")
    mapHelp:SetPoint("TOPLEFT", 8, y - 296)
    mapHelp:SetPoint("RIGHT", c2, "RIGHT", -8, 0)
    mapHelp:SetJustifyH("LEFT")
    mapHelp:SetText(L["These two: the game's map opened on its own (Game map button)."])

    -----------------------------------------------------------------------
    -- Column 3: Map markers
    -----------------------------------------------------------------------
    y = Section(c3, L["Map markers"], 0)
    local function MCheck(label, key, tip)
        local cb = W.CheckBox(c3, label, AP.db.markers[key], function(v)
            AP.db.markers[key] = v
            AP.Markers:Draw()
        end, tip)
        return cb
    end
    local my = y
    local mLabels = {
        dungeon = L["Dungeons (blue)"], raid = L["Raids (green)"], worldboss = L["World bosses"],
        portal = L["Portals"], boat = L["Boats"], zepp = L["Zeppelins"], tram = L["Deeprun Tram"],
        flight = L["Flight masters"], inn = L["Innkeepers"], mail = L["Mailboxes"], bank = L["Banks"], auction = L["Auction houses"],
    }
    for _, t in ipairs(AP.Markers.TYPES) do
        local cb = MCheck(mLabels[t.key] or t.label, t.key)
        cb:SetPoint("TOPLEFT", 4, my)
        my = my - 22
    end
    local cbCont = W.CheckBox(c3, L["Markers on continent maps"], AP.db.continentMarkers, function(v)
        AP.db.continentMarkers = v
        AP.Markers:Draw()
    end, L["Not the town ones (flight masters, inns...)."])
    cbCont:SetPoint("TOPLEFT", 4, my)
    my = my - 22
    local cbQ = W.CheckBox(c3, L["Hide Questie's dungeon and raid icons"], AP.db.hideQuestiePins, function(v)
        AP.db.hideQuestiePins = v
        AP.Markers:SyncQuestie()
    end, L["While the Atlas Plus ones are on. They come back when you turn these off."])
    cbQ:SetPoint("TOPLEFT", 4, my)
    my = my - 22
    local cbFac = W.CheckBox(c3, L["Only my faction's"], AP.db.myFactionOnly, function(v)
        AP.db.myFactionOnly = v
        AP.Markers:Draw()
    end, L["Transports, portals and town markers. Neutral ones always show."])
    cbFac:SetPoint("TOPLEFT", 4, my)
    my = my - 24

    local slScale = W.Slider(c3, L["Marker size"], 0.7, 1.4, AP.db.markerScale or 1, 0.05, function(v)
        AP.db.markerScale = v
        AP.Markers:Draw()
    end)
    slScale:SetPoint("TOPLEFT", 12, my - 14)
    slScale:SetWidth(320)

    local slTown = W.Slider(c3, L["Town marker size"], 0.7, 1.4, AP.db.townScale or 1, 0.05, function(v)
        AP.db.townScale = v
        AP.Markers:Draw()
    end)
    slTown:SetPoint("TOPLEFT", 12, my - 60)
    slTown:SetWidth(320)

    -- Credits at the bottom across the columns
    local credits = W.Text(s, "GameFontDisableSmall")
    credits:SetPoint("BOTTOMLEFT", 16, 12)
    credits:SetPoint("BOTTOMRIGHT", -16, 12)
    credits:SetJustifyH("CENTER")
    credits:SetText(string.format(L["Atlas Plus %s (Circle Edition) by Saranwrap & dadec666. Instance maps and legends from Atlas (GPL v2). Zone levels from LibTourist-3.0 (MIT). Database aligned with wowroad.info.\n/ap - open / close     /ap here - map of where you are     /ap world - world map     /ap search <item>     /ap reset - window position and size"], AP.VERSION))
end

function UI:ShowSettings()
    if not self.settings then self:CreateSettings(self.frame) end
    self.settings:Show()
end

---------------------------------------------------------------------------
-- Interface Options panel (ESC -> Interface -> AddOns -> Atlas Plus)
---------------------------------------------------------------------------
function UI:CreateInterfacePanel()
    local panel = CreateFrame("Frame", "AtlasPlusInterfaceOptions", UIParent)
    panel.name = "Atlas Plus"

    local title = W.Text(panel, "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Atlas Plus |cfffc7a2b[Circle Edition]|r  v" .. AP.VERSION)

    local desc = W.Text(panel, "GameFontHighlight")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    desc:SetPoint("RIGHT", panel, "RIGHT", -16, 0)
    desc:SetJustifyH("LEFT")
    desc:SetText(L["Instance maps with every boss and its loot, item search, and world map zone info.\n\n/ap - open / close     /ap here - map of where you are     /ap settings"])

    local btn = W.Button(panel, L["Open Atlas Plus"], 140, 26)
    btn:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -16)
    btn:SetScript("OnClick", function()
        InterfaceOptionsFrame_Show()          -- closes the options
        UI:Toggle()
    end)

    local btnSett = W.Button(panel, L["Settings"], 140, 26)
    btnSett:SetPoint("LEFT", btn, "RIGHT", 10, 0)
    btnSett:SetScript("OnClick", function()
        InterfaceOptionsFrame_Show()
        UI:ShowSettings()
    end)

    InterfaceOptions_AddCategory(panel)
end

---------------------------------------------------------------------------
-- Minimap button
---------------------------------------------------------------------------
function UI:CreateMinimapButton()
    local b = CreateFrame("Button", "AtlasPlusMinimapButton", Minimap)
    self.minimapBtn = b
    W.Size(b, 31, 31)
    b:SetFrameStrata("MEDIUM")
    b:SetFrameLevel(8)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:RegisterForDrag("LeftButton")
    b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local icon = b:CreateTexture(nil, "BACKGROUND")
    W.Size(icon, 20, 20)
    icon:SetPoint("CENTER", 0, 0)
    icon:SetTexture(ICON)
    local border = b:CreateTexture(nil, "OVERLAY")
    W.Size(border, 52, 52)
    border:SetPoint("TOPLEFT", 0, 0)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    local function UpdatePos()
        local rad = math.rad(AP.db.minimapPos or 220)
        local cos, sin = math.cos(rad), math.sin(rad)
        local cx, cy = Minimap:GetWidth() / 2, Minimap:GetHeight() / 2
        local r = cx + 10                                       -- slightly outside the rim
        b:ClearAllPoints()
        b:SetPoint("CENTER", Minimap, "CENTER", cos * r, sin * r)
    end
    UpdatePos()

    b:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local cx, cy = GetCursorPosition()
            local s = Minimap:GetEffectiveScale()
            cx, cy = cx / s, cy / s
            local deg = math.deg(math.atan2(cy - my, cx - mx))
            if deg < 0 then deg = deg + 360 end
            AP.db.minimapPos = deg
            UpdatePos()
        end)
    end)
    b:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
    b:SetScript("OnClick", function(_, btn)
        if btn == "RightButton" then UI:ShowSettings() else UI:Toggle() end
    end)
    b:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Atlas Plus")
        GameTooltip:AddLine(L["Left-click: open / close"], 0.8, 0.8, 0.8)
        GameTooltip:AddLine(L["Right-click: settings"], 0.8, 0.8, 0.8)
        GameTooltip:AddLine(L["Drag: move"], 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    b:SetShown(AP.db.minimap)
end

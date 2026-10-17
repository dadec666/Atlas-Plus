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
--   e123 / g500 = sold for a cost / for copper, q123 = quest reward
local function Parse(str)
    local list = {}
    for entry in (str or ""):gmatch("[^,]+") do
        local id, pct, rest = entry:match("^(%d+):([%d%.e%-]+)(.*)$")
        if id then
            local r = { id = tonumber(id), pct = tonumber(pct) or 0 }
            for f in rest:gmatch("[^:]+") do
                local c, v = f:sub(1, 1), f:sub(2)
                if c == "h" then r.hm = true
                elseif c == "x" then r.count = tonumber(v)
                elseif c == "l" then r.lv = v
                elseif c == "e" then r.cost = tonumber(v)
                elseif c == "g" then r.copper = tonumber(v)
                elseif c == "q" then r.quest = tonumber(v) end
            end
            list[#list + 1] = r
        end
    end
    return list
end

-- prices: "12 [icon] 2 [icon]", copper as gold / silver / copper
local function Coins(c)
    local g, s, cp = math.floor(c / 10000), math.floor(c / 100) % 100, c % 100
    local out = {}
    if g > 0 then out[#out + 1] = g .. "|TInterface\\MoneyFrame\\UI-GoldIcon:0|t" end
    if s > 0 then out[#out + 1] = s .. "|TInterface\\MoneyFrame\\UI-SilverIcon:0|t" end
    if cp > 0 or #out == 0 then out[#out + 1] = cp .. "|TInterface\\MoneyFrame\\UI-CopperIcon:0|t" end
    return table.concat(out, " ")
end
local function CostParts(d)
    local parts = {}
    if d.copper then
        if d.copper > 0 then parts[1] = { Coins(d.copper), "Gold" } end
        return parts
    end
    local c = d.cost and AtlasPlus_Costs[d.cost]
    if not c then return parts end
    if c[1] > 0 then
        local fac = UnitFactionGroup("player") or "Alliance"
        parts[#parts + 1] = { c[1] .. "|TInterface\\PVPFrame\\PVP-Currency-" .. fac .. ":0|t", "Honor Points" }
    end
    if c[2] > 0 then parts[#parts + 1] = { c[2] .. "|TInterface\\PVPFrame\\PVP-ArenaPoints-Icon:0|t", "Arena Points" } end
    for i = 4, #c, 2 do
        local name = AtlasPlus_Items[c[i]] and AtlasPlus_Items[c[i]][1] or GetItemInfo(c[i]) or ("item " .. c[i])
        parts[#parts + 1] = { c[i + 1] .. "|T" .. (GetItemIcon(c[i]) or "Interface\\Icons\\INV_Misc_QuestionMark") .. ":0|t", name, c[i + 1] }
    end
    return parts, c[3]
end
local function CostText(d)
    local out = {}
    for _, p in ipairs((CostParts(d))) do out[#out + 1] = p[1] end
    return #out > 0 and table.concat(out, " ") or "|cff888888free|r"
end
AP.CostText = CostText

function UI:GetLoot(key, line, mode)
    local ck = key .. ":" .. tostring(line) .. ":" .. tostring(mode)
    if self.lootCache[ck] then return self.lootCache[ck] end
    local m = AtlasPlus_Maps[key]
    local str
    if line == "trash" then
        local t = m and m.mapID and AtlasPlus_Trash[m.mapID]
        str = t and t[mode]
    else
        local l = AtlasPlus_Loot[key]
        str = l and l[line] and l[line][mode]
    end
    local list = Parse(str)
    self.lootCache[ck] = list
    return list
end

-- Item info: GetItemInfo, cached, falls back to the database name
local itemCache = {}
local function ItemInfo(id)
    local c = itemCache[id]
    if c then return unpack(c) end
    local name, link, quality, _, _, itemType, itemSubType, _, equipLoc, icon = GetItemInfo(id)
    local d = AtlasPlus_Items[id]
    if not name and d then name, quality = d[1], d[2] end
    name = name or ("Item " .. id)
    local typ = equipLoc and _G[equipLoc]
    if not typ or typ == "" then typ = itemSubType or itemType or "" end
    if not typ or typ == "" then typ = d and d[3] or "" end
    local fac = d and d[5]
    local res = { name, icon, quality or 1, typ, link, fac }
    itemCache[id] = res
    return unpack(res)
end

local function LineTitle(key, line)
    if line == "trash" then return L["Trash mobs"] end
    local m = AtlasPlus_Maps[key]
    local entry = m and m.lines and m.lines[line]
    local text = type(entry) == "table" and entry[1] or entry or ""
    return (text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("^%s*[%w%']+%)%s*", ""):gsub("^%s+", ""))
end

---------------------------------------------------------------------------
-- Build UI
---------------------------------------------------------------------------
function UI:Create()
    local f = CreateFrame("Frame", "AtlasPlusFrame", UIParent)
    W.Size(f, FRAME_W, FRAME_H)
    f:SetPoint("CENTER")
    f:SetFrameStrata("HIGH")
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:SetResizable(true)
    f:EnableMouse(true)
    W.Backdrop(f, C.bg)
    f:Hide()
    tinsert(UISpecialFrames, "AtlasPlusFrame")
    self.frame = f

    -- title bar: drag to move, double-click to centre
    local title = CreateFrame("Button", nil, f)
    title:SetPoint("TOPLEFT", 1, -1)
    title:SetPoint("TOPRIGHT", -1, -1)
    title:SetHeight(TOP)
    title:EnableMouse(true)
    title:RegisterForDrag("LeftButton")
    title:RegisterForClicks("LeftButtonUp")
    title:SetScript("OnDragStart", function() if not AP.db.locked then f:StartMoving() end end)
    title:SetScript("OnDragStop", function() f:StopMovingOrSizing(); UI:SavePosition() end)
    title:SetScript("OnClick", function()
        local now = GetTime()
        if title.lastClick and now - title.lastClick < 0.3 then
            f:ClearAllPoints()
            f:SetPoint("CENTER")
            UI:SavePosition()
        end
        title.lastClick = now
    end)
    self.titleBar = title

    local name = W.Text(title, "GameFontNormal")
    name:SetPoint("LEFT", 10, 1)
    name:SetText(AP.ACCENT .. "Atlas Plus|r")

    local ver = W.Text(title, "GameFontDisableSmall")
    ver:SetPoint("LEFT", name, "RIGHT", 6, 0)
    ver:SetText("v" .. AP.VERSION)

    local close = W.Button(title, "X", 22, 22)
    close:SetPoint("RIGHT", -8, 0)
    close:SetScript("OnClick", function() UI:Hide() end)

    local settings = W.Button(title, L["Settings"], 80, 22)
    settings:SetPoint("RIGHT", close, "LEFT", -4, 0)
    settings:SetScript("OnClick", function() UI:ToggleSettings() end)
    self.settingsBtn = settings

    local search = W.EditBox(title, 230, 22, L["Search an instance, a boss or loot..."])
    search:SetPoint("RIGHT", settings, "LEFT", -10, 0)

    -- pages
    local worldTab = W.Button(title, L["World map"], 84, 22)
    worldTab:SetPoint("LEFT", ver, "RIGHT", 18, 1)
    worldTab:SetScript("OnClick", function() UI:BackToWorld() end)
    local instTab = W.Button(title, L["Atlas"], 84, 22)
    instTab:SetPoint("LEFT", worldTab, "RIGHT", 4, 0)
    instTab:SetScript("OnClick", function() UI:OpenInstance(UI.mapKey or AP.db.lastMap) end)
    self.worldTab, self.instTab = worldTab, instTab

    search:SetScript("OnTextChanged", function(eb)
        local text = strtrim(eb:GetText() or "")
        if text == "" then eb.placeholder:Show(); eb.clear:Hide() else eb.placeholder:Hide(); eb.clear:Show() end
        if text == UI.searchText then return end
        UI.searchText = text
        if text == "" then
            if UI.view == "search" then UI.view = "legend"; UI:RefreshModes(); UI:RefreshRight() end
        else
            UI:DoSearch(text)
        end
    end)
    self.searchBox = search

    -- resize corner
    local sizer = CreateFrame("Button", nil, f)
    W.Size(sizer, 16, 16)
    sizer:SetPoint("BOTTOMRIGHT", -2, 2)
    sizer:EnableMouse(true)
    sizer:RegisterForDrag("LeftButton")
    local stex = sizer:CreateTexture(nil, "OVERLAY")
    stex:SetAllPoints()
    stex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    sizer:SetScript("OnEnter", function() stex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight") end)
    sizer:SetScript("OnLeave", function() stex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up") end)
    sizer:SetScript("OnDragStart", function() f:StartSizing("BOTTOMRIGHT") end)
    sizer:SetScript("OnDragStop", function()
        f:StopMovingOrSizing()
        UI:OnResize()
    end)
    self.sizer = sizer

    -- panels
    self.worldW, self.worldH = FRAME_W, FRAME_H - TOP - 19
    self:CreateList(f)
    self:CreateMap(f)
    self:CreateRight(f)
    AP.WorldView:Create(f, TOP, FRAME_W - 20, self.worldH)

    -- footer
    local foot = W.Text(f, "GameFontDisableSmall")
    foot:SetPoint("BOTTOMLEFT", 12, 5)
    foot:SetPoint("BOTTOMRIGHT", -24, 5)
    foot:SetJustifyH("LEFT")
    self.foot = foot

    self:CreateSettings(f)
    self:ApplyLayout()

    -- fade while moving: mouse over the window brings full opacity back
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
end

function UI:SavePosition()
    local f = self.frame
    if not (f and f:GetLeft()) then return end
    local s = f:GetEffectiveScale() / UIParent:GetEffectiveScale()
    AP.db.pos = { left = f:GetLeft() * s, top = f:GetTop() * s }
end

function UI:ApplyLayout()
    local f = self.frame
    if not f then return end
    f:SetScale(AP.db.scale or 1)
    f:SetAlpha(AP.db.alpha or 1)
    if AP.db.pos then
        local s = UIParent:GetEffectiveScale() / f:GetEffectiveScale()
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", AP.db.pos.left * s, AP.db.pos.top * s)
    end
end

function UI:OnResize()
    local f = self.frame
    local w, h = f:GetWidth(), f:GetHeight()
    w = math.max(FRAME_W - 200, math.min(1900, w))
    h = math.max(FRAME_H - 150, math.min(1200, h))
    f:SetWidth(w); f:SetHeight(h)
    self.worldW, self.worldH = w, h - TOP - 19
    AP.WorldView:SetSize(w - 20, self.worldH)
    if self.page == "world" then
        self.listPanel:SetHeight(self.worldH)
        self.listVisible = math.floor((self.worldH - 4) / LIST_ROW_H)
        self:RefreshList()
        if AP.WorldMap then AP.WorldMap:Layout() end
    end
end

---------------------------------------------------------------------------
-- Left panel: instances by expansion
---------------------------------------------------------------------------
local CAT_SHORT = {
    ["Classic Dungeons"] = "Classic", ["Classic Raids"] = "Classic (R)",
    ["Burning Crusade Dungeons"] = "TBC", ["Burning Crusade Raids"] = "TBC (R)",
    ["Wrath of the Lich King Dungeons"] = "WotLK", ["Wrath of the Lich King Raids"] = "WotLK (R)",
    ["World Drops"] = "Drops", ["World Events"] = "Events", ["Vendors"] = "Vendors",
    ["Entrances"] = "Entr.", ["Dungeon Locations"] = "Loc.",
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
    line:SetTexture("Interface\\Buttons\\WHITE8X8")
    line:SetVertexColor(C.line[1], C.line[2], C.line[3], 0.6)
    line:SetWidth(2)
    line:SetPoint("TOP", 0, -4)
    line:SetPoint("BOTTOM", 0, 4)
    local dots = {}
    for i = -1, 1 do
        local d = bar:CreateTexture(nil, "OVERLAY")
        d:SetTexture("Interface\\Buttons\\WHITE8X8")
        d:SetVertexColor(C.line[1], C.line[2], C.line[3], 1)
        W.Size(d, 4, 4)
        d:SetPoint("CENTER", 0, i * 8)
        dots[#dots + 1] = d
    end
    local function Paint(on)
        local c = on and C.accent or C.line
        line:SetVertexColor(c[1], c[2], c[3], on and 1 or 0.6)
        for _, d in ipairs(dots) do d:SetVertexColor(c[1], c[2], c[3], 1) end
    end
    bar:SetScript("OnEnter", function(b)
        Paint(true)
        GameTooltip:SetOwner(b, "ANCHOR_RIGHT")
        GameTooltip:AddLine(L["Drag: list wider or narrower"], 1, 1, 1)
        GameTooltip:AddLine(L["Right-click: back to the first width"], 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    bar:SetScript("OnLeave", function(b) if not b.dragging then Paint(false) end GameTooltip:Hide() end)
    bar:RegisterForClicks("RightButtonUp")
    bar:SetScript("OnClick", function() UI:SetListWidth(LIST_W) end)
    bar:SetScript("OnMouseDown", function(b, button)
        if button ~= "LeftButton" then return end
        b.dragging = true
        b.x0, b.w0 = GetCursorPosition(), ListW()
        b.sc = b:GetEffectiveScale()
        b:SetScript("OnUpdate", function(s)
            local x = GetCursorPosition()
            UI:SetListWidth(s.w0 + (x - s.x0) / s.sc)
        end)
    end)
    local function StopDrag(b)
        if not b.dragging then return end
        b.dragging = nil
        b:SetScript("OnUpdate", nil)
        if not b:IsMouseOver() then Paint(false) end
    end
    bar:SetScript("OnMouseUp", StopDrag)
    bar:SetScript("OnHide", StopDrag)
    self.listBar = bar

    local maxRows = math.floor((math.max(self.worldH, MAP_S + 2) - 4) / LIST_ROW_H)
    self.listVisible = math.floor((MAP_S + 2 - 4) / LIST_ROW_H)
    for i = 1, maxRows do
        local r = CreateFrame("Button", nil, panel)
        r:SetHeight(LIST_ROW_H)
        r:SetPoint("TOPLEFT", 2, -2 - (i - 1) * LIST_ROW_H)
        r:SetPoint("RIGHT", panel, "RIGHT", -18, 0)
        local hl = r:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetTexture(C.accent[1], C.accent[2], C.accent[3], 0.15)
        local fs = W.Text(r)
        fs:SetPoint("LEFT", 6, 0)
        fs:SetPoint("RIGHT", -4, 0)
        fs:SetJustifyH("LEFT")
        r:SetFontString(fs)
        r:SetScript("OnClick", function(self)
            local d = self.data
            if not d then return end
            if d.kind == "cat" then
                AP.db.collapsed[d.cat] = not AP.db.collapsed[d.cat]
                UI:RefreshList()
            else
                UI:SelectMap(d.key)
            end
        end)
        self.listRows[i] = r
    end

    local sf = CreateFrame("ScrollFrame", "AtlasPlusListScroll", panel, "FauxScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 2, -2)
    sf:SetPoint("BOTTOMRIGHT", -2, 2)
    sf:SetScript("OnVerticalScroll", function(s, offset)
        FauxScrollFrame_OnVerticalScroll(s, offset, LIST_ROW_H, function() UI:RefreshList() end)
    end)
    W.FlatScroll(sf)
    self.listScroll = sf
end

function UI:ListEntries()
    local out = {}
    for _, cat in ipairs(AP.CATEGORIES) do
        local open = not AP.db.collapsed[cat]
        out[#out + 1] = { kind = "cat", cat = cat, text = (open and "- " or "+ ") .. (L[cat] or cat) }
        if open then
            for _, key in ipairs(AP.byCategory[cat] or {}) do
                local m = AtlasPlus_Maps[key]
                out[#out + 1] = { kind = "map", key = key, text = "   " .. (m.name or key) }
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
    local count = #entries
    local visible = self.listVisible or 28
    FauxScrollFrame_Update(self.listScroll, count, visible, LIST_ROW_H)
    local off = FauxScrollFrame_GetOffset(self.listScroll)
    for i, r in ipairs(self.listRows) do
        if i <= visible then
            local idx = off + i
            local d = entries[idx]
            r.data = d
            if d then
                local fs = r:GetFontString()
                if d.kind == "cat" then
                    fs:SetFontObject("GameFontNormalSmall")
                    fs:SetTextColor(C.accent[1], C.accent[2], C.accent[3])
                else
                    fs:SetFontObject("GameFontHighlightSmall")
                    local sel = (d.key == self.mapKey)
                    fs:SetTextColor(sel and C.accent[1] or 0.9, sel and C.accent[2] or 0.9, sel and C.accent[3] or 0.9)
                end
                r:SetText(d.text)
                r:Show()
            else
                r:Hide()
            end
        else
            r:Hide()
        end
    end
end

function UI:RevealInList(key)
    local m = AtlasPlus_Maps[key]
    if m and AP.db.collapsed[m.cat] then
        AP.db.collapsed[m.cat] = false
        self:RefreshList()
    end
    local entries = self.listEntries or self:ListEntries()
    local idx
    for i, e in ipairs(entries) do if e.key == key then idx = i break end end
    if not idx then return end
    local visible = self.listVisible or 28
    local off = FauxScrollFrame_GetOffset(self.listScroll)
    if idx <= off or idx > off + visible then
        local newOff = math.max(0, math.min(#entries - visible, idx - math.floor(visible / 2)))
        FauxScrollFrame_SetOffset(self.listScroll, newOff)
        self.listScroll:SetVerticalScroll(newOff * LIST_ROW_H)
    end
    self:RefreshList()
end

---------------------------------------------------------------------------
-- Middle: instance map
---------------------------------------------------------------------------
function UI:CreateMap(f)
    local holder = CreateFrame("Frame", nil, f)
    holder:SetPoint("TOPLEFT", self.listPanel, "TOPRIGHT", 10, 0)
    W.Size(holder, MAP_S, MAP_S)
    W.Backdrop(holder, C.panel)

    local tex = holder:CreateTexture(nil, "ARTWORK")
    tex:SetPoint("CENTER")
    W.Size(tex, MAP_S, MAP_S)
    self.mapTex = tex
    self.mapHolder = holder

    -- pages without a map (world drops, events, vendors): what the page is about
    local info = CreateFrame("Frame", nil, holder)
    info:SetAllPoints()
    local big = info:CreateTexture(nil, "ARTWORK")
    W.Size(big, 64, 64)
    big:SetPoint("TOP", 0, -120)
    big:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    local title = W.Text(info, "GameFontNormalLarge")
    title:SetPoint("TOP", big, "BOTTOM", 0, -14)
    title:SetWidth(MAP_S - 60)
    local body = W.Text(info, "GameFontHighlight")
    body:SetPoint("TOP", title, "BOTTOM", 0, -12)
    body:SetWidth(MAP_S - 80)
    body:SetSpacing(3)
    local count = W.Text(info, "GameFontDisable")
    count:SetPoint("TOP", body, "BOTTOM", 0, -14)
    count:SetWidth(MAP_S - 80)
    info.icon, info.title, info.body, info.count = big, title, body, count
    info:Hide()
    self.mapInfo = info

    -- right-click on the instance map: back to the world map
    holder:EnableMouse(true)
    holder:SetScript("OnMouseUp", function(_, button) if button == "RightButton" then UI:BackToWorld() end end)
    holder:SetScript("OnEnter", function()
        if UI.page == "instance" and not (AtlasPlus_Maps[UI.mapKey] and AtlasPlus_Maps[UI.mapKey].nomap) then
            SetCursor("Interface\\Cursor\\Crosshairs")
        end
    end)
    holder:SetScript("OnLeave", function() ResetCursor() end)
end

---------------------------------------------------------------------------
-- Right panel: legend / loot list
---------------------------------------------------------------------------
local function CreateRow(parent, i)
    local r = CreateFrame("Button", nil, parent)
    r:SetHeight(ROW_H)
    r:SetPoint("TOPLEFT", 2, -2 - (i - 1) * ROW_H)
    r:SetPoint("RIGHT", parent, "RIGHT", -18, 0)
    local hl = r:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetTexture(C.accent[1], C.accent[2], C.accent[3], 0.15)
    local icon = r:CreateTexture(nil, "ARTWORK")
    W.Size(icon, 16, 16)
    icon:SetPoint("LEFT", 6, 0)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    local left = W.Text(r, "GameFontHighlightSmall")
    left:SetJustifyH("LEFT")
    local mid = W.Text(r, "GameFontDisableSmall")
    mid:SetJustifyH("LEFT")
    local right = W.Text(r, "GameFontHighlightSmall")
    right:SetJustifyH("RIGHT")
    right:SetPoint("RIGHT", -6, 0)
    r.icon, r.left, r.mid, r.right, r.hl = icon, left, mid, right, hl
    r:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    r:SetScript("OnClick", function(self, button) UI:OnRowClick(self, button) end)
    r:SetScript("OnEnter", function(self) UI:OnRowEnter(self) end)
    r:SetScript("OnLeave", function(self) UI:OnRowLeave(self) end)
    return r
end

-- layout of one row: "legend" (text only), "item" (icon, name, type, chance), "result" (icon, name, where)
local function LayoutRow(row, kind, width, rightW)
    row.left:ClearAllPoints(); row.mid:ClearAllPoints()
    if kind == "legend" or kind == "group" then
        row.icon:Hide()
        row.left:SetPoint("LEFT", 6, 0)
        row.left:SetWidth(width - 60)
        row.mid:Hide()
        row.right:SetWidth(50)
    elseif kind == "item" then
        rightW = rightW or 44
        row.icon:Show()
        row.left:SetPoint("LEFT", 27, 0)
        local nameW = math.floor((width - 27 - rightW - 2) * 0.58)
        row.left:SetWidth(nameW)
        row.mid:Show()
        row.mid:SetPoint("LEFT", 27 + nameW + 6, 0)
        row.mid:SetWidth(width - 27 - nameW - 6 - rightW - 6)
        row.right:SetWidth(rightW)
    else -- result
        row.icon:Show()
        row.left:SetPoint("LEFT", 27, 0)
        local nameW = math.floor((width - 27 - 10) * 0.55)
        row.left:SetWidth(nameW)
        row.mid:Show()
        row.mid:SetPoint("LEFT", 27 + nameW + 6, 0)
        row.mid:SetWidth(width - 27 - nameW - 12)
        row.right:SetWidth(1)
        row.right:SetText("")
    end
end

function UI:CreateRight(f)
    local panel = CreateFrame("Frame", nil, f)
    panel:SetPoint("TOPLEFT", self.mapHolder, "TOPRIGHT", 10, 0)
    panel:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 24)
    W.Backdrop(panel, C.panel)
    self.rightPanel = panel

    -- header: instance name, zone, level, player count
    local head = CreateFrame("Frame", nil, panel)
    head:SetPoint("TOPLEFT", 1, -1)
    head:SetPoint("TOPRIGHT", -1, -1)
    head:SetHeight(48)
    W.Backdrop(head, C.header)
    self.rHead = head

    local hTitle = W.Text(head, "GameFontNormal")
    hTitle:SetPoint("TOPLEFT", 8, -6)
    hTitle:SetPoint("RIGHT", head, "RIGHT", -110, 0)
    hTitle:SetJustifyH("LEFT")
    self.hTitle = hTitle

    local hInfo = W.Text(head, "GameFontDisableSmall")
    hInfo:SetPoint("TOPLEFT", hTitle, "BOTTOMLEFT", 0, -4)
    hInfo:SetPoint("RIGHT", head, "RIGHT", -110, 0)
    hInfo:SetJustifyH("LEFT")
    self.hInfo = hInfo

    local mapBtn = W.Button(head, "", 100, 20)
    mapBtn:SetPoint("RIGHT", -6, 0)
    mapBtn:SetScript("OnClick", function() UI:ToggleMapEntrance() end)
    mapBtn:Hide()
    self.mapBtn = mapBtn

    -- subheader: mode buttons (Normal / Heroic...), or "back to bosses", or search count
    local subBar = CreateFrame("Frame", nil, panel)
    subBar:SetPoint("TOPLEFT", head, "BOTTOMLEFT", 0, -1)
    subBar:SetPoint("TOPRIGHT", head, "BOTTOMRIGHT", 0, -1)
    subBar:SetHeight(28)
    W.Backdrop(subBar, C.inset)
    self.subBar = subBar

    local back = W.Button(subBar, "<", 22, 20)
    back:SetPoint("LEFT", 6, 0)
    back:SetScript("OnClick", function() UI:BackToBosses() end)
    back:Hide()
    self.backBtn = back

    local sub = W.Text(subBar, "GameFontHighlightSmall")
    sub:SetPoint("LEFT", back, "RIGHT", 6, 0)
    sub:SetPoint("RIGHT", -6, 0)
    sub:SetJustifyH("LEFT")
    self.sub = sub

    self.modeBtns = {}
    for i = 1, 4 do
        local b = W.Button(subBar, "", 50, 20)
        b:Hide()
        b:SetScript("OnClick", function(btn) UI:SetMode(btn.mode) end)
        self.modeBtns[i] = b
    end

    -- scrollable row list
    local rowsHolder = CreateFrame("Frame", nil, panel)
    rowsHolder:SetPoint("TOPLEFT", subBar, "BOTTOMLEFT", 0, -1)
    rowsHolder:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -1, 1)
    self.rowsHolder = rowsHolder

    for i = 1, ROWS do self.rows[i] = CreateRow(rowsHolder, i) end

    local sf = CreateFrame("ScrollFrame", "AtlasPlusRowScroll", rowsHolder, "FauxScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 2, -2)
    sf:SetPoint("BOTTOMRIGHT", -2, 2)
    sf:SetScript("OnVerticalScroll", function(s, offset)
        FauxScrollFrame_OnVerticalScroll(s, offset, ROW_H, function() UI:RefreshRows() end)
    end)
    W.FlatScroll(sf)
    self.rowScroll = sf

    local empty = W.Text(rowsHolder, "GameFontDisable")
    empty:SetPoint("CENTER", 0, 0)
    empty:Hide()
    self.empty = empty
end

---------------------------------------------------------------------------
-- Map / legend / loot logic
---------------------------------------------------------------------------
function UI:SelectMap(key, keepView)
    if not AtlasPlus_Maps[key] then return end
    self.mapKey = key
    AP.db.lastMap = key
    local m = AtlasPlus_Maps[key]
    self.mode = AP.db.modes[key] or (m.modes and m.modes[1]) or "N"
    if not keepView then
        self.view, self.lootLine = "legend", nil
        if self.searchBox:GetText() ~= "" then self.searchBox:SetText("") end
    end
    if m.nomap then
        self.mapTex:Hide()
        local info = self.mapInfo
        info.icon:SetTexture(AP.CAT_ICON[m.cat] or ICON)
        info.title:SetText(L[m.full or m.name] or (m.full or m.name))
        info.body:SetText(m.info or "")
        local n, items = 0, 0
        for _, modes in pairs(AtlasPlus_Loot[key] or {}) do
            n = n + 1
            for _, str in pairs(modes) do for _ in str:gmatch("[^,]+") do items = items + 1 end end
        end
        local nLists = (GetLocale() == "ruRU" and (n .. " " .. AP.GetPluralRu(n, "список", "списка", "списков"))) or (n .. " list" .. (n == 1 and "" or "s"))
        local nItems = (GetLocale() == "ruRU" and (items .. " " .. AP.GetPluralRu(items, "предмет", "предмета", "предметов"))) or (items .. " item" .. (items == 1 and "" or "s"))
        info.count:SetText(nLists .. ", " .. nItems)
        info:Show()
    else
        self.mapInfo:Hide()
        self.mapTex:Show()
        self.mapTex:SetTexture(AP.MAPS .. key)
    end
    FauxScrollFrame_SetOffset(self.rowScroll, 0)
    self.rowScroll:SetVerticalScroll(0)
    self:RevealInList(key)
    self:RefreshHeader()
    self:RefreshModes()
    self:RefreshRight()
end

function UI:SetPage(page)
    self.page = page
    local inst = page == "instance"
    local h = inst and (MAP_S + 2) or self.worldH
    self.frame:SetHeight(FRAME_H + h - (MAP_S + 2))
    self.frame:SetWidth(inst and (FRAME_W + ListW() - LIST_W) or self.worldW)
    self.listPanel:SetHeight(MAP_S + 2)
    self.listVisible = math.floor((MAP_S + 2 - 4) / LIST_ROW_H)
    if inst then
        self.worldTab:SetSelected(false)
        self.instTab:SetSelected(true)
        AP.WorldView:Hide()
        if AP.WorldMap then AP.WorldMap:Detach() end
        self.listPanel:Show()
        self.listBar:Show()
        self.mapHolder:Show()
        self.rightPanel:Show()
        self.sizer:Hide()
        if self.mapKey then self:SelectMap(self.mapKey, true) else self:SelectMap(AP.db.lastMap or "TheDeadmines") end
    else
        self.worldTab:SetSelected(true)
        self.instTab:SetSelected(false)
        self.listPanel:Hide()
        self.listBar:Hide()
        self.mapHolder:Hide()
        self.rightPanel:Hide()
        AP.WorldView:Show()
        self.sizer:Show()
        self.foot:SetText("")
        if AP.WorldMap then AP.WorldMap:Attach() end
    end
    self:RefreshList()
end

function UI:OpenInstance(key)
    self:Show()
    self:SetPage("instance")
    self:SelectMap(key)
end

function UI:ShowWorld(force)
    self:Show()
    if self.page ~= "world" or force then
        if AP.WorldMap then AP.WorldMap.restore = true end
        self:SetPage("world")
    end
end

function UI:BackToWorld()
    self:ShowWorld()
end

function UI:RefreshHeader()
    local m = AtlasPlus_Maps[self.mapKey]
    if not m then return end
    self.hTitle:SetText(m.full or m.name)
    local bits = {}
    if m.loc then bits[#bits + 1] = m.loc end
    if m.lvl then bits[#bits + 1] = string.format(L["Level %s"], m.lvl) end
    if m.minlvl then bits[#bits + 1] = string.format(L["min. %s"], m.minlvl) end
    if m.players then bits[#bits + 1] = string.format(L["%d players"], tonumber(m.players) or m.players) end
    if m.nomap then bits[#bits + 1] = "|cff888888" .. (L[m.cat] or m.cat) .. "|r" end
    if m.acr and m.acr ~= "" then bits[#bits + 1] = "|cff888888" .. m.acr .. "|r" end
    self.hInfo:SetText(table.concat(bits, "   "))
    local hub = m.full and m.full:match("^(.-):") or nil
    local other
    if m.cat == "Entrances" then
        other = AtlasPlus_EntranceFix and AtlasPlus_EntranceFix[m.name]
        if not other then
            for k, om in pairs(AtlasPlus_Maps) do
                if om.cat ~= "Entrances" and (om.name == m.name or (hub and om.full and om.full:find("^" .. hub, 1, true))) then
                    other = k; break
                end
            end
        end
        self.mapBtn:SetText(L["Instances"])
    else
        other = (m.name .. "Ent")
        if not AtlasPlus_Maps[other] and hub then
            for k, om in pairs(AtlasPlus_Maps) do
                if om.cat == "Entrances" and (om.name == hub or om.full == hub) then other = k; break end
            end
        end
        if not AtlasPlus_Maps[other] then other = nil end
        self.mapBtn:SetText(L["Entrance map"])
    end
    self.otherMapKey = other
    if other then self.mapBtn:Show() else self.mapBtn:Hide() end
end

function UI:ToggleMapEntrance()
    if self.otherMapKey then self:SelectMap(self.otherMapKey) end
end

function UI:RefreshModes()
    local m = AtlasPlus_Maps[self.mapKey]
    local modes = (m and m.modes) or {}
    for i, b in ipairs(self.modeBtns) do
        local md = modes[i]
        if md and self.view ~= "search" and not m.nomap then
            b.mode = md
            b:SetText(AP.MODE_LABEL[md] or md)
            b:SetWidth(math.max(34, b:GetFontString():GetStringWidth() + 14))
            b:SetSelected(md == self.mode)
            b:ClearAllPoints()
            if i == 1 then b:SetPoint("RIGHT", self.subBar, "RIGHT", -6, 0)
            else b:SetPoint("RIGHT", self.modeBtns[i - 1], "LEFT", -4, 0) end
            b:Show()
        else
            b:Hide()
        end
    end
    if self.view == "legend" then self.backBtn:Hide() else self.backBtn:Show() end
end

-- class loot: folded lists per class (like the instance list)
local CLASS_BITS = {
    { "WARRIOR", 1 }, { "PALADIN", 2 }, { "HUNTER", 4 }, { "ROGUE", 8 }, { "PRIEST", 16 },
    { "DEATHKNIGHT", 32 }, { "SHAMAN", 64 }, { "MAGE", 128 }, { "WARLOCK", 256 }, { "DRUID", 1024 },
}
local CLASS_LABEL = {
    WARRIOR = L["Warrior"], PALADIN = L["Paladin"], HUNTER = L["Hunter"], ROGUE = L["Rogue"],
    PRIEST = L["Priest"], DEATHKNIGHT = L["Death Knight"], SHAMAN = L["Shaman"], MAGE = L["Mage"],
    WARLOCK = L["Warlock"], DRUID = L["Druid"]
}
local CLASS_GROUP_MIN = 6      -- fewer class items than this: they stay in the main list

local function ClassMask(id)
    local d = AtlasPlus_Items[id]
    return d and d[6] or 0
end

function UI:GroupOpen(gk)
    self.groupOpen = self.groupOpen or {}
    local v = self.groupOpen[gk]
    if v == nil then
        -- your own class starts open
        local _, mine = UnitClass("player")
        return gk == "class:" .. (mine or "")
    end
    return v
end

function UI:ToggleGroup(gk)
    self.groupOpen = self.groupOpen or {}
    self.groupOpen[gk] = not self:GroupOpen(gk)
    self:RefreshRight()
end

function UI:LootRows(list)
    local rows, main, byClass, nClass = {}, {}, {}, 0
    for _, r in ipairs(list) do
        local cm = ClassMask(r.id)
        if cm > 0 then
            nClass = nClass + 1
            for _, c in ipairs(CLASS_BITS) do
                if bit.band(cm, c[2]) ~= 0 then
                    byClass[c[1]] = byClass[c[1]] or {}
                    table.insert(byClass[c[1]], r)
                end
            end
        else
            main[#main + 1] = r
        end
    end
    local function item(r)
        return { kind = "item", id = r.id, pct = r.pct, hm = r.hm, count = r.count, lv = r.lv, cost = r.cost,
                 copper = r.copper, quest = r.quest }
    end
    if nClass < CLASS_GROUP_MIN then
        -- a few class items: in the main list, in drop order
        main = {}
        for _, r in ipairs(list) do main[#main + 1] = r end
        byClass = {}
    end
    for _, r in ipairs(main) do rows[#rows + 1] = item(r) end
    for _, c in ipairs(CLASS_BITS) do
        local l = byClass[c[1]]
        if l then
            local gk = "class:" .. c[1]
            local open = self:GroupOpen(gk)
            local col = RAID_CLASS_COLORS and RAID_CLASS_COLORS[c[1]]
            local hex = col and string.format("|cff%02x%02x%02x", col.r * 255, col.g * 255, col.b * 255) or "|cffffffff"
            rows[#rows + 1] = { kind = "group", gk = gk, open = open,
                text = (open and "- " or "+ ") .. hex .. (CLASS_LABEL[c[1]] or c[1]) .. "|r |cff888888(" .. #l .. ")|r" }
            if open then for _, r in ipairs(l) do rows[#rows + 1] = item(r) end end
        end
    end
    return rows
end

-- rows for the current view
function UI:BuildRows()
    local key, rows = self.mapKey, {}
    local m = AtlasPlus_Maps[key]
    if self.view == "legend" then
        for i, line in ipairs(m and m.lines or {}) do
            local hasLoot = AtlasPlus_Loot[key] and AtlasPlus_Loot[key][i] ~= nil
            local text = type(line) == "table" and line[1] or line
            rows[#rows + 1] = { kind = "legend", line = i, text = text, loot = hasLoot, type = line[2], id = line[3] }
        end
        if m and m.mapID and AtlasPlus_Trash[m.mapID] then
            rows[#rows + 1] = { kind = "legend", line = "trash", text = "|cff999999" .. L["Trash mobs"] .. "|r", loot = true }
        end
    elseif self.view == "loot" then
        rows = self:LootRows(self:GetLoot(key, self.lootLine, self.mode))
    elseif self.view == "search" then
        rows = self.results or {}
    end
    return rows
end

function UI:RefreshRight()
    local m = AtlasPlus_Maps[self.mapKey]
    if self.view == "loot" then
        local t = LineTitle(self.mapKey, self.lootLine)
        self.sub:SetText(t .. (m.nomap and "" or ("  |cff888888" .. (AP.MODE_LABEL[self.mode] or "") .. "|r")))
    elseif self.view == "search" then
        local f = self.found or { places = 0, bosses = 0, items = #(self.results or {}) }
        local parts = {}
        if f.places > 0 then
            if GetLocale() == "ruRU" then
                parts[#parts + 1] = f.places .. " " .. AP.GetPluralRu(f.places, "подземелье", "подземелья", "подземелий")
            else
                parts[#parts + 1] = f.places .. " instance" .. (f.places == 1 and "" or "s")
            end
        end
        if f.bosses > 0 then
            if GetLocale() == "ruRU" then
                parts[#parts + 1] = f.bosses .. " " .. AP.GetPluralRu(f.bosses, "босс", "босса", "боссов")
            else
                parts[#parts + 1] = f.bosses .. " boss" .. (f.bosses == 1 and "" or "es")
            end
        end
        if GetLocale() == "ruRU" then
            parts[#parts + 1] = f.items .. " " .. AP.GetPluralRu(f.items, "предмет", "предмета", "предметов") .. (self.resultsCapped and " (первые 200)" or "")
        else
            parts[#parts + 1] = f.items .. " item" .. (f.items == 1 and "" or "s") .. (self.resultsCapped and " (first 200)" or "")
        end
        self.sub:SetText(table.concat(parts, ", ") .. L[" found"])
    else
        local hasLoot = AtlasPlus_Loot[self.mapKey] ~= nil
        self.sub:SetText(hasLoot and (m.nomap and string.format(L["Click a list (|r%s>|r|cff888888) to see its items|r"], AP.ACCENT) or string.format(L["Click a boss (|r%s>|r|cff888888) to see its loot|r"], AP.ACCENT)) or "")
    end
    self.rowData = self:BuildRows()
    self:RefreshRows()
    if self.view == "search" then
        self.foot:SetText(L["Click a result to open its boss.  Shift-click: link in chat.  Ctrl-click: try on."])
    elseif self.view == "loot" and m.cat == "Vendors" then
        self.foot:SetText(L["Prices from the game data.  Shift-click: link.  Ctrl-click: try on."])
    elseif self.view == "loot" and m.cat == "World Drops" then
        self.foot:SetText(L["Chances per kill, for a typical creature of the level.  Lx-y = creature levels.  Shift-click: link."])
    elseif self.view == "loot" then
        self.foot:SetText(L["Drop chances from the 3.3.5a database (the server can differ).  HM = hard mode.  |cff4a9effA|r / |cffff4a4aH|r = Alliance / Horde only.  Shift-click: link.  Ctrl-click: try on."])
    else
        self.foot:SetText("")
    end
end

local function PctText(pct)
    if not pct or pct <= 0 then return "" end
    if pct >= 99.5 then return "100%" end
    if pct >= 10 then return string.format("%.0f%%", pct) end
    if pct >= 1 then return string.format("%.1f%%", pct) end
    return string.format("%.2f%%", pct)
end

local FACTION_TAG = { A = " |cff4a9effA|r", H = " |cffff4a4aH|r" }

function UI:RefreshRows()
    local data = self.rowData or {}
    local count = #data
    FauxScrollFrame_Update(self.rowScroll, count, ROWS, ROW_H)
    local off = FauxScrollFrame_GetOffset(self.rowScroll)
    local width = self.rowsHolder:GetWidth() or RIGHT_W
    for i = 1, ROWS do
        local row = self.rows[i]
        local d = data[off + i]
        row.data = d
        if d then
            LayoutRow(row, d.kind, width, (d.cost or d.copper) and 120 or (d.quest and 50) or nil)
            if d.kind == "group" then
                row.left:SetText(d.text)
                row.right:SetText("")
                row.hl:Show()
            elseif d.kind == "legend" then
                row.left:SetText(d.text or "")
                row.right:SetText(d.loot and (AP.ACCENT .. L["loot >"] .. "|r") or "")
                local clickable = d.loot or (d.type == 1 and d.id and AP.byArea[d.id])
                if clickable then row.hl:Show() else row.hl:Hide() end
            elseif d.kind == "item" then
                local name, _, q, typ, _, fac = ItemInfo(d.id)
                row.icon:SetTexture(GetItemIcon(d.id) or "Interface\\Icons\\INV_Misc_QuestionMark")
                row.left:SetText((d.count and ("|cffffffff" .. d.count .. "x|r ") or "") .. (W.QUALITY_HEX[q] or "") .. name .. "|r" .. (FACTION_TAG[fac or ""] or "") .. (d.hm and (" |cffff8040" .. (GetLocale() == "ruRU" and "ХМ" or "HM") .. "|r") or "") or "")
                local mid = typ
                if d.lv then mid = typ .. " |cff888888L" .. d.lv .. "|r" end
                row.mid:SetText(mid)
                if d.cost or d.copper then row.right:SetText(CostText(d))
                elseif d.quest then row.right:SetText("|cffffd100" .. L["Quest"] .. "|r")
                else row.right:SetText(PctText(d.pct)) end
                row.hl:Show()
            elseif d.kind == "place" or d.kind == "boss" then
                row.icon:SetTexture(d.kind == "place" and ICON or "Interface\\Icons\\INV_Misc_Bone_Skull_02")
                row.left:SetText(AP.ACCENT .. d.text .. "|r")
                row.mid:SetText(d.where)
                row.right:SetText("")
                row.hl:Show()
            else -- result
                local name, _, q, typ, _, fac = ItemInfo(d.id)
                row.icon:SetTexture(GetItemIcon(d.id) or "Interface\\Icons\\INV_Misc_QuestionMark")
                row.left:SetText((W.QUALITY_HEX[q] or "") .. name .. "|r" .. (FACTION_TAG[fac or ""] or ""))
                row.mid:SetText(d.where)
                row.hl:Show()
            end
            row:Show()
        else
            row:Hide()
        end
    end
    if count == 0 and self.view == "search" then
        self.empty:SetText((self.searchText or ""):len() < 2 and L["Type at least 2 letters."] or L["Nothing found."])
        self.empty:Show()
    elseif count == 0 and self.view == "loot" then
        self.empty:SetText(L["No loot for this mode."])
        self.empty:Show()
    else
        self.empty:Hide()
    end
end

function UI:SetMode(mode)
    self.mode = mode
    AP.db.modes[self.mapKey] = mode
    self:RefreshModes()
    self:RefreshRight()
end

function UI:BackToBosses()
    self.view, self.lootLine = "legend", nil
    self:RefreshModes()
    self:RefreshRight()
end

---------------------------------------------------------------------------
-- Row clicks and tooltips
---------------------------------------------------------------------------
function UI:OnRowClick(row, button)
    local d = row.data
    if not d then return end
    if d.kind == "group" then
        self:ToggleGroup(d.gk)
    elseif d.kind == "legend" then
        if button == "RightButton" then UI:BackToWorld() return end
        if d.loot then
            self.view, self.lootLine = "loot", d.line
            self:RefreshModes()
            self:RefreshRight()
        elseif d.type == 1 and d.id and AP.byArea[d.id] then
            self:SelectMap(AP.byArea[d.id])
        end
    elseif d.kind == "item" then
        if button == "RightButton" then self:BackToBosses() return end
        local _, link = GetItemInfo(d.id)
        link = link or ("item:" .. d.id)
        if IsShiftKeyDown() and ChatEdit_InsertLink then
            ChatEdit_InsertLink(link)
        elseif IsControlKeyDown() and DressUpItemLink then
            DressUpItemLink(link)
        end
    elseif d.kind == "place" then
        self:SelectMap(d.mapKey)
    elseif d.kind == "boss" then
        self.mode = d.mode
        AP.db.modes[d.mapKey] = d.mode
        self:SelectMap(d.mapKey, true)
        self.view, self.lootLine = "loot", d.line
        self:RefreshModes()
        self:RefreshRight()
    elseif d.kind == "result" then
        if button == "RightButton" then return end
        local _, link = GetItemInfo(d.id)
        link = link or ("item:" .. d.id)
        if IsShiftKeyDown() and ChatEdit_InsertLink then
            ChatEdit_InsertLink(link)
        elseif IsControlKeyDown() and DressUpItemLink then
            DressUpItemLink(link)
        else
            self.mode = d.mode
            AP.db.modes[d.mapKey] = d.mode
            self:SelectMap(d.mapKey, true)
            self.view, self.lootLine = "loot", d.line
            self:RefreshModes()
            self:RefreshRight()
        end
    end
end

function UI:OnRowEnter(row)
    local d = row.data
    if not d then return end
    if d.kind == "group" then
        GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
        GameTooltip:AddLine(L["Items for this class"], 1, 1, 1)
        GameTooltip:AddLine(d.open and L["Click: fold"] or L["Click: open"], 0.6, 0.6, 0.6)
        GameTooltip:Show()
    elseif d.kind == "place" or d.kind == "boss" then
        GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
        GameTooltip:AddLine(d.text, 1, 1, 1)
        GameTooltip:AddLine(d.where, 0.8, 0.8, 0.8)
        GameTooltip:AddLine(d.kind == "place" and L["Click: open this map"] or L["Click: see its loot"], 0.6, 0.6, 0.6)
        GameTooltip:Show()
    elseif d.kind == "item" or d.kind == "result" then
        GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink("item:" .. d.id)
        GameTooltip:AddLine(" ")
        if d.cost or d.copper then
            local parts, rating = CostParts(d)
            if #parts == 0 then GameTooltip:AddLine(L["Cost: free"], 1, 0.82, 0) end
            for i, p in ipairs(parts) do
                GameTooltip:AddLine((i == 1 and L["Cost: "] or "          ") .. p[1] .. "  " .. p[2], 1, 1, 1)
            end
            if rating and rating > 0 then GameTooltip:AddLine(string.format(L["Requires a personal arena rating of %d"], rating), 1, 0.82, 0) end
            GameTooltip:AddLine(string.format(L["Sold by: %s"], LineTitle(self.mapKey, self.lootLine)), 0.8, 0.8, 0.8)
        elseif d.quest then
            GameTooltip:AddLine(string.format(L["Quest reward: %s"], (AtlasPlus_Quests[d.quest] or ("quest " .. d.quest))), 1, 0.82, 0)
        elseif d.pct and d.pct > 0 then
            GameTooltip:AddLine(string.format(L["Drop chance: %s%%"], d.pct) .. (d.count and ("  (" .. d.count .. "x)") or "") .. (d.hm and ("  " .. L["(hard mode)"]) or ""), 1, 0.82, 0)
        end
        if d.lv then
            GameTooltip:AddLine(string.format(L["World drop: creatures of level %s can drop this."], d.lv:gsub("%-", " - ")), 0.8, 0.8, 0.8, true)
        end
        if d.where then
            GameTooltip:AddLine(d.where, 1, 1, 1)
            if d.modes and not d.nomap then GameTooltip:AddLine("Drops in: " .. d.modes, 0.8, 0.8, 0.8) end
        end
        local fac = AtlasPlus_Items[d.id] and AtlasPlus_Items[d.id][5]
        if fac == "A" then GameTooltip:AddLine(L["Alliance only"], 0.29, 0.62, 1) elseif fac == "H" then GameTooltip:AddLine(L["Horde only"], 1, 0.29, 0.29) end
        GameTooltip:Show()
    end
end

function UI:OnRowLeave() GameTooltip:Hide() end

---------------------------------------------------------------------------
-- Search across every instance and difficulty
---------------------------------------------------------------------------
function UI:Search(text)
    self:Show()
    self:SetPage("instance")
    self.searchBox:SetText(text)
    self.searchBox:SetFocus()
end

function UI:DoSearch(raw)
    local query = strlower(strtrim(raw or ""))
    if query:len() < 2 then
        self.results = {}
        self.found = { places = 0, bosses = 0, items = 0 }
        self.view = "search"
        self:RefreshModes()
        self:RefreshRight()
        return
    end

    local places, bosses, items = {}, {}, {}
    local seenBoss, seenItem = {}, {}
    local qAcr = "^" .. query .. "$"

    -- 1. Instances: match name, full name, or acronym (ICC, Uld, EoE...)
    for key, m in pairs(AtlasPlus_Maps) do
        local name, full = strlower(m.name or ""), strlower(m.full or "")
        local acr = strlower(m.acr or "")
        local hit = name:find(query, 1, true) or full:find(query, 1, true)
        if not hit and acr ~= "" then
            for a in acr:gmatch("[^,%s]+") do if a == query or a:find(qAcr) then hit = true break end end
        end
        -- check Russian acronym or translated name in AP.L
        if not hit and AP.L then
            local ruName = strlower(AP.L[m.name] or "")
            local ruFull = strlower(AP.L[m.full or ""] or "")
            if ruName:find(query, 1, true) or ruFull:find(query, 1, true) then hit = true end
            if not hit and strlower(AP.L[query] or "") == name then hit = true end
        end
        if hit then
            local where = m.cat or ""
            if m.lvl and m.lvl ~= "" then where = where .. " (" .. m.lvl .. ")" end
            places[#places + 1] = { kind = "place", mapKey = key, text = m.full or m.name, where = where }
        end
    end
    table.sort(places, function(a, b) return a.text < b.text end)

    -- 2. Bosses / lists (pages without a map: "EventBrewfest:1", "RepArgentCrusade:2"...)
    for mapKey, m in pairs(AtlasPlus_Maps) do
        for line, entry in ipairs(m.lines or {}) do
            local title = LineTitle(mapKey, line)
            local ruTitle = AP.L and AP.L[title] or ""
            if strlower(title):find(query, 1, true) or (ruTitle ~= "" and strlower(ruTitle):find(query, 1, true)) then
                local bk = mapKey .. ":" .. line
                if not seenBoss[bk] then
                    seenBoss[bk] = true
                    local mode = (m.modes and m.modes[1]) or "N"
                    local where = m.name or (m.full or "")
                    if m.nomap then
                        where = m.cat or where
                    else
                        local num = type(entry) == "table" and entry[1] or entry or ""
                        local prefix = num:match("^%s*|c%x+([%w%']+%)?)") or num:match("^%s*([%w%']+%)?)")
                        if prefix and prefix ~= "" then where = where .. "  " .. prefix end
                    end
                    bosses[#bosses + 1] = { kind = "boss", mapKey = mapKey, line = line, mode = mode,
                                           text = title, where = where }
                end
            end
        end
    end
    table.sort(bosses, function(a, b) return a.text < b.text end)

    -- 3. Items: in loot / vendors / events / world drops
    local MAX = 200
    local capped = false
    for mapKey, lines in pairs(AtlasPlus_Loot) do
        local m = AtlasPlus_Maps[mapKey]
        for line, modes in pairs(lines) do
            for mode, str in pairs(modes) do
                for id in str:gmatch("(%d+):") do
                    id = tonumber(id)
                    if id and not seenItem[id] then
                        local name, _, _, typ = ItemInfo(id)
                        local d = AtlasPlus_Items[id]
                        local engName = d and d[1] or ""
                        local tLow = strlower(typ or "")
                        if strlower(name):find(query, 1, true) or strlower(engName):find(query, 1, true) or tLow:find(query, 1, true) then
                            seenItem[id] = true
                            local where
                            if m and m.cat == "World Drops" then
                                where = "World drop"
                            elseif m and m.cat == "Vendors" then
                                where = "Vendor: " .. (m.name or LineTitle(mapKey, line))
                            elseif m and m.cat == "World Events" then
                                where = "Event: " .. (m.name or LineTitle(mapKey, line))
                            elseif m then
                                where = (m.name or mapKey) .. " - " .. LineTitle(mapKey, line)
                            else
                                where = LineTitle(mapKey, line)
                            end
                            local modeList = {}
                            for md, s2 in pairs(modes) do if s2:find(tostring(id) .. ":") then modeList[#modeList + 1] = md end end
                            items[#items + 1] = { kind = "result", id = id, mapKey = mapKey, line = line, mode = mode,
                                                 where = where, modes = table.concat(modeList, ", ") }
                            if #items >= MAX then capped = true break end
                        end
                    end
                end
                if capped then break end
            end
            if capped then break end
        end
        if capped then break end
    end
    table.sort(items, function(a, b) return ItemInfo(a.id) < ItemInfo(b.id) end)

    local combined = {}
    for _, p in ipairs(places) do combined[#combined + 1] = p end
    for _, b in ipairs(bosses) do combined[#combined + 1] = b end
    for _, it in ipairs(items) do combined[#combined + 1] = it end

    self.results = combined
    self.resultsCapped = capped
    self.found = { places = #places, bosses = #bosses, items = #items }
    self.view = "search"
    self:RefreshModes()
    self:RefreshRight()
end

---------------------------------------------------------------------------
-- Settings: a window of its own, so the map stays visible while you change things
---------------------------------------------------------------------------
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
    bar:SetHeight(TOP)
    bar:EnableMouse(true)
    bar:SetScript("OnMouseDown", function() win:StartMoving() end)
    bar:SetScript("OnMouseUp", function() win:StopMovingOrSizing() end)

    local title = W.Text(bar, "GameFontNormal")
    title:SetPoint("LEFT", 10, 1)
    title:SetText(AP.ACCENT .. "Atlas Plus " .. L["Settings"] .. "|r")

    local close = W.Button(bar, "X", 22, 22)
    close:SetPoint("RIGHT", -8, 0)
    close:SetScript("OnClick", function() UI:HideSettings() end)

    local sizer = CreateFrame("Button", nil, win)
    W.Size(sizer, 16, 16)
    sizer:SetPoint("BOTTOMRIGHT", -2, 2)
    sizer:EnableMouse(true)
    sizer:RegisterForDrag("LeftButton")
    local stex = sizer:CreateTexture(nil, "OVERLAY")
    stex:SetAllPoints()
    stex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    sizer:SetScript("OnEnter", function() stex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight") end)
    sizer:SetScript("OnLeave", function() stex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up") end)
    sizer:SetScript("OnDragStart", function() win:StartSizing("BOTTOMRIGHT") end)
    sizer:SetScript("OnDragStop", function() win:StopMovingOrSizing() end)
    win:SetResizable(true)

    local s = CreateFrame("Frame", nil, win)
    s:SetPoint("TOPLEFT", 10, -TOP)
    s:SetPoint("BOTTOMRIGHT", -10, 10)
    W.Backdrop(s, C.panel)

    local x0, y = 20, -14
    local function Column(name, x)
        x0, y = x, -14
        local h = W.Text(s, "GameFontNormal")
        h:SetPoint("TOPLEFT", x0, y)
        h:SetText(AP.ACCENT .. name .. "|r")
        y = y - 26
    end
    local function db() return AP.db end
    local function Check(label, desc, key, after)
        local cb = W.CheckBox(s, label, desc, function() return db()[key] end, function(v) db()[key] = v; if after then after(v) end end)
        cb:SetPoint("TOPLEFT", x0 + 4, y)
        y = y - (desc and 46 or 28)
        return cb
    end
    local function Slider(label, minV, maxV, step, key, after)
        y = y - 26
        local sl = W.Slider(s, label, minV, maxV, step, function() return db()[key] or 1 end,
            function(v) db()[key] = v; if after then after(v) end end, function(v) return math.floor(v * 100 + 0.5) .. "%" end)
        sl:SetPoint("TOPLEFT", x0 + 8, y)
        y = y - 30
        return sl
    end
    local function Note(text)
        local n = W.Text(s, "GameFontDisableSmall")
        n:SetPoint("TOPLEFT", x0 + 4, y - 8)
        n:SetWidth(330)
        n:SetJustifyH("LEFT")
        n:SetText(text)
        y = y - 34
    end
    local function Refresh() AP.WorldMap:Update(); AP.WorldView:Refresh() end

    -- 1. the window
    Column(L["Window"], 20)
    Check(L["Open on the map of where you are"], L["In a dungeon or raid: its map and wing, with the loot of your difficulty. Outdoors: the world map, on your zone."], "autoSelect")
    Check(L["Open by itself in dungeons and raids"], nil, "autoOpen")
    local mm = W.CheckBox(s, L["Minimap button"], nil, function() return not db().minimap.hide end,
        function(v) db().minimap.hide = not v; UI:UpdateMinimapButton() end)
    mm:SetPoint("TOPLEFT", x0 + 4, y)
    y = y - 28
    Check(L["Lock the window"], L["It can't be moved by its title bar."], "locked")
    Check(L["Fade while moving"], L["See-through while you move, unless the mouse is over it."], "fadeMoving")
    Slider(L["Opacity while moving"], 0.1, 1, 0.05, "fadeAlpha")
    Slider(L["Window size"], 0.5, 1.6, 0.05, "scale", function() UI:ApplyLayout() end)
    Slider(L["Window opacity"], 0.3, 1, 0.05, "alpha", function() UI:ApplyLayout() end)
    Note(L["Move the window: drag its title. Resize it: drag its bottom right corner."])

    -- 2. the world map
    Column(L["World map"], 385)
    Check(L["The map key (M) opens Atlas Plus"], L["The game's map opens inside Atlas Plus, quests and map addons included. Untick to get the game's map back on M."], "replaceWorldMap")
    Check(L["Game instance maps"], L["In a dungeon or raid with a game map (Ulduar, Icecrown Citadel...): open it, on your floor. The Atlas map stays in the Atlas tab."], "gameInstanceMaps")
    Check(L["No fog of war"], L["Show the areas you have not explored yet."], "showUnexplored", Refresh)
    Check(L["Darken unexplored areas"], L["So you can still tell them apart."], "darkenUnexplored", Refresh)
    Check(L["Zone panel (top left of the map)"], nil, "zoneBlock", Refresh)
    Check(L["Zone info under the cursor"], nil, "worldZoneInfo", Refresh)
    Check(L["Coordinates (yours and the cursor's)"], nil, "worldCoords", Refresh)
    Slider(L["Quest icon size"], 0.5, 2, 0.1, "questScale", function() AP.WorldMap:RescaleQuestIcons() end)
    Slider(L["Game map opacity"], 0.3, 1, 0.05, "gameMapAlpha", function() AP.WorldMap:Update() end)
    Slider(L["Game small map size"], 0.5, 1.5, 0.05, "gameSmallScale", function() AP.WorldMap:Update() end)
    Note(L["These two: the game's map opened on its own (Game map button)."])

    -- 3. map markers: one switch per kind, two per line
    Column(L["Map markers"], 750)
    local col = 0
    local function Marker(label, key)
        local cb = W.CheckBox(s, label, nil, function() return db().markers[key] end, function(v) db().markers[key] = v; AP.Markers:Refresh() end)
        cb:SetPoint("TOPLEFT", x0 + 4 + col * 172, y)
        if col == 1 then y = y - 24 end
        col = 1 - col
    end
    Marker(L["Dungeons (blue)"], "dungeon"); Marker(L["Raids (green)"], "raid")
    Marker(L["World bosses"], "worldboss"); Marker(L["Portals"], "portal")
    Marker(L["Boats"], "boat");             Marker(L["Zeppelins"], "zepp")
    Marker(L["Deeprun Tram"], "tram");      Marker(L["Flight masters"], "flight")
    Marker(L["Innkeepers"], "inn");         Marker(L["Mailboxes"], "mail")
    Marker(L["Banks"], "bank");             Marker(L["Auction houses"], "auction")
    y = y - 6
    Check(L["Markers on continent maps"], L["Not the town ones (flight masters, inns...)."], "continentMarkers", function() AP.Markers:Refresh() end)
    Check(L["Hide Questie's dungeon and raid icons"], L["While the Atlas Plus ones are on. They come back when you turn these off."], "hideQuestieInstances", function() AP.Markers:SyncQuestie(true) end)
    Check(L["Only my faction's"], L["Transports, portals and town markers. Neutral ones always show."], "myFactionOnly", function() AP.Markers:Refresh() end)
    Slider(L["Marker size"], 0.6, 2, 0.1, "pinScale", function() AP.Markers:Refresh() end)
    Slider(L["Town marker size"], 0.5, 2, 0.1, "townScale", function() AP.Markers:Refresh() end)

    -- credits
    local credits = W.Text(s, "GameFontDisableSmall")
    credits:SetPoint("BOTTOMLEFT", 20, 16)
    credits:SetPoint("RIGHT", s, "RIGHT", -20, 0)
    credits:SetJustifyH("LEFT")
    credits:SetText(string.format(L["Atlas Plus %s. Instance maps and legends from Atlas (GPL v2). Zone levels from LibTourist-3.0 (MIT). Loot and drop chances based on 3.3.5a database.\\n/ap - open / close     /ap here - map of where you are     /ap world - world map     /ap search <item>     /ap reset - window position and size"], AP.VERSION))
end

function UI:PlaceSettings()
    local win = self.settings
    local sc = AP.db.settingsScale or 0.9
    win:SetScale(sc)
    win:ClearAllPoints()
    if self.frame:IsShown() then
        local left, top = self.frame:GetLeft(), self.frame:GetTop()
        if left and top then
            local uSc = UIParent:GetEffectiveScale()
            local x = (left * self.frame:GetEffectiveScale() - 20 * uSc) / (uSc * sc)
            local y = (top * self.frame:GetEffectiveScale() - 20 * uSc) / (uSc * sc)
            win:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
            return
        end
    end
    win:SetPoint("CENTER")
end

function UI:ShowSettings()
    self:PlaceSettings()
    self.settings:Show()
end

function UI:HideSettings() self.settings:Hide() end

function UI:ToggleSettings()
    if self.settings:IsShown() then self:HideSettings() else self:ShowSettings() end
end

---------------------------------------------------------------------------
-- Minimap button
---------------------------------------------------------------------------
local function PositionMinimapButton(b)
    local angle = math.rad(AP.db.minimap.angle or 200)
    b:ClearAllPoints()
    b:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * 80, math.sin(angle) * 80)
end

function UI:CreateMinimapButton()
    local b = CreateFrame("Button", "AtlasPlusMinimapButton", Minimap)
    b:SetFrameStrata("MEDIUM")
    W.Size(b, 31, 31)
    b:SetFrameLevel(8)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:RegisterForDrag("LeftButton")
    b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local icon = b:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture(ICON)
    W.Size(icon, 20, 20)
    icon:SetPoint("CENTER", 0, 0)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    local border = b:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    W.Size(border, 53, 53)
    border:SetPoint("TOPLEFT", 0, 0)

    b:SetScript("OnDragStart", function(self)
        self.dragging = true
        self:SetScript("OnUpdate", function(self)
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            px, py = px / scale, py / scale
            local angle = math.deg(math.atan2(py - my, px - mx))
            AP.db.minimap.angle = angle
            PositionMinimapButton(self)
        end)
    end)
    b:SetScript("OnDragStop", function(self)
        self.dragging = nil
        self:SetScript("OnUpdate", nil)
    end)
    b:SetScript("OnClick", function(_, button)
        if button == "RightButton" then UI:ToggleSettings() else UI:Toggle() end
    end)
    b:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Atlas Plus", 1, 1, 1)
        GameTooltip:AddLine("Click: open / close", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Right-click: settings", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Drag: move button", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    self.minimapBtn = b
    self:UpdateMinimapButton()
end

function UI:UpdateMinimapButton()
    local b = self.minimapBtn
    if not b then return end
    if AP.db.minimap.hide then b:Hide() else PositionMinimapButton(b); b:Show() end
end

---------------------------------------------------------------------------
-- Open / close
---------------------------------------------------------------------------
function UI:Show()
    if not self.frame then self:Create() end
    self.frame:Show()
    if not self.page then self:SetPage("instance") end
end

function UI:Hide()
    if self.frame then
        self.lastHide = GetTime()
        self.frame:Hide()
        if self.page == "world" and AP.WorldMap then AP.WorldMap:Detach() end
        if self.settings and self.settings:IsShown() then self.settings:Hide() end
    end
end

function UI:Toggle()
    if self.frame and self.frame:IsShown() then self:Hide() else self:Show() end
end

-- Escape > Interface > AddOns
---------------------------------------------------------------------------
function UI:CreateInterfacePanel()
    local p = CreateFrame("Frame", "AtlasPlusInterfacePanel", UIParent)
    p.name = "Atlas Plus"
    local t = W.Text(p, "GameFontNormalLarge")
    t:SetPoint("TOPLEFT", 16, -16)
    t:SetText("Atlas Plus |cff888888v" .. AP.VERSION .. "|r")
    local d = W.Text(p, "GameFontHighlight")
    d:SetPoint("TOPLEFT", t, "BOTTOMLEFT", 0, -10)
    d:SetWidth(560)
    d:SetJustifyH("LEFT")
    d:SetText(L["Instance maps with every boss and its loot, item search, and world map zone info.\n\n/ap - open / close     /ap here - map of where you are     /ap settings"])
    local open = W.Button(p, L["Open Atlas Plus"], 140, 24)
    open:SetPoint("TOPLEFT", d, "BOTTOMLEFT", 0, -16)
    open:SetScript("OnClick", function() HideUIPanel(InterfaceOptionsFrame); HideUIPanel(GameMenuFrame); UI:Show() end)
    local set = W.Button(p, L["Settings"], 100, 24)
    set:SetPoint("LEFT", open, "RIGHT", 8, 0)
    set:SetScript("OnClick", function() HideUIPanel(InterfaceOptionsFrame); HideUIPanel(GameMenuFrame); UI:ShowSettings() end)
    InterfaceOptions_AddCategory(p)
end

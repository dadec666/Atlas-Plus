--[[
    Atlas Plus - small flat widgets (same look as the other Saranwrap addons)
    Author: Saranwrap
]]

local AP = AtlasPlus
local W = {}
AP.W = W

W.C = {
    bg     = { 0.06, 0.06, 0.06, 0.95 },
    panel  = { 0.10, 0.10, 0.10, 1 },
    inset  = { 0.08, 0.08, 0.08, 1 },
    border = { 0, 0, 0, 1 },
    line   = { 0.22, 0.22, 0.22, 1 },
    button = { 0.10, 0.10, 0.10, 1 },
    header = { 0.13, 0.13, 0.13, 1 },
    accent = { 0.99, 0.48, 0.17, 1 },
    sel    = { 0.45, 0.22, 0.08, 1 },
    text   = { 0.90, 0.90, 0.90, 1 },
    muted  = { 0.55, 0.55, 0.60, 1 },
}
local C = W.C

W.QUALITY_HEX = {
    [0] = "|cff9d9d9d", [1] = "|cffffffff", [2] = "|cff1eff00", [3] = "|cff0070dd",
    [4] = "|cffa335ee", [5] = "|cffff8000", [6] = "|cffe6cc80", [7] = "|cffe6cc80",
}

function W.Size(f, w, h) f:SetWidth(w); f:SetHeight(h) end

function W.Backdrop(f, bg, border)
    f:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1, insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    f:SetBackdropColor(unpack(bg or C.panel))
    f:SetBackdropBorderColor(unpack(border or C.border))
end

function W.Text(parent, font, layer)
    return parent:CreateFontString(nil, layer or "OVERLAY", font or "GameFontHighlightSmall")
end

function W.Tip(owner, title, ...)
    GameTooltip:SetOwner(owner, "ANCHOR_TOP")
    GameTooltip:AddLine(title, 1, 1, 1)
    for i = 1, select("#", ...) do
        local line = select(i, ...)
        if line then GameTooltip:AddLine(line, 0.8, 0.8, 0.8, true) end
    end
    GameTooltip:Show()
end

function W.Button(parent, label, w, h)
    local b = CreateFrame("Button", nil, parent)
    W.Size(b, w, h or 22)
    W.Backdrop(b, C.button)
    local fs = W.Text(b)
    fs:SetPoint("CENTER")
    b:SetFontString(fs)
    b:SetText(label)
    b:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(unpack(C.accent))
        if self.tip then W.Tip(self, self.tipTitle or label, self.tip) end
    end)
    b:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(unpack(self.selected and C.accent or C.border))
        GameTooltip:Hide()
    end)
    b:SetScript("OnMouseDown", function(self) self:GetFontString():SetPoint("CENTER", 1, -1) end)
    b:SetScript("OnMouseUp", function(self) self:GetFontString():SetPoint("CENTER", 0, 0) end)
    function b:SetSelected(on)
        self.selected = on
        self:SetBackdropColor(unpack(on and C.sel or C.button))
        self:SetBackdropBorderColor(unpack(on and C.accent or C.border))
    end
    return b
end

function W.EditBox(parent, w, h, placeholder)
    local e = CreateFrame("EditBox", nil, parent)
    W.Size(e, w, h or 22)
    W.Backdrop(e, C.inset, C.line)
    e:SetFontObject(ChatFontNormal)
    e:SetTextInsets(6, 20, 0, 0)
    e:SetAutoFocus(false)
    local ph = W.Text(e, "GameFontDisableSmall")
    ph:SetPoint("LEFT", 7, 0)
    ph:SetText(placeholder or "")
    e.placeholder = ph
    local clear = CreateFrame("Button", nil, e)
    W.Size(clear, 16, 16)
    clear:SetPoint("RIGHT", -3, 0)
    local x = W.Text(clear, "GameFontDisableSmall")
    x:SetPoint("CENTER")
    x:SetText("x")
    clear:SetScript("OnClick", function() e:SetText(""); e:ClearFocus() end)
    clear:Hide()
    e.clear = clear
    e:SetScript("OnEscapePressed", function(self) self:SetText(""); self:ClearFocus() end)
    e:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    e:SetScript("OnEditFocusGained", function(self) self:SetBackdropBorderColor(unpack(C.accent)) end)
    e:SetScript("OnEditFocusLost", function(self) self:SetBackdropBorderColor(unpack(C.line)) end)
    return e
end

-- Check box: dark square with the yellow game check mark
function W.CheckBox(parent, label, desc, getter, setter)
    local cb = CreateFrame("CheckButton", nil, parent)
    W.Size(cb, 18, 18)
    W.Backdrop(cb, C.inset, C.line)
    local check = cb:CreateTexture(nil, "OVERLAY")
    W.Size(check, 24, 24)
    check:SetPoint("CENTER", 0, 0)
    check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    cb:SetCheckedTexture(check)
    local fs = W.Text(cb, "GameFontHighlight")
    fs:SetPoint("LEFT", cb, "RIGHT", 8, 0)
    fs:SetText(label)
    cb.label = fs
    if desc then
        local d = W.Text(cb, "GameFontDisableSmall")
        d:SetPoint("TOPLEFT", fs, "BOTTOMLEFT", 0, -3)
        d:SetWidth(330)
        d:SetJustifyH("LEFT")
        d:SetText(desc)
        cb.desc = d
    end
    cb:SetScript("OnShow", function(self) self:SetChecked(getter()) end)
    cb:SetScript("OnClick", function(self) setter(self:GetChecked() and true or false) end)
    cb:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(C.accent)) end)
    cb:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.line)) end)
    return cb
end

-- Slider: thin flat track, orange handle, value in the label
local sliderCount = 0
function W.Slider(parent, label, minV, maxV, step, getter, setter, fmt)
    sliderCount = sliderCount + 1
    local s = CreateFrame("Slider", "AtlasPlusSlider" .. sliderCount, parent)
    W.Size(s, 220, 14)
    s:SetOrientation("HORIZONTAL")
    s:SetMinMaxValues(minV, maxV)
    s:SetValueStep(step)
    s:EnableMouseWheel(true)
    local track = s:CreateTexture(nil, "BACKGROUND")
    track:SetTexture("Interface\\Buttons\\WHITE8X8")
    track:SetVertexColor(unpack(C.line))
    track:SetHeight(4)
    track:SetPoint("LEFT")
    track:SetPoint("RIGHT")
    local thumb = s:CreateTexture(nil, "OVERLAY")
    thumb:SetTexture("Interface\\Buttons\\WHITE8X8")
    thumb:SetVertexColor(unpack(C.accent))
    W.Size(thumb, 8, 14)
    s:SetThumbTexture(thumb)
    local fs = W.Text(s, "GameFontHighlight")
    fs:SetPoint("BOTTOMLEFT", s, "TOPLEFT", 0, 4)
    local function show(v) fs:SetText(label .. ": " .. AP.ACCENT .. (fmt and fmt(v) or v) .. "|r") end
    s:SetScript("OnShow", function(self) local v = getter(); self:SetValue(v); show(v) end)
    s:SetScript("OnValueChanged", function(self, v)
        v = math.floor(v / step + 0.5) * step
        show(v)
        if self:IsShown() and math.abs(v - getter()) > 1e-6 then setter(v) end
    end)
    s:SetScript("OnMouseWheel", function(self, d)
        local v = math.min(maxV, math.max(minV, self:GetValue() + d * step))
        self:SetValue(v)
    end)
    return s
end

-- Flat scroll bar for a FauxScrollFrame / UIPanelScrollFrame
function W.FlatScroll(sf)
    for _, r in ipairs({ sf:GetRegions() }) do r:SetAlpha(0) end
    local name = sf:GetName()
    local sb = name and _G[name .. "ScrollBar"]
    if not sb then return end
    for _, r in ipairs({ sb:GetRegions() }) do
        if r ~= sb:GetThumbTexture() then r:SetAlpha(0) end
    end
    local track = sb:CreateTexture(nil, "BACKGROUND")
    track:SetTexture("Interface\\Buttons\\WHITE8X8")
    track:SetVertexColor(unpack(C.inset))
    track:SetWidth(6)
    track:SetPoint("TOP", 0, 0)
    track:SetPoint("BOTTOM", 0, 0)
    local thumb = sb:GetThumbTexture()
    if thumb then
        thumb:SetTexture("Interface\\Buttons\\WHITE8X8")
        thumb:SetVertexColor(0.40, 0.40, 0.40, 1)
        thumb:SetWidth(6)
    end
    for _, part in ipairs({ { "ScrollUpButton", "^" }, { "ScrollDownButton", "v" } }) do
        local b = _G[sb:GetName() .. part[1]]
        if b then
            for _, t in ipairs({ b:GetNormalTexture(), b:GetPushedTexture(), b:GetDisabledTexture(), b:GetHighlightTexture() }) do
                if t then t:SetAlpha(0) end
            end
            W.Backdrop(b, C.panel, C.line)
            local fs = W.Text(b, "GameFontHighlightSmall")
            fs:SetPoint("CENTER", 0, 0)
            fs:SetText(part[2])
            b:HookScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(C.accent)) end)
            b:HookScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.line)) end)
        end
    end
end

local menuFrame = CreateFrame("Frame", "AtlasPlusMenu", UIParent, "UIDropDownMenuTemplate")
-- a second click on the same button closes the menu
function W.ShowMenu(menu, anchor)
    if DropDownList1 and DropDownList1:IsShown() and W.menuAnchor == anchor then
        CloseDropDownMenus()
        W.menuAnchor = nil
        return
    end
    W.menuAnchor = anchor
    EasyMenu(menu, menuFrame, anchor or "cursor", 0, 0, "MENU")
end

--[[
    Atlas Plus - no fog of war
    Draws the areas you have not explored yet on the game's map (inside Atlas Plus or on its own).
    Area list: the game's WorldMapOverlay table (Data\Overlays.lua). Drawn like the game draws explored areas.
    Author: Saranwrap
]]

local AP = AtlasPlus
local FOG = {}
AP.Fog = FOG

local TILE = 256
local pool = {}

local function Texture(i)
    local t = pool[i]
    if not t then
        t = WorldMapDetailFrame:CreateTexture(nil, "ARTWORK")
        pool[i] = t
    end
    return t
end

function FOG:Update()
    if not (WorldMapDetailFrame and AP.db) then return end
    local n = 0
    local file = GetMapInfo()
    local data = AP.db.showUnexplored and file and AtlasPlus_Overlays[file]
    local level = GetCurrentMapDungeonLevel and GetCurrentMapDungeonLevel() or 0
    if data and level == 0 then
        local explored = {}
        for i = 1, GetNumMapOverlays() do
            local name = GetMapOverlayInfo(i)
            if name and name ~= "" then explored[strupper(name:match("([^\\]+)$") or name)] = true end
        end
        local shade = AP.db.darkenUnexplored and 0.55 or 1
        for i = 1, #data, 5 do
            local tex, tw, th, ox, oy = data[i], data[i + 1], data[i + 2], data[i + 3], data[i + 4]
            if not explored[strupper(tex)] then
                local path = "Interface\\WorldMap\\" .. file .. "\\" .. tex
                local wide, tall = math.ceil(tw / TILE), math.ceil(th / TILE)
                for j = 1, tall do
                    local ph, fh
                    if j < tall then ph, fh = TILE, TILE else
                        ph = th % TILE; if ph == 0 then ph = TILE end
                        fh = 16; while fh < ph do fh = fh * 2 end
                    end
                    for k = 1, wide do
                        local pw, fw
                        if k < wide then pw, fw = TILE, TILE else
                            pw = tw % TILE; if pw == 0 then pw = TILE end
                            fw = 16; while fw < pw do fw = fw * 2 end
                        end
                        n = n + 1
                        local t = Texture(n)
                        t:SetWidth(pw)
                        t:SetHeight(ph)
                        t:SetTexCoord(0, pw / fw, 0, ph / fh)
                        t:ClearAllPoints()
                        t:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", ox + TILE * (k - 1), -(oy + TILE * (j - 1)))
                        t:SetTexture(path .. ((j - 1) * wide + k))
                        t:SetVertexColor(shade, shade, shade)
                        t:Show()
                    end
                end
            end
        end
    end
    for i = n + 1, #pool do pool[i]:Hide() end
    self.count = n
end

function FOG:Init()
    if WorldMapFrame_Update then hooksecurefunc("WorldMapFrame_Update", function() FOG:Update() end) end
    local ev = CreateFrame("Frame")
    ev:RegisterEvent("WORLD_MAP_UPDATE")
    ev:SetScript("OnEvent", function() FOG:Update() end)
end

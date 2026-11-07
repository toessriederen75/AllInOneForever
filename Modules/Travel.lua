-- AllInOne: boat and zeppelin routes on the world map. Every dock and
-- zeppelin tower gets a small pin; pointing at it tells where it goes. On
-- continent and world maps a dashed line joins the two ends of each route.
--
-- The places are our own list (zone map and position in it). They are
-- placed on whatever map is open through the game's own map conversion, so
-- the same pin shows on the zone, the continent and the world map.
--
-- Cost: nothing while the map is closed. Opening the map or changing it
-- places at most a few dozen textures; zooming only rescales them.

local ADDON, ns = ...
if ns.env then setfenv(1, ns.env) end
local AIO, L = ns.AIO, ns.L

if GetLocale() == "deDE" then
    L["Travel routes"]         = "Reiserouten"
    L["Boats and zeppelins on the world map."] = "Schiffe und Zeppeline auf der Weltkarte."
    L["Shows every boat dock and zeppelin tower on the world map. Pointing at one tells where it goes. On continent and world maps a line joins the two ends of each route."] =
        "Zeigt jeden Schiffsanleger und Zeppelinturm auf der Weltkarte. Zeigst du darauf, siehst du, wohin es geht. Auf Kontinent- und Weltkarte verbindet eine Linie die beiden Enden jeder Route."
    L["Only my faction"]       = "Nur meine Fraktion"
    L["Routes of the other faction are left out. Neutral routes are always shown."] =
        "Routen der anderen Fraktion werden weggelassen. Neutrale Routen sind immer zu sehen."
    L["Lines between the ends"] = "Linien zwischen den Enden"
    L["Pin size"]              = "Grösse der Symbole"
    L["Boat to %s"]            = "Schiff nach %s"
    L["Zeppelin to %s"]        = "Zeppelin nach %s"
    L["Alliance"]              = "Allianz"
    L["Horde"]                 = "Horde"
    L["Neutral"]               = "Neutral"
    L["Menethil Harbor"]       = "Hafen von Menethil"
    L["Auberdine"]             = "Auberdine"
    L["Theramore"]             = "Theramore"
    L["Rut'theran Village"]    = "Rut'theran"
    L["Booty Bay"]             = "Beutebucht"
    L["Ratchet"]               = "Ratschet"
    L["Orgrimmar"]             = "Orgrimmar"
    L["Undercity"]             = "Unterstadt"
    L["Grom'gol Base Camp"]    = "Grom'gol-Basislager"
end

local M = AIO:NewModule("travel", {
    title    = L["Travel routes"],
    short    = L["Boats and zeppelins on the world map."],
    desc     = L["Shows every boat dock and zeppelin tower on the world map. Pointing at one tells where it goes. On continent and world maps a line joins the two ends of each route."],
    category = "maps",
    default  = true,
    defaults = { ownFaction = true, lines = true, size = 22 },
    options  = {
        { type = "toggle", key = "ownFaction", label = L["Only my faction"], desc = L["Routes of the other faction are left out. Neutral routes are always shown."] },
        { type = "toggle", key = "lines", label = L["Lines between the ends"] },
        { type = "slider", key = "size", label = L["Pin size"], min = 14, max = 36, step = 1 },
    },
})

-- ---------------------------------------------------------------------------
-- The routes: kind, faction, and both ends as { zone map, x, y, name }.
-- Zone maps by their map ID; positions as fractions of the zone map.
-- ---------------------------------------------------------------------------

local WETLANDS, DARKSHORE, DUSTWALLOW, TELDRASSIL = 1437, 1439, 1445, 1438
local STRANGLETHORN, BARRENS, DUROTAR, TIRISFAL = 1434, 1413, 1411, 1420

local ROUTES = {
    { kind = "boat", faction = "Alliance",
      { WETLANDS, 0.0466, 0.5713, L["Menethil Harbor"] }, { DARKSHORE, 0.3243, 0.4382, L["Auberdine"] } },
    { kind = "boat", faction = "Alliance",
      { WETLANDS, 0.0503, 0.6347, L["Menethil Harbor"] }, { DUSTWALLOW, 0.7180, 0.5640, L["Theramore"] } },
    { kind = "boat", faction = "Alliance",
      { DARKSHORE, 0.3309, 0.4014, L["Auberdine"] }, { TELDRASSIL, 0.5510, 0.9480, L["Rut'theran Village"] } },
    { kind = "boat", faction = "Neutral",
      { STRANGLETHORN, 0.2589, 0.7310, L["Booty Bay"] }, { BARRENS, 0.6370, 0.3860, L["Ratchet"] } },
    { kind = "zeppelin", faction = "Horde",
      { DUROTAR, 0.5090, 0.1380, L["Orgrimmar"] }, { TIRISFAL, 0.6070, 0.5880, L["Undercity"] } },
    { kind = "zeppelin", faction = "Horde",
      { DUROTAR, 0.5060, 0.1260, L["Orgrimmar"] }, { STRANGLETHORN, 0.3150, 0.2970, L["Grom'gol Base Camp"] } },
    { kind = "zeppelin", faction = "Horde",
      { TIRISFAL, 0.6190, 0.5900, L["Undercity"] }, { STRANGLETHORN, 0.3160, 0.3020, L["Grom'gol Base Camp"] } },
}

local ICON = {
    boat     = "Interface\\AddOns\\" .. ADDON .. "\\Media\\map\\pin_boat",
    zeppelin = "Interface\\AddOns\\" .. ADDON .. "\\Media\\map\\pin_zeppelin",
}
local LINE_COLOR = {
    Alliance = { 0.35, 0.62, 1.00, 0.85 },
    Horde    = { 1.00, 0.35, 0.30, 0.85 },
    Neutral  = { 1.00, 0.82, 0.35, 0.85 },
}

-- ---------------------------------------------------------------------------
-- Positions on the open map
-- ---------------------------------------------------------------------------

-- World position of every route end, worked out once: { continent, vector }.
local world = {}

local function WorldPos(e)
    local w = world[e]
    if w ~= nil then return w or nil end
    world[e] = false
    if not (C_Map and C_Map.GetWorldPosFromMapPos and C_Map.GetMapInfo(e[1])) then return nil end
    local ok, continent, pos = pcall(C_Map.GetWorldPosFromMapPos, e[1], CreateVector2D(e[2], e[3]))
    if ok and continent and pos then
        world[e] = { continent, pos }
        return world[e]
    end
    return nil
end

--- Where a route end lies on map `mapID` (0..1 each), or nil when it is not on it.
local function MapPos(e, mapID)
    if e[1] == mapID then return e[2], e[3] end
    local w = WorldPos(e)
    if not w then return nil end
    local ok, _, pos = pcall(C_Map.GetMapPosFromWorldPos, w[1], w[2], mapID)
    if not (ok and type(pos) == "table" and pos.GetXY) then return nil end
    local x, y = pos:GetXY()
    if not x or x < 0 or x > 1 or y < 0 or y > 1 then return nil end
    return x, y
end

-- ---------------------------------------------------------------------------
-- Pins and lines on the map canvas
-- ---------------------------------------------------------------------------

local pins, lines = {}, {}
local layer        -- our frame on the map's canvas

local function Canvas()
    local wm = _G.WorldMapFrame
    return wm and wm.ScrollContainer and wm.ScrollContainer.Child
end

local function PinTooltip(pin)
    GameTooltip:SetOwner(pin, "ANCHOR_RIGHT")
    GameTooltip:AddLine(pin.here, 1, 0.82, 0)
    for _, t in ipairs(pin.trips) do
        local line = (t.kind == "boat" and L["Boat to %s"] or L["Zeppelin to %s"]):format(t.to)
        local c = LINE_COLOR[t.faction]
        GameTooltip:AddDoubleLine(line, L[t.faction], 1, 1, 1, c[1], c[2], c[3])
    end
    GameTooltip:Show()
end

local function Pin(i)
    local p = pins[i]
    if p then return p end
    p = CreateFrame("Frame", nil, layer)
    p:SetFrameLevel(layer:GetFrameLevel() + 2)
    p.tex = p:CreateTexture(nil, "OVERLAY")
    p.tex:SetAllPoints()
    p:EnableMouse(true)
    if p.SetPropagateMouseClicks then p:SetPropagateMouseClicks(true) end
    p:SetScript("OnEnter", PinTooltip)
    p:SetScript("OnLeave", GameTooltip_Hide)
    pins[i] = p
    return p
end

local function Line(i)
    local l = lines[i]
    if l then return l end
    l = layer:CreateLine(nil, "ARTWORK")
    l:SetTexture("Interface\\Buttons\\WHITE8X8")
    lines[i] = l
    return l
end

local function Scale()
    local wm = _G.WorldMapFrame
    local s = wm and wm.GetCanvasScale and wm:GetCanvasScale() or 1
    return (s and s > 0) and s or 1
end

--- Sizes follow the zoom so pins and lines keep the same size on screen.
local function Rescale()
    if not layer then return end
    local inv = 1 / Scale()
    local size = M.db.size * inv
    for _, p in ipairs(pins) do
        if p:IsShown() then p:SetSize(size, size) end
    end
    for _, l in ipairs(lines) do
        if l:IsShown() then l:SetThickness(math.max(1, 2.5 * inv)) end
    end
end

local function Wanted(r)
    if not M.db.ownFaction or r.faction == "Neutral" then return true end
    return r.faction == UnitFactionGroup("player")
end

function M:Refresh()
    local canvas = Canvas()
    if not canvas then return end
    if not layer then
        layer = CreateFrame("Frame", nil, canvas)
        layer:SetAllPoints(canvas)
        layer:SetFrameLevel(canvas:GetFrameLevel() + 30)
    end
    local wm = _G.WorldMapFrame
    local mapID = self.enabled and wm and wm:IsShown() and wm.GetMapID and wm:GetMapID()
    local w, h = canvas:GetSize()
    local np, nl = 0, 0
    if mapID and w and w > 0 then
        -- One pin per place on this map; trips from the same place share it.
        local byPlace = {}
        for _, r in ipairs(ROUTES) do
            if Wanted(r) then
                local ax, ay = MapPos(r[1], mapID)
                local bx, by = MapPos(r[2], mapID)
                for side = 1, 2 do
                    local e, x, y = r[side], side == 1 and ax or bx, side == 1 and ay or by
                    if x then
                        local other = r[side == 1 and 2 or 1]
                        local key = ("%.2f:%.2f"):format(x, y)
                        local p = byPlace[key]
                        if not p then
                            np = np + 1
                            p = Pin(np)
                            p.here, p.trips = e[4], {}
                            p.tex:SetTexture(ICON[r.kind])
                            p:ClearAllPoints()
                            p:SetPoint("CENTER", layer, "TOPLEFT", x * w, -y * h)
                            p:Show()
                            byPlace[key] = p
                        end
                        p.trips[#p.trips + 1] = { kind = r.kind, faction = r.faction, to = other[4] }
                    end
                end
                if self.db.lines and ax and bx and r[1][1] ~= mapID and r[2][1] ~= mapID then
                    nl = nl + 1
                    local l = Line(nl)
                    local c = LINE_COLOR[r.faction]
                    l:SetVertexColor(c[1], c[2], c[3], c[4])
                    l:SetStartPoint("TOPLEFT", layer, ax * w, -ay * h)
                    l:SetEndPoint("TOPLEFT", layer, bx * w, -by * h)
                    l:Show()
                end
            end
        end
    end
    for i = np + 1, #pins do pins[i]:Hide() end
    for i = nl + 1, #lines do lines[i]:Hide() end
    Rescale()
end

-- ---------------------------------------------------------------------------
-- Hooks
-- ---------------------------------------------------------------------------

local hooked = false
local function Hook()
    local wm = _G.WorldMapFrame
    if hooked or not wm then return end
    hooked = true
    wm:HookScript("OnShow", function() M:Refresh() end)
    if wm.OnMapChanged then hooksecurefunc(wm, "OnMapChanged", function() M:Refresh() end) end
    if wm.OnCanvasScaleChanged then hooksecurefunc(wm, "OnCanvasScaleChanged", Rescale) end
    if wm.ScrollContainer then
        wm.ScrollContainer:HookScript("OnSizeChanged", function() M:Refresh() end)
    end
end

function M:OnEnable()
    Hook()
    self:Refresh()
end

function M:OnDisable()
    self:Refresh()
end

function M:OnSettingChanged()
    self:Refresh()
end

-- The world map is load-on-demand on some clients.
M:On("ADDON_LOADED", function(name)
    if name == "Blizzard_WorldMap" then Hook() end
end)
M:On("PLAYER_ENTERING_WORLD", function() Hook() end)

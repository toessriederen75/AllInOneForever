-- AllInOne: more on the world map. Pointing at a zone on a continent map
-- shows its level range next to the name (coloured like quests: red too
-- high, green easy, grey trivial) and, if wanted, the fishing skill it needs.
-- On zone maps an arrow marks every crossing into the next zone (click it to
-- open that zone's map) and every flight master gets the game's taxi icon.
--
-- Level ranges and places as in Leatrix Maps by Leatrix (WoW Forever), who
-- gathered them first; see MapData.lua. The code here is our own.
--
-- Cost: nothing while the map is closed. Opening a zone map places at most
-- a dozen pins; the level range is added to the name the map already shows.

local ADDON, ns = ...
if ns.env then setfenv(1, ns.env) end
local AIO, L = ns.AIO, ns.L

if GetLocale() == "deDE" then
    L["Map details"]            = "Kartendetails"
    L["Level ranges, zone crossings and flight masters on the world map."] =
        "Stufenbereiche, Zonenübergänge und Greifenmeister auf der Weltkarte."
    L["Pointing at a zone on the continent map shows its level range, coloured like quests. On zone maps, arrows mark the crossings into the next zone (click one to open that zone) and flight masters get the taxi icon."] =
        "Zeigst du auf der Kontinentkarte auf eine Zone, siehst du ihren Stufenbereich, eingefärbt wie Quests. Auf Zonenkarten markieren Pfeile die Übergänge in die nächste Zone (ein Klick öffnet diese Zone) und Greifenmeister bekommen das Flugsymbol."
    L["Level ranges of zones"]  = "Stufenbereiche der Zonen"
    L["On the continent map, next to the zone name under the mouse."] = "Auf der Kontinentkarte neben dem Zonennamen unter der Maus."
    L["Fishing skill"]          = "Angelfertigkeit"
    L["The fishing skill a zone needs, below its name."] = "Die Angelfertigkeit, die eine Zone braucht, unter ihrem Namen."
    L["Fishing"]                = "Angeln"
    L["Zone crossings"]         = "Zonenübergänge"
    L["Arrows on zone maps where a path leads into the next zone."] = "Pfeile auf Zonenkarten, wo ein Weg in die nächste Zone führt."
    L["Flight masters"]         = "Greifenmeister"
    L["Only my faction's flight masters"] = "Nur Greifenmeister meiner Fraktion"
    L["Neutral ones are always shown."] = "Neutrale werden immer gezeigt."
    L["Icon size"]              = "Grösse der Symbole"
    L["Click: show this map"]   = "Klick: diese Karte zeigen"
    L["Flight master"]          = "Greifenmeister"
end

local M = AIO:NewModule("mapinfo", {
    title    = L["Map details"],
    short    = L["Level ranges, zone crossings and flight masters on the world map."],
    desc     = L["Pointing at a zone on the continent map shows its level range, coloured like quests. On zone maps, arrows mark the crossings into the next zone (click one to open that zone) and flight masters get the taxi icon."],
    category = "maps",
    default  = true,
    defaults = { levels = true, fishing = true, arrows = true, flights = true, ownFaction = true, size = 20 },
    options  = {
        { type = "toggle", key = "levels", label = L["Level ranges of zones"], desc = L["On the continent map, next to the zone name under the mouse."] },
        { type = "toggle", key = "fishing", label = L["Fishing skill"], desc = L["The fishing skill a zone needs, below its name."],
          disabled = function(m) return not m.db.levels end },
        { type = "toggle", key = "arrows", label = L["Zone crossings"], desc = L["Arrows on zone maps where a path leads into the next zone."] },
        { type = "toggle", key = "flights", label = L["Flight masters"], half = true },
        { type = "toggle", key = "ownFaction", label = L["Only my faction's flight masters"], desc = L["Neutral ones are always shown."], half = true,
          disabled = function(m) return not m.db.flights end },
        { type = "slider", key = "size", label = L["Icon size"], min = 12, max = 32, step = 1 },
    },
})

-- ---------------------------------------------------------------------------
-- Level ranges: { lowest, highest, fishing skill }. Cities only fishing.
-- ---------------------------------------------------------------------------

local LEVELS = {
    -- Eastern Kingdoms
    [1416] = { 30, 40, "130" },        -- Alterac Mountains
    [1417] = { 30, 40, "130" },        -- Arathi Highlands
    [1418] = { 35, 45 },               -- Badlands
    [1419] = { 45, 55 },               -- Blasted Lands
    [1428] = { 50, 58, "330" },        -- Burning Steppes
    [1430] = { 55, 60, "330" },        -- Deadwind Pass
    [1426] = { 1, 10, "1" },           -- Dun Morogh
    [1431] = { 18, 30, "55" },         -- Duskwood
    [1423] = { 53, 60, "330" },        -- Eastern Plaguelands
    [1429] = { 1, 10, "1" },           -- Elwynn Forest
    [1424] = { 20, 30, "55" },         -- Hillsbrad Foothills
    [1455] = { nil, nil, "1" },        -- Ironforge
    [1432] = { 10, 20, "1" },          -- Loch Modan
    [1433] = { 15, 25, "55" },         -- Redridge Mountains
    [1427] = { 43, 50 },               -- Searing Gorge
    [1421] = { 10, 20, "1" },          -- Silverpine Forest
    [1453] = { nil, nil, "1" },        -- Stormwind City
    [1434] = { 30, 45, "130 (205)" },  -- Stranglethorn Vale
    [1435] = { 35, 45, "130" },        -- Swamp of Sorrows
    [1425] = { 40, 50, "205" },        -- The Hinterlands
    [1420] = { 1, 10, "1" },           -- Tirisfal Glades
    [1458] = { nil, nil, "1" },        -- Undercity
    [1436] = { 10, 20, "1" },          -- Westfall
    [1422] = { 51, 58, "205" },        -- Western Plaguelands
    [1437] = { 20, 30, "55" },         -- Wetlands
    -- Kalimdor
    [1440] = { 18, 30, "55" },         -- Ashenvale
    [1447] = { 45, 55, "205 (330)" },  -- Azshara
    [1439] = { 10, 20, "1" },          -- Darkshore
    [1457] = { nil, nil, "1" },        -- Darnassus
    [1443] = { 30, 40, "130" },        -- Desolace
    [1411] = { 1, 10, "1" },           -- Durotar
    [1445] = { 35, 45, "130" },        -- Dustwallow Marsh
    [1448] = { 48, 55, "205" },        -- Felwood
    [1444] = { 40, 50, "205 (330)" },  -- Feralas
    [1450] = { nil, nil, "205" },      -- Moonglade
    [1412] = { 1, 10, "1" },           -- Mulgore
    [1454] = { nil, nil, "1" },        -- Orgrimmar
    [1451] = { 55, 60, "330" },        -- Silithus
    [1442] = { 15, 27, "55" },         -- Stonetalon Mountains
    [1446] = { 40, 50, "205" },        -- Tanaris
    [1438] = { 1, 10, "1" },           -- Teldrassil
    [1413] = { 10, 25, "1" },          -- The Barrens
    [1441] = { 25, 35, "130" },        -- Thousand Needles
    [1456] = { nil, nil, "1" },        -- Thunder Bluff
    [1449] = { 48, 55, "205" },        -- Un'Goro Crater
    [1452] = { 55, 60, "330" },        -- Winterspring
    -- WoW Forever
    [2482] = { 60, 60 },               -- Hyjal
    [2521] = { 1, 12 },                -- Zephras Isle
    [2548] = { 35, 45 },               -- Riverglades
    [2652] = { 35, 45 },               -- Shen'dralas
}

--- "(35-45)" in the colour a quest of that level would have for you.
local function Range(e)
    local lo, hi = e[1], e[2]
    if not (lo and hi) then return nil end
    local me = UnitLevel("player") or 1
    local c
    if me < lo then
        c = GetQuestDifficultyColor and GetQuestDifficultyColor(lo)
    elseif me > hi then
        -- A zone wholly below you should not look yellow.
        c = GetQuestDifficultyColor and GetQuestDifficultyColor(hi - 2)
    else
        c = QuestDifficultyColors and QuestDifficultyColors["difficult"]
    end
    local text = lo == hi and ("(" .. hi .. ")") or ("(" .. lo .. "-" .. hi .. ")")
    if c then
        text = ("|cff%02x%02x%02x%s|r"):format(c.r * 255, c.g * 255, c.b * 255, text)
    end
    return text
end

-- The map writes the name of the zone under the mouse through its area
-- label; our version adds the range to it on the way.
local labelHooked = false
local function HookLabel()
    local wm = _G.WorldMapFrame
    if labelHooked or not (wm and wm.dataProviders) then return end
    local AREA = _G.MAP_AREA_LABEL_TYPE and _G.MAP_AREA_LABEL_TYPE.AREA_NAME
    for provider in next, wm.dataProviders do
        local label = provider.Label
        if label and label.SetLabel and AREA then
            labelHooked = true
            local SetLabel = label.SetLabel
            label.SetLabel = function(self, kind, name, description, ...)
                if kind == AREA and name and M.enabled and M.db.levels then
                    local map = self.dataProvider and self.dataProvider:GetMap()
                    if map and map.GetNormalizedCursorPosition then
                        local x, y = map:GetNormalizedCursorPosition()
                        local ok, info = pcall(C_Map.GetMapInfoAtPosition, map:GetMapID(), x, y)
                        local e = ok and info and info.mapID ~= map:GetMapID() and LEVELS[info.mapID]
                        if e then
                            local r = Range(e)
                            if r then name = name .. " " .. r end
                            if M.db.fishing and e[3] and not description then
                                description = L["Fishing"] .. ": " .. e[3]
                            end
                        end
                    end
                end
                return SetLabel(self, kind, name, description, ...)
            end
        end
    end
end

-- ---------------------------------------------------------------------------
-- Pins: zone crossings and flight masters, on zone maps
-- ---------------------------------------------------------------------------

local function Atlas(name)
    if C_Texture and C_Texture.GetAtlasInfo then
        local ok, info = pcall(C_Texture.GetAtlasInfo, name)
        if ok and info then return name end
    end
end

local ARROW = Atlas("Garr_LevelUpgradeArrow")
local TAXI = {
    A = Atlas("TaxiNode_Alliance"), H = Atlas("TaxiNode_Horde"), N = Atlas("TaxiNode_Neutral"),
}
local TAXI_FILE = "Interface\\TaxiFrame\\UI-Taxi-Icon-Green"
local FACTION_COLOR = { A = { 0.35, 0.62, 1 }, H = { 1, 0.35, 0.3 }, N = { 1, 0.82, 0.35 } }
local FACTION_NAME = { A = _G.FACTION_ALLIANCE or "Alliance", H = _G.FACTION_HORDE or "Horde", N = _G.FACTION_NEUTRAL or "Neutral" }

local pins = {}
local layer

local function Canvas()
    local wm = _G.WorldMapFrame
    return wm and wm.ScrollContainer and wm.ScrollContainer.Child
end

local function OnEnter(p)
    GameTooltip:SetOwner(p, "ANCHOR_RIGHT")
    if p.kind == "arrow" then
        GameTooltip:AddLine(L[p.name], 1, 0.82, 0)
        if p.note then GameTooltip:AddLine(L[p.note], 0.8, 0.8, 0.8, true) end
        GameTooltip:AddLine(L["Click: show this map"], 0.5, 0.8, 1)
    else
        local c = FACTION_COLOR[p.faction]
        GameTooltip:AddLine(L[p.name], 1, 0.82, 0)
        GameTooltip:AddDoubleLine(L["Flight master"], FACTION_NAME[p.faction], 1, 1, 1, c[1], c[2], c[3])
    end
    GameTooltip:Show()
end

local function OnClick(p, button)
    if p.kind ~= "arrow" or button ~= "LeftButton" or not p.dest then return end
    if InCombatLockdown and InCombatLockdown() then return end
    local wm = _G.WorldMapFrame
    if wm and wm.SetMapID then wm:SetMapID(p.dest) end
end

local function Pin(i)
    local p = pins[i]
    if p then return p end
    p = CreateFrame("Button", nil, layer)
    p:SetFrameLevel(layer:GetFrameLevel() + 2)
    p.tex = p:CreateTexture(nil, "OVERLAY")
    p.tex:SetAllPoints()
    p:SetScript("OnEnter", OnEnter)
    p:SetScript("OnLeave", GameTooltip_Hide)
    p:SetScript("OnClick", OnClick)
    p:RegisterForClicks("LeftButtonUp")
    pins[i] = p
    return p
end

local function Scale()
    local wm = _G.WorldMapFrame
    local s = wm and wm.GetCanvasScale and wm:GetCanvasScale() or 1
    return (s and s > 0) and s or 1
end

local function Rescale()
    if not layer then return end
    local size = M.db.size / Scale()
    for _, p in ipairs(pins) do
        if p:IsShown() then
            local s = p.kind == "arrow" and size * 1.15 or size
            p:SetSize(s, s)
        end
    end
end

function M:Refresh()
    local canvas = Canvas()
    if not canvas then return end
    if not layer then
        layer = CreateFrame("Frame", nil, canvas)
        layer:SetAllPoints(canvas)
        layer:SetFrameLevel(canvas:GetFrameLevel() + 31)
    end
    local wm = _G.WorldMapFrame
    local mapID = self.enabled and wm and wm:IsShown() and wm.GetMapID and wm:GetMapID()
    local w, h = canvas:GetSize()
    local n = 0
    if mapID and w and w > 0 then
        local db = self.db
        if db.arrows and ns.mapArrows and ns.mapArrows[mapID] then
            for _, a in ipairs(ns.mapArrows[mapID]) do
                n = n + 1
                local p = Pin(n)
                p.kind, p.name, p.note, p.dest = "arrow", a[5], a[6], a[3]
                if ARROW then p.tex:SetAtlas(ARROW) else p.tex:SetTexture("Interface\\Minimap\\MinimapArrow") end
                p.tex:SetRotation(a[4] or 0)
                p.tex:SetVertexColor(1, 1, 1)
                p:EnableMouse(true)
                p:ClearAllPoints()
                p:SetPoint("CENTER", layer, "TOPLEFT", a[1] / 100 * w, -a[2] / 100 * h)
                p:Show()
            end
        end
        if db.flights and ns.mapFlights and ns.mapFlights[mapID] then
            local own = UnitFactionGroup("player") == "Horde" and "H" or "A"
            for _, f in ipairs(ns.mapFlights[mapID]) do
                if not db.ownFaction or f[1] == "N" or f[1] == own then
                    n = n + 1
                    local p = Pin(n)
                    p.kind, p.name, p.faction, p.dest = "flight", f[4], f[1], nil
                    if TAXI[f[1]] then
                        p.tex:SetAtlas(TAXI[f[1]])
                        p.tex:SetVertexColor(1, 1, 1)
                    else
                        p.tex:SetTexture(TAXI_FILE)
                        local c = FACTION_COLOR[f[1]]
                        p.tex:SetVertexColor(c[1], c[2], c[3])
                    end
                    p.tex:SetRotation(0)
                    p:EnableMouse(true)
                    p:ClearAllPoints()
                    p:SetPoint("CENTER", layer, "TOPLEFT", f[2] / 100 * w, -f[3] / 100 * h)
                    p:Show()
                end
            end
        end
    end
    self.placed = n
    for i = n + 1, #pins do pins[i]:Hide() end
    Rescale()
end

-- ---------------------------------------------------------------------------
-- Hooks
-- ---------------------------------------------------------------------------

local hooked = false
local function Hook()
    local wm = _G.WorldMapFrame
    if not wm then return end
    HookLabel()
    if hooked then return end
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

M:On("ADDON_LOADED", function(name)
    if name == "Blizzard_WorldMap" then Hook() end
end)
M:On("PLAYER_ENTERING_WORLD", function() Hook() end)

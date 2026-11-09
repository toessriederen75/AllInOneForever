-- AllInOne: gathering map. Every herb, mining vein and treasure chest you
-- gather is noted with its place, and shown on the world map and the
-- minimap, so you see where in a zone to look again.
--
-- Data: one small table per zone map, place -> name. Account-wide, so all
-- your characters fill the same map. A node found again near a known one
-- (within about 15 yards) only counts up, it doesn't add a second pin.
--
-- Cost: the world map pins are placed when the map opens or changes. The
-- minimap pins are moved five times a second, only for the nodes of your
-- current zone that are near enough to show.

local ADDON, ns = ...
if ns.env then setfenv(1, ns.env) end
local AIO, L = ns.AIO, ns.L

if GetLocale() == "deDE" then
    L["Gathering map"]          = "Sammelkarte"
    L["Herbs, veins and chests you found, on the maps."] = "Gefundene Kräuter, Adern und Truhen auf den Karten."
    L["Every herb, mining vein and treasure chest you gather is noted with its place and shown on the world map and the minimap. Nodes always grow at the same places, so you see where to look again. All your characters fill the same map."] =
        "Jedes Kraut, jede Erzader und jede Schatztruhe, die du sammelst, wird mit dem Ort notiert und auf der Weltkarte und der Minikarte gezeigt. Vorkommen wachsen immer an denselben Stellen, so siehst du, wo du wieder suchen kannst. Alle deine Charaktere füllen dieselbe Karte."
    L["Herbs"]                  = "Kräuter"
    L["Mining veins"]           = "Erzadern"
    L["Treasure chests"]        = "Schatztruhen"
    L["On the world map"]       = "Auf der Weltkarte"
    L["On the minimap"]         = "Auf der Minikarte"
    L["Pin size"]               = "Grösse der Symbole"
    L["Herb"]                   = "Kraut"
    L["Mining vein"]            = "Erzader"
    L["Treasure chest"]         = "Schatztruhe"
    L["Found %d times"]         = "%d-mal gefunden"
    L["Gathering map: %d herbs, %d veins, %d chests in this zone, %d places in all."] =
        "Sammelkarte: %d Kräuter, %d Adern, %d Truhen in dieser Zone, %d Orte insgesamt."
    L["Gathering map: the places of this zone are forgotten."] = "Sammelkarte: Die Orte dieser Zone sind vergessen."
    L["Type /aio gather clear to forget the places of this zone."] =
        "Mit /aio gather clear vergisst du die Orte dieser Zone."
end

local M = AIO:NewModule("gather", {
    title    = L["Gathering map"],
    short    = L["Herbs, veins and chests you found, on the maps."],
    desc     = L["Every herb, mining vein and treasure chest you gather is noted with its place and shown on the world map and the minimap. Nodes always grow at the same places, so you see where to look again. All your characters fill the same map."],
    category = "maps",
    default  = true,
    defaults = { herb = true, ore = true, treasure = true, world = true, minimap = true, size = 14 },
    options  = {
        { type = "toggle", key = "herb", label = L["Herbs"] },
        { type = "toggle", key = "ore", label = L["Mining veins"] },
        { type = "toggle", key = "treasure", label = L["Treasure chests"] },
        { type = "toggle", key = "world", label = L["On the world map"] },
        { type = "toggle", key = "minimap", label = L["On the minimap"] },
        { type = "slider", key = "size", label = L["Pin size"], min = 10, max = 24, step = 1 },
    },
})

local DATA = ns.GatherData or { nodes = {}, icons = {}, spells = {} }
local KIND_LABEL = { herb = L["Herb"], ore = L["Mining vein"], treasure = L["Treasure chest"] }
local CHEST_ICON = "Interface\\Icons\\INV_Box_02"

-- Chests are opened with many different spells: known by their name.
local CHEST_WORDS = { "chest", "footlocker", "strongbox", "truhe", "fusskiste", "fußkiste", "schatulle" }
local ORE_WORDS = { " vein", " deposit", "ader", "vorkommen", "ablagerung" }

local MERGE_YARDS = 15

-- ---------------------------------------------------------------------------
-- Stored places: db.maps[mapID][place] = name, db.count[mapID][place] = n
-- place = x * 10000 rounded, times 10000, plus y * 10000 rounded.
-- ---------------------------------------------------------------------------

local function Pack(x, y)
    return math.floor(x * 10000 + 0.5) * 10000 + math.floor(y * 10000 + 0.5)
end

local function Unpack(place)
    return math.floor(place / 10000) / 10000, (place % 10000) / 10000
end

local function KindOf(name)
    local key = name:lower()
    local node = DATA.nodes[key]
    if node then return node.kind, node end
    local sparkle = AIO.modules.sparkle
    local learnt = sparkle and sparkle.db and sparkle.db.learnt
    if learnt and learnt[key] then return learnt[key] end
    for _, w in ipairs(CHEST_WORDS) do if key:find(w, 1, true) then return "treasure" end end
    for _, w in ipairs(ORE_WORDS) do if key:find(w, 1, true) then return "ore" end end
end

local function IconOf(name)
    local kind, node = KindOf(name)
    if node and node.item then
        local icon = C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(node.item)
            or (GetItemIcon and GetItemIcon(node.item))
        if icon then return icon, kind end
    end
    if kind == "treasure" then return CHEST_ICON, kind end
    return DATA.icons[kind] or CHEST_ICON, kind
end

local sizes = {}
--- Width and height of a zone map in yards (nil if unknown).
local function MapYards(mapID)
    local s = sizes[mapID]
    if s ~= nil then return s and s[1], s and s[2] end
    sizes[mapID] = false
    if C_Map and C_Map.GetMapWorldSize then
        local ok, w, h = pcall(C_Map.GetMapWorldSize, mapID)
        if ok and w and w > 0 and h and h > 0 then sizes[mapID] = { w, h } end
    end
    if not sizes[mapID] and C_Map and C_Map.GetWorldPosFromMapPos and CreateVector2D then
        local ok1, _, a = pcall(C_Map.GetWorldPosFromMapPos, mapID, CreateVector2D(0, 0))
        local ok2, _, b = pcall(C_Map.GetWorldPosFromMapPos, mapID, CreateVector2D(1, 1))
        if ok1 and ok2 and a and b then
            local ax, ay = a:GetXY()
            local bx, by = b:GetXY()
            -- World x runs north, y west; the map's width is the y span.
            local w, h = math.abs(ay - by), math.abs(ax - bx)
            if w > 0 and h > 0 then sizes[mapID] = { w, h } end
        end
    end
    s = sizes[mapID]
    return s and s[1], s and s[2]
end

local function PlayerSpot()
    if not (C_Map and C_Map.GetBestMapForUnit) then return end
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then return end
    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    if not pos then return end
    local x, y = pos:GetXY()
    if not x or (x == 0 and y == 0) then return end
    return mapID, x, y
end

local Refresh, RefreshMinimap

function M:Note(name)
    local mapID, x, y = PlayerSpot()
    if not mapID then return end
    local db = self.db
    db.maps = db.maps or {}
    db.count = db.count or {}
    local places = db.maps[mapID]
    if not places then places = {}; db.maps[mapID] = places end
    local counts = db.count[mapID]
    if not counts then counts = {}; db.count[mapID] = counts end
    -- Near a known place with the same name: count up only.
    local w, h = MapYards(mapID)
    for place, known in pairs(places) do
        if known == name then
            local px, py = Unpack(place)
            local dx, dy = (px - x) * (w or 1), (py - y) * (h or 1)
            local near = w and (dx * dx + dy * dy <= MERGE_YARDS * MERGE_YARDS)
                or (not w and math.abs(dx) < 0.005 and math.abs(dy) < 0.005)
            if near then
                counts[place] = (counts[place] or 1) + 1
                return
            end
        end
    end
    local place = Pack(x, y)
    while places[place] do place = place + 1 end   -- two kinds on one spot
    places[place] = name
    counts[place] = 1
    Refresh()
    RefreshMinimap(true)
end

local function Wanted(kind)
    return kind and M.db[kind]
end

-- ---------------------------------------------------------------------------
-- Pins on the world map
-- ---------------------------------------------------------------------------

local layer
local pins = {}

local function Canvas()
    local wm = _G.WorldMapFrame
    return wm and wm.ScrollContainer and wm.ScrollContainer.Child
end

local function PinTooltip(pin)
    GameTooltip:SetOwner(pin, "ANCHOR_RIGHT")
    GameTooltip:AddLine(pin.name, 1, 0.82, 0)
    GameTooltip:AddLine(KIND_LABEL[pin.kind] or "", 1, 1, 1)
    if pin.count and pin.count > 1 then
        GameTooltip:AddLine(L["Found %d times"]:format(pin.count), 0.7, 0.7, 0.7)
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
    p.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    p:EnableMouse(true)
    if p.SetPropagateMouseClicks then p:SetPropagateMouseClicks(true) end
    p:SetScript("OnEnter", PinTooltip)
    p:SetScript("OnLeave", GameTooltip_Hide)
    pins[i] = p
    return p
end

local function Rescale()
    if not layer then return end
    local wm = _G.WorldMapFrame
    local s = wm and wm.GetCanvasScale and wm:GetCanvasScale() or 1
    if not s or s <= 0 then s = 1 end
    local size = M.db.size / s
    for _, p in ipairs(pins) do
        if p:IsShown() then p:SetSize(size, size) end
    end
end

function Refresh()
    local canvas = Canvas()
    if not canvas then return end
    if not layer then
        layer = CreateFrame("Frame", nil, canvas)
        layer:SetAllPoints(canvas)
        layer:SetFrameLevel(canvas:GetFrameLevel() + 25)
    end
    local wm = _G.WorldMapFrame
    local mapID = M.enabled and M.db.world and wm and wm:IsShown() and wm.GetMapID and wm:GetMapID()
    local places = mapID and M.db.maps and M.db.maps[mapID]
    local counts = places and M.db.count and M.db.count[mapID]
    local w, h = canvas:GetSize()
    local n = 0
    if places and w and w > 0 then
        for place, name in pairs(places) do
            local icon, kind = IconOf(name)
            if Wanted(kind) then
                n = n + 1
                local p = Pin(n)
                local x, y = Unpack(place)
                p.name, p.kind, p.count = name, kind, counts and counts[place]
                p.tex:SetTexture(icon)
                p:ClearAllPoints()
                p:SetPoint("CENTER", layer, "TOPLEFT", x * w, -y * h)
                p:Show()
            end
        end
    end
    for i = n + 1, #pins do pins[i]:Hide() end
    M.placed = n
    Rescale()
end

local hooked = false
local function Hook()
    local wm = _G.WorldMapFrame
    if hooked or not wm then return end
    hooked = true
    wm:HookScript("OnShow", function() Refresh() end)
    if wm.OnMapChanged then hooksecurefunc(wm, "OnMapChanged", function() Refresh() end) end
    if wm.OnCanvasScaleChanged then hooksecurefunc(wm, "OnCanvasScaleChanged", Rescale) end
    if wm.ScrollContainer then wm.ScrollContainer:HookScript("OnSizeChanged", function() Refresh() end) end
end

-- ---------------------------------------------------------------------------
-- Pins on the minimap
-- ---------------------------------------------------------------------------

-- How many yards the minimap shows across, per zoom step.
local OUTDOOR = { [0] = 466 + 2 / 3, 400, 333 + 1 / 3, 266 + 2 / 3, 200, 133 + 1 / 3 }
local INDOOR  = { [0] = 300, 240, 180, 120, 80, 50 }

local mini = {}
local ticker
local zoneMap, zoneList   -- current zone and its nodes as { x, y, name, icon, kind }

local function MiniPin(i)
    local p = mini[i]
    if p then return p end
    p = CreateFrame("Frame", nil, Minimap)
    p:SetFrameLevel(Minimap:GetFrameLevel() + 5)
    p.tex = p:CreateTexture(nil, "OVERLAY")
    p.tex:SetAllPoints()
    p.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    p:EnableMouse(true)
    p:SetScript("OnEnter", PinTooltip)
    p:SetScript("OnLeave", GameTooltip_Hide)
    mini[i] = p
    return p
end

--- The nodes of the zone you are in, worked out again when the zone or the
--- data changes.
local function ZoneList(mapID, force)
    if mapID == zoneMap and not force then return zoneList end
    zoneMap, zoneList = mapID, {}
    local places = M.db.maps and M.db.maps[mapID]
    local counts = M.db.count and M.db.count[mapID]
    if places then
        for place, name in pairs(places) do
            local icon, kind = IconOf(name)
            if Wanted(kind) then
                local x, y = Unpack(place)
                zoneList[#zoneList + 1] = { x, y, name, icon, kind, counts and counts[place] }
            end
        end
    end
    return zoneList
end

local function PlaceMinimap()
    local n = 0
    local mapID, px, py = PlayerSpot()
    local w, h
    if mapID then w, h = MapYards(mapID) end
    if mapID and w then
        local list = ZoneList(mapID)
        local zoom = Minimap:GetZoom() or 0
        local across = ((IsIndoors and IsIndoors()) and INDOOR or OUTDOOR)[zoom] or 300
        local radius = Minimap:GetWidth() / 2
        local perYard = radius / (across / 2)
        local rotate = GetCVar("rotateMinimap") == "1"
        local f = rotate and GetPlayerFacing and GetPlayerFacing() or 0
        local cf, sf = math.cos(f), math.sin(f)
        local size = M.db.size - 2
        local limit = (radius - size / 2) * (radius - size / 2)
        for _, node in ipairs(list) do
            local dx, dy = (node[1] - px) * w, (node[2] - py) * h
            local sx, sy = dx * perYard, -dy * perYard
            if rotate then
                sx = (dx * cf - dy * sf) * perYard
                sy = -(dx * sf + dy * cf) * perYard
            end
            if sx * sx + sy * sy <= limit then
                n = n + 1
                local p = MiniPin(n)
                p.name, p.kind, p.count = node[3], node[5], node[6]
                p.tex:SetTexture(node[4])
                p:SetSize(size, size)
                p:ClearAllPoints()
                p:SetPoint("CENTER", Minimap, "CENTER", sx, sy)
                p:Show()
            end
        end
    end
    for i = n + 1, #mini do mini[i]:Hide() end
    M.onMinimap = n
end

function RefreshMinimap(force)
    if force then zoneMap = nil end
    local on = M.enabled and M.db.minimap and Minimap
    if on and not ticker and C_Timer and C_Timer.NewTicker then
        ticker = C_Timer.NewTicker(0.2, PlaceMinimap)
    elseif not on and ticker then
        ticker:Cancel()
        ticker = nil
    end
    if on then PlaceMinimap() else for _, p in ipairs(mini) do p:Hide() end end
end

-- ---------------------------------------------------------------------------
-- Noting what you gather
-- ---------------------------------------------------------------------------

M:On("UNIT_SPELLCAST_SENT", function(unit, target, _, spellID)
    if unit ~= "player" or type(target) ~= "string" or target == "" then return end
    if _G.issecretvalue and _G.issecretvalue(target) then return end
    local kind = DATA.spells[spellID]
    if not kind then
        kind = KindOf(target)
        if kind ~= "treasure" then return end
    end
    M:Note(target)
end)

function M:OnEnable()
    Hook()
    Refresh()
    RefreshMinimap(true)
end

function M:OnDisable()
    Refresh()
    RefreshMinimap(true)
end

function M:OnSettingChanged()
    Refresh()
    RefreshMinimap(true)
end

M:On("ADDON_LOADED", function(name)
    if name == "Blizzard_WorldMap" then Hook() end
end)
M:On("PLAYER_ENTERING_WORLD", function() Hook(); RefreshMinimap(true) end)
M:On("ZONE_CHANGED_NEW_AREA", function() RefreshMinimap(true) end)

-- ---------------------------------------------------------------------------
-- /aio gather: what is known here. /aio gather clear: forget this zone.
-- ---------------------------------------------------------------------------

M.slash = "gather"
function M:Slash(rest)
    local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    local maps = self.db.maps or {}
    if rest and rest:lower():match("^clear") then
        if mapID then
            maps[mapID] = nil
            if self.db.count then self.db.count[mapID] = nil end
        end
        Refresh()
        RefreshMinimap(true)
        self:Print(L["Gathering map: the places of this zone are forgotten."])
        return
    end
    local c = { herb = 0, ore = 0, treasure = 0 }
    for _, name in pairs(mapID and maps[mapID] or {}) do
        local kind = KindOf(name)
        if c[kind] then c[kind] = c[kind] + 1 end
    end
    local all = 0
    for _, places in pairs(maps) do for _ in pairs(places) do all = all + 1 end end
    self:Print(L["Gathering map: %d herbs, %d veins, %d chests in this zone, %d places in all."],
        c.herb, c.ore, c.treasure, all)
    self:Print(L["Type /aio gather clear to forget the places of this zone."])
end

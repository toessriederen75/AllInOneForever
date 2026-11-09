-- AllInOne: things you can gather light up in the world.
--
--  * Quest items: the game has its own glitter on objects you can loot for a
--    quest, but its "outline" graphics setting hides it. With this on, the
--    outline stays off and the glitter on.
--  * Herbs and veins: the game's soft targeting picks the node in front of
--    you. We put a golden glow on it with the icon of what it gives and its
--    name in the colour of how much skill-up it still brings (red: your
--    skill is too low).
--
-- Every game setting we change is noted first and put back as it was when
-- the option or the module is switched off.
--
-- Nodes are known by name: an own list (English and German) and every node
-- you gather yourself, so names missing from the list are learnt.
--
-- Cost: nothing runs on a timer. Work happens only when the soft target
-- changes (a handful of table look-ups) or a nameplate appears.

local ADDON, ns = ...
if ns.env then setfenv(1, ns.env) end
local AIO, L = ns.AIO, ns.L

if GetLocale() == "deDE" then
    L["Sparkles"]              = "Glitzern"
    L["Quest items, herbs and veins light up."] = "Questgegenstände, Kräuter und Erzadern leuchten."
    L["Objects you need for a quest glitter again, and the herb or vein in front of you gets a golden glow with what it gives and how much skill-up it still brings."] =
        "Gegenstände, die du für eine Quest brauchst, glitzern wieder, und das Kraut oder die Erzader vor dir bekommt einen goldenen Schein mit dem, was es gibt, und wie viel Fertigkeit es noch bringt."
    L["Quest items glitter"]   = "Questgegenstände glitzern"
    L["The game's own glitter on objects you can loot for a quest. The outline around objects under the mouse is switched off for it, because the game shows only one of the two."] =
        "Das Glitzern des Spiels auf Gegenständen, die du für eine Quest plündern kannst. Dafür wird der Umriss um Objekte unter der Maus ausgeschaltet, weil das Spiel nur eines von beiden zeigt."
    L["Glow on herbs"]         = "Schein auf Kräutern"
    L["Glow on mining veins"]  = "Schein auf Erzadern"
    L["Only for my professions"] = "Nur für meine Berufe"
    L["No glow on herbs without Herbalism and on veins without Mining."] =
        "Kein Schein auf Kräutern ohne Kräuterkunde und auf Adern ohne Bergbau."
    L["Show what it gives"]    = "Zeigen, was es gibt"
    L["Icon and name above the node; the name in the colour of the skill-up chance."] =
        "Symbol und Name über dem Vorkommen; der Name in der Farbe der Chance auf Fertigkeit."
    L["Reach (yards)"]         = "Reichweite (Meter)"
    L["Skill %d needed"]       = "Fertigkeit %d nötig"
    L["Sparkles: quest items %s, herbs %s, veins %s. Nodes learnt: %d."] =
        "Glitzern: Questgegenstände %s, Kräuter %s, Adern %s. Gelernte Vorkommen: %d."
    L["Search all around"]     = "Rundum suchen"
    L["Herbs and veins are found all around you, not only in front of you. The game's interact key then also reaches things beside and behind you."] =
        "Kräuter und Adern werden rund um dich gefunden, nicht nur vor dir. Die Interaktionstaste des Spiels erreicht dann auch Dinge neben und hinter dir."
    L["Notice when one is near"] = "Hinweis, wenn eines in der Nähe ist"
    L["A symbol in a fixed place on screen with the name of the herb or vein nearby. Hold Alt and drag it to move it."] =
        "Ein Symbol an fester Stelle auf dem Bildschirm mit dem Namen des Krauts oder der Ader in der Nähe. Mit gedrückter Alt-Taste verschiebst du es."
    L["Sound for the notice"]  = "Ton zum Hinweis"
    L["Mining vein nearby"]    = "Erzader in der Nähe"
    L["Herb nearby"]           = "Kraut in der Nähe"
    L["on"]                    = "an"
    L["off"]                   = "aus"
end

local M = AIO:NewModule("sparkle", {
    title    = L["Sparkles"],
    short    = L["Quest items, herbs and veins light up."],
    desc     = L["Objects you need for a quest glitter again, and the herb or vein in front of you gets a golden glow with what it gives and how much skill-up it still brings."],
    category = "display",
    default  = true,
    defaults = { quest = true, herb = true, ore = true, onlyMine = true, label = true, reach = 30,
                 around = true, alert = true, sound = true },
    options  = {
        { type = "toggle", key = "quest", label = L["Quest items glitter"],
          desc = L["The game's own glitter on objects you can loot for a quest. The outline around objects under the mouse is switched off for it, because the game shows only one of the two."] },
        { type = "toggle", key = "herb", label = L["Glow on herbs"] },
        { type = "toggle", key = "ore", label = L["Glow on mining veins"] },
        { type = "toggle", key = "onlyMine", label = L["Only for my professions"],
          desc = L["No glow on herbs without Herbalism and on veins without Mining."] },
        { type = "toggle", key = "label", label = L["Show what it gives"],
          desc = L["Icon and name above the node; the name in the colour of the skill-up chance."] },
        { type = "toggle", key = "around", label = L["Search all around"],
          desc = L["Herbs and veins are found all around you, not only in front of you. The game's interact key then also reaches things beside and behind you."] },
        { type = "toggle", key = "alert", label = L["Notice when one is near"],
          desc = L["A symbol in a fixed place on screen with the name of the herb or vein nearby. Hold Alt and drag it to move it."] },
        { type = "toggle", key = "sound", label = L["Sound for the notice"] },
        { type = "slider", key = "reach", label = L["Reach (yards)"], min = 10, max = 60, step = 5 },
    },
})

-- ---------------------------------------------------------------------------
-- Nodes: name -> kind, skill needed, item it gives
-- ---------------------------------------------------------------------------

local NODES = {}
local DE = GetLocale() == "deDE"
local function Add(kind, skill, item, ...)
    local node = { kind = kind, skill = skill, item = item, name = (DE and select(2, ...)) or (...) }
    for i = 1, select("#", ...) do NODES[(select(i, ...)):lower()] = node end
end

-- Herbs
Add("herb",   1,  2447, "Peacebloom", "Friedensblume")
Add("herb",   1,   765, "Silverleaf", "Silberblatt")
Add("herb",  15,  2449, "Earthroot", "Erdwurzel")
Add("herb",  50,   785, "Mageroyal", "Maguskönigskraut")
Add("herb",  70,  2450, "Briarthorn", "Wilddornrose")
Add("herb",  85,  3820, "Stranglekelp", "Würgetang")
Add("herb", 100,  2453, "Bruiseweed", "Beulengras")
Add("herb", 115,  3355, "Wild Steelbloom", "Wildstahlblume")
Add("herb", 120,  3369, "Grave Moss", "Grabmoos")
Add("herb", 125,  3356, "Kingsblood", "Königsblut")
Add("herb", 150,  3357, "Liferoot", "Lebenswurz")
Add("herb", 160,  3818, "Fadeleaf", "Blassblatt")
Add("herb", 170,  3821, "Goldthorn", "Golddorn")
Add("herb", 185,  3358, "Khadgar's Whisker", "Khadgars Schnurrbart")
Add("herb", 195,  3819, "Wintersbite", "Winterbiss")
Add("herb", 205,  4625, "Firebloom", "Feuerblüte")
Add("herb", 210,  8831, "Purple Lotus", "Lila Lotus")
Add("herb", 220,  8836, "Arthas' Tears", "Arthas' Tränen")
Add("herb", 230,  8838, "Sungrass", "Sonnengras")
Add("herb", 235,  8839, "Blindweed", "Blindkraut")
Add("herb", 245,  8845, "Ghost Mushroom", "Geisterpilz")
Add("herb", 250,  8846, "Gromsblood", "Gromsblut")
Add("herb", 260, 13464, "Golden Sansam", "Goldener Sansam")
Add("herb", 270, 13463, "Dreamfoil", "Traumblatt")
Add("herb", 280, 13465, "Mountain Silversage", "Bergsilbersalbei")
Add("herb", 285, 13466, "Plaguebloom", "Pestblüte")
Add("herb", 290, 13467, "Icecap", "Eiskappe")
Add("herb", 300, 13468, "Black Lotus", "Schwarzer Lotus")

-- Mining
Add("ore",   1,  2770, "Copper Vein", "Kupfervorkommen", "Kupferader")
Add("ore",  65,  2771, "Tin Vein", "Zinnvorkommen", "Zinnader")
Add("ore",  65,  3340, "Incendicite Mineral Vein", "Pyrophormineralvorkommen")
Add("ore",  75,  2775, "Silver Vein", "Silbervorkommen", "Silberader", "Ooze Covered Silver Vein", "Schlammbedecktes Silbervorkommen", "Schlammbedeckte Silberader")
Add("ore",  75,  4278, "Lesser Bloodstone Deposit", "Geringes Blutsteinvorkommen", "Geringe Blutsteinablagerung")
Add("ore", 125,  2772, "Iron Deposit", "Eisenvorkommen")
Add("ore", 150,  5833, "Indurium Mineral Vein", "Induriummineralvorkommen")
Add("ore", 155,  2776, "Gold Vein", "Goldvorkommen", "Goldader", "Ooze Covered Gold Vein", "Schlammbedecktes Goldvorkommen", "Schlammbedeckte Goldader")
Add("ore", 175,  3858, "Mithril Deposit", "Mithrilvorkommen", "Mithrilablagerung", "Ooze Covered Mithril Deposit", "Schlammbedecktes Mithrilvorkommen", "Schlammbedeckte Mithrilablagerung")
Add("ore", 230,  7911, "Truesilver Deposit", "Echtsilbervorkommen", "Echtsilberablagerung", "Ooze Covered Truesilver Deposit", "Schlammbedecktes Echtsilbervorkommen", "Schlammbedeckte Echtsilberablagerung")
Add("ore", 230, 11370, "Dark Iron Deposit", "Dunkeleisenvorkommen", "Dunkeleisenablagerung")
Add("ore", 245, 10620, "Small Thorium Vein", "Kleines Thoriumvorkommen", "Kleine Thoriumader", "Ooze Covered Thorium Vein", "Schlammbedecktes Thoriumvorkommen", "Schlammbedeckte Thoriumader")
Add("ore", 275, 10620, "Rich Thorium Vein", "Reiches Thoriumvorkommen", "Reiche Thoriumader", "Schlammbedecktes reiches Thoriumvorkommen", "Hakkari-Thoriumvorkommen", "Ooze Covered Rich Thorium Vein", "Schlammbedeckte reiche Thoriumader", "Hakkari Thorium Vein", "Hakkari-Thoriumader")
Add("ore", 305, 22202, "Small Obsidian Chunk", "Kleiner Obsidianbrocken", "Large Obsidian Chunk", "Großer Obsidianbrocken", "Grosser Obsidianbrocken")

-- A vein missing from the list is still known by its name.
local ORE_WORDS = { " vein", " deposit", "ader", "vorkommen", "ablagerung", "obsidianbrocken" }

local ICON = {
    herb = "Interface\\Icons\\INV_Misc_Herb_07",
    ore  = "Interface\\Icons\\INV_Ore_Copper_01",
}

-- The gathering spells (all ranks), to learn the node you just gathered.
local GATHER_SPELL = {
    [2366] = "herb", [2368] = "herb", [3570] = "herb", [11993] = "herb",
    [2575] = "ore",  [2576] = "ore",  [3564] = "ore",  [10248] = "ore",
}
local SKILL_NAMES = {
    herb = { ["herbalism"] = true, ["kräuterkunde"] = true },
    ore  = { ["mining"] = true, ["bergbau"] = true },
}
local SKILL_LINE = { herb = 182, ore = 186 }

-- The same nodes by their object ID (part of the GUID), for when the game
-- hands out no readable name.
local OBJECTS = {}
local function Obj(name, ...)
    local node = NODES[name:lower()]
    for i = 1, select("#", ...) do OBJECTS[(select(i, ...))] = node end
end
Obj("Peacebloom", 1618, 3724)
Obj("Silverleaf", 1617, 3725)
Obj("Earthroot", 1619, 3726)
Obj("Mageroyal", 1620, 3727)
Obj("Briarthorn", 1621, 3729)
Obj("Bruiseweed", 1622, 3730)
Obj("Stranglekelp", 2045)
Obj("Wild Steelbloom", 1623)
Obj("Grave Moss", 1628)
Obj("Kingsblood", 1624)
Obj("Liferoot", 2041)
Obj("Fadeleaf", 2042)
Obj("Goldthorn", 2046)
Obj("Khadgar's Whisker", 2043)
Obj("Wintersbite", 2044)
Obj("Firebloom", 2866)
Obj("Purple Lotus", 142140)
Obj("Arthas' Tears", 142141)
Obj("Sungrass", 142142)
Obj("Blindweed", 142143)
Obj("Ghost Mushroom", 142144)
Obj("Gromsblood", 142145)
Obj("Golden Sansam", 176583)
Obj("Dreamfoil", 176584)
Obj("Mountain Silversage", 176586)
Obj("Plaguebloom", 176587)
Obj("Icecap", 176588)
Obj("Black Lotus", 176589)
Obj("Copper Vein", 1731)
Obj("Tin Vein", 1732)
Obj("Silver Vein", 1733, 73940)
Obj("Gold Vein", 1734, 73941)
Obj("Iron Deposit", 1735)
Obj("Incendicite Mineral Vein", 1610, 1667)
Obj("Lesser Bloodstone Deposit", 2653)
Obj("Indurium Mineral Vein", 19903)
Obj("Mithril Deposit", 2040, 123310)
Obj("Truesilver Deposit", 2047, 123309)
Obj("Dark Iron Deposit", 165658)
Obj("Small Thorium Vein", 324, 123848)
Obj("Rich Thorium Vein", 175404, 177388)

-- Shared with the gathering map (Gather.lua).
ns.GatherData = { nodes = NODES, icons = ICON, spells = GATHER_SPELL }

local function Readable(v)
    return v ~= nil and not (_G.issecretvalue and _G.issecretvalue(v))
end

local function Learnt()
    local db = M.db
    db.learnt = db.learnt or {}
    return db.learnt
end

local function ObjectID(guid)
    if not Readable(guid) or type(guid) ~= "string" then return nil end
    local kind, id = guid:match("^(%a+)%-%d+%-%d+%-%d+%-%d+%-(%d+)")
    if kind == "GameObject" then return tonumber(id) end
end

local function NodeFor(name, guid)
    local id = ObjectID(guid)
    if id and OBJECTS[id] then return OBJECTS[id] end
    if not Readable(name) or type(name) ~= "string" or name == "" then return nil end
    local key = name:lower()
    local node = NODES[key]
    if node then return node end
    local kind = Learnt()[key]
    if not kind then
        for _, w in ipairs(ORE_WORDS) do
            if key:find(w, 1, true) then kind = "ore" break end
        end
    end
    if kind then return { kind = kind } end
end

--- Your skill in the profession for this kind of node, or nil without it.
local function Skill(kind)
    if GetNumSkillLines and GetSkillLineInfo then
        local names = SKILL_NAMES[kind]
        for i = 1, GetNumSkillLines() do
            local name, header, _, rank = GetSkillLineInfo(i)
            if not header and name and names[name:lower()] then return rank end
        end
    end
    if GetProfessions and GetProfessionInfo then
        local list = { GetProfessions() }
        for i = 1, 6 do
            local idx = list[i]
            if idx then
                local ok, _, _, rank, _, _, _, line = pcall(GetProfessionInfo, idx)
                if ok and line == SKILL_LINE[kind] then return rank end
            end
        end
    end
end

--- Colour of the name: red too low, then orange, yellow, green, grey.
local function SkillColor(rank, need)
    if not (rank and need) then return 1, 0.82, 0 end
    if rank < need then return 1, 0.25, 0.25 end
    if rank < need + 25 then return 1, 0.5, 0.25 end
    if rank < need + 50 then return 1, 1, 0 end
    if rank < need + 100 then return 0.25, 0.75, 0.25 end
    return 0.6, 0.6, 0.6
end

local function ItemIcon(id)
    if not id then return nil end
    if C_Item and C_Item.GetItemIconByID then return C_Item.GetItemIconByID(id) end
    if GetItemIcon then return GetItemIcon(id) end
end

-- ---------------------------------------------------------------------------
-- Game settings, noted before we change them
-- ---------------------------------------------------------------------------

local function GetCV(name)
    local get = (C_CVar and C_CVar.GetCVar) or GetCVar
    local ok, v = pcall(get, name)
    if ok then return v end
end

local busy = false   -- our own changes, so CVAR_UPDATE ignores them
local function SetCV(name, value)
    local set = (C_CVar and C_CVar.SetCVar) or SetCVar
    busy = true
    pcall(set, name, tostring(value))
    busy = false
end

local QUEST_CVARS = {
    graphicsOutlineMode = "0",
    raidGraphicsOutlineMode = "0",
    outlineModeShowLootEffectWhenDisabled = "1",
}
local PLATE_CVAR = "SoftTargetNameplateInteract"

local function SoftCVars()
    return {
        SoftTargetInteract = "3",
        SoftTargetInteractRange = tostring(M.db.reach or 30),
        SoftTargetInteractArc = M.db.around and "2" or "1",
    }
end

--- Sets `list` while `on`, otherwise puts back what was there before.
local function Use(list, on)
    local saved = M.db.saved
    for name, value in pairs(list) do
        local now = GetCV(name)
        if on then
            if now ~= nil then
                if saved[name] == nil then saved[name] = now end
                if now ~= value then SetCV(name, value) end
            end
        elseif saved[name] ~= nil then
            if now ~= saved[name] then SetCV(name, saved[name]) end
            saved[name] = nil
        end
    end
end

-- ---------------------------------------------------------------------------
-- The glow
-- ---------------------------------------------------------------------------

local glow

local function Spin(tex, degrees, seconds)
    local ag = tex:CreateAnimationGroup()
    ag:SetLooping("REPEAT")
    local r = ag:CreateAnimation("Rotation")
    r:SetDegrees(degrees)
    r:SetDuration(seconds)
    return ag
end

local function Pulse(tex, from, to, seconds)
    local ag = tex:CreateAnimationGroup()
    ag:SetLooping("BOUNCE")
    local a = ag:CreateAnimation("Alpha")
    a:SetFromAlpha(from)
    a:SetToAlpha(to)
    a:SetDuration(seconds)
    a:SetSmoothing("IN_OUT")
    return ag
end

local function Glow()
    if glow then return glow end
    local f = CreateFrame("Frame", "AllInOneSparkle", UIParent)
    f:SetSize(70, 70)
    f:SetFrameStrata("LOW")
    f:EnableMouse(false)
    f.anims = {}

    local burst = f:CreateTexture(nil, "BACKGROUND")
    burst:SetTexture("Interface\\Cooldown\\starburst")
    burst:SetBlendMode("ADD")
    burst:SetAllPoints()
    f.burst = burst
    f.anims[#f.anims + 1] = Spin(burst, -360, 9)
    f.anims[#f.anims + 1] = Pulse(burst, 0.35, 0.8, 1.1)

    local star = f:CreateTexture(nil, "ARTWORK")
    star:SetTexture("Interface\\Cooldown\\star4")
    star:SetBlendMode("ADD")
    star:SetSize(34, 34)
    star:SetPoint("CENTER")
    f.star = star
    f.anims[#f.anims + 1] = Spin(star, 360, 4)
    f.anims[#f.anims + 1] = Pulse(star, 0.5, 1, 0.7)

    local icon = f:CreateTexture(nil, "OVERLAY")
    icon:SetSize(20, 20)
    icon:SetPoint("BOTTOM", f, "TOP", 0, -6)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    f.icon = icon

    local text = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("BOTTOM", icon, "TOP", 0, 2)
    f.text = text

    f:Hide()
    f:SetScript("OnShow", function(self) for _, ag in ipairs(self.anims) do ag:Play() end end)
    f:SetScript("OnHide", function(self) for _, ag in ipairs(self.anims) do ag:Stop() end end)
    glow = f
    return f
end

-- ---------------------------------------------------------------------------
-- Following the soft target
-- ---------------------------------------------------------------------------

local current, current_name   -- node in front of you and its name
local plateOn = false          -- we switched the interact nameplate on
local tries = 0

local function PlateCVar(on)
    if plateOn == on then return end
    if InCombatLockdown() then M.pending = true return end
    Use({ [PLATE_CVAR] = "1" }, on)
    plateOn = on
end

local alert, alerted

local function Alert()
    if alert then return alert end
    local f = CreateFrame("Frame", "AllInOneSparkleAlert", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    f:SetSize(220, 42)
    f:SetFrameStrata("MEDIUM")
    f:SetClampedToScreen(true)
    if f.SetBackdrop then
        f:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                        edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
        f:SetBackdropColor(0.05, 0.05, 0.05, 0.75)
        f:SetBackdropBorderColor(1, 0.82, 0.3, 0.9)
    end
    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetSize(30, 30)
    f.icon:SetPoint("LEFT", 6, 0)
    f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    f.name = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.name:SetPoint("TOPLEFT", f.icon, "TOPRIGHT", 8, -1)
    f.name:SetPoint("RIGHT", -8, 0)
    f.name:SetJustifyH("LEFT")
    f.sub = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.sub:SetPoint("BOTTOMLEFT", f.icon, "BOTTOMRIGHT", 8, 1)
    f.sub:SetPoint("RIGHT", -8, 0)
    f.sub:SetJustifyH("LEFT")
    -- A soft pulse on the icon, so it catches the eye.
    local ag = f.icon:CreateAnimationGroup()
    ag:SetLooping("BOUNCE")
    local a = ag:CreateAnimation("Alpha")
    a:SetFromAlpha(1)
    a:SetToAlpha(0.45)
    a:SetDuration(0.6)
    f.pulse = ag
    -- Alt + drag moves it.
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self) if IsAltKeyDown() then self:StartMoving() end end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, rel, x, y = self:GetPoint(1)
        M.db.alertPos = { point, rel, x, y }
    end)
    local pos = M.db.alertPos
    if pos then f:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4])
    else f:SetPoint("CENTER", UIParent, "CENTER", 0, 180) end
    f:SetScript("OnShow", function(self) self.pulse:Play() end)
    f:SetScript("OnHide", function(self) self.pulse:Stop() end)
    f:Hide()
    alert = f
    return f
end

local function ShowAlert(node, name)
    if not M.db.alert then if alert then alert:Hide() end return end
    local f = Alert()
    local rank = Skill(node.kind)
    local low = rank and node.skill and rank < node.skill
    f.icon:SetTexture(ItemIcon(node.item) or ICON[node.kind])
    f.icon:SetDesaturated(low and true or false)
    f.name:SetText(name or "")
    f.name:SetTextColor(SkillColor(rank, node.skill))
    if low then
        f.sub:SetText(L["Skill %d needed"]:format(node.skill))
        f.sub:SetTextColor(1, 0.3, 0.3)
    else
        f.sub:SetText(node.kind == "ore" and L["Mining vein nearby"] or L["Herb nearby"])
        f.sub:SetTextColor(0.85, 0.85, 0.85)
    end
    f:Show()
    if M.db.sound and alerted ~= name then
        PlaySound(SOUNDKIT and SOUNDKIT.MAP_PING or 3175, "Master")
    end
    alerted = name
end

local function HideGlow()
    if glow then glow:Hide() end
    if alert then alert:Hide() end
    alerted = nil
    current, current_name = nil, nil
    PlateCVar(false)
end

local function Same(unit, guid)
    if UnitIsUnit then
        local ok, same = pcall(UnitIsUnit, unit, "softinteract")
        if ok and same == true then return true end
    end
    if guid then
        local g = UnitGUID(unit)
        return Readable(g) and g == guid
    end
end

--- The nameplate the game puts on the node in front of you.
local seenPlate, seenUnit      -- the node's nameplate, from NAME_PLATE_UNIT_ADDED
local plateLog = {}            -- last nameplates that came up, for /aio sparkle

local function FindPlate()
    if not C_NamePlate then return nil end
    if seenPlate and seenUnit and Same(seenUnit, UnitGUID("softinteract")) then return seenPlate end
    if C_NamePlate.GetNamePlateForUnit then
        local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, "softinteract")
        if ok and plate then return plate end
    end
    if C_NamePlate.GetNamePlates then
        local guid = UnitGUID("softinteract")
        if not Readable(guid) then guid = nil end
        for _, plate in ipairs(C_NamePlate.GetNamePlates() or {}) do
            local unit = plate.namePlateUnitToken or (plate.UnitFrame and plate.UnitFrame.unit)
            if unit and Same(unit, guid) then return plate end
        end
    end
end

local Place
function Place()
    if not current then return end
    local plate = FindPlate()
    local f = Glow()
    if not plate then
        -- The nameplate turns up a moment after the setting is on.
        tries = tries + 1
        f:Hide()
        if tries <= 8 and C_Timer then
            local node = current
            C_Timer.After(0.1, function() if current == node then Place() end end)
        end
        -- Without a nameplate the notice alone tells about the node.
        return
    end
    tries = 0
    M.lastPlate = plate and true or false
    local node = current
    local rank = Skill(node.kind)
    local low = rank and node.skill and rank < node.skill
    if low then
        f.burst:SetVertexColor(1, 0.3, 0.25)
        f.star:SetVertexColor(1, 0.45, 0.4)
    else
        f.burst:SetVertexColor(1, 0.8, 0.3)
        f.star:SetVertexColor(1, 0.95, 0.6)
    end
    if M.db.label then
        f.icon:SetTexture(ItemIcon(node.item) or ICON[node.kind])
        f.icon:SetDesaturated(low and true or false)
        f.icon:Show()
        local label = current_name or ""
        if low then label = label .. " – " .. L["Skill %d needed"]:format(node.skill) end
        f.text:SetText(label)
        f.text:SetTextColor(SkillColor(rank, node.skill))
        f.text:Show()
    else
        f.icon:Hide()
        f.text:Hide()
    end
    f:ClearAllPoints()
    f:SetPoint("BOTTOM", plate, "TOP", 0, -12)
    f:Show()
end

function M:Update()
    if not (self.enabled and (self.db.herb or self.db.ore)) then HideGlow() return end
    local name = UnitName("softinteract")
    local guid = UnitGUID("softinteract")
    local node = NodeFor(name, guid)
    if not (Readable(name) and type(name) == "string" and name ~= "") then
        name = node and node.name
    end
    if not node or not self.db[node.kind] then HideGlow() return end
    if self.db.onlyMine and not Skill(node.kind) then HideGlow() return end
    current, current_name, tries = node, name, 0
    ShowAlert(node, name)
    PlateCVar(true)
    Place()
end

-- ---------------------------------------------------------------------------
-- Switching
-- ---------------------------------------------------------------------------

function M:Apply()
    if InCombatLockdown() then self.pending = true return end
    self.pending = nil
    self.db.saved = self.db.saved or {}
    local on = self.enabled
    Use(QUEST_CVARS, on and self.db.quest)
    Use(SoftCVars(), on and (self.db.herb or self.db.ore))
    self:Update()
end

function M:OnEnable()
    self:Apply()
end

function M:OnDisable()
    HideGlow()
    self:Apply()
end

function M:OnSettingChanged()
    self:Apply()
end

M:On("PLAYER_SOFT_INTERACT_CHANGED", function() M:Update() end)

M:On("NAME_PLATE_UNIT_ADDED", function(unit)
    local guid = UnitGUID("softinteract")
    if not Readable(guid) then guid = nil end
    local mine = unit == "softinteract" or Same(unit, guid)
    local g = UnitGUID(unit)
    table.insert(plateLog, 1, ("%s:%s%s"):format(tostring(unit),
        Readable(g) and tostring(g):match("^%a+") or "?", mine and "*" or ""))
    plateLog[6] = nil
    if mine then
        local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
        if ok and plate then seenPlate, seenUnit = plate, unit end
        if current then tries = 0; Place() end
    end
end)

M:On("NAME_PLATE_UNIT_REMOVED", function(unit)
    if unit == seenUnit then seenPlate, seenUnit = nil, nil end
end)

M:On("PLAYER_REGEN_ENABLED", function()
    if M.pending then M:Apply() end
end)

M:On("PLAYER_ENTERING_WORLD", function()
    if C_Timer then C_Timer.After(1, function() if M.enabled then M:Apply() end end) else M:Apply() end
end)

-- A graphics preset turns the outline back on: put the glitter back.
M:On("CVAR_UPDATE", function(name)
    if busy or type(name) ~= "string" or not M.db.quest then return end
    local n = name:lower()
    if n:find("outline", 1, true) or n:find("graphicsquality", 1, true) then
        if C_Timer and not M.queued then
            M.queued = true
            C_Timer.After(1, function()
                M.queued = nil
                if M.enabled and M.db.quest and not InCombatLockdown() then
                    for cvar, value in pairs(QUEST_CVARS) do
                        if GetCV(cvar) ~= value then SetCV(cvar, value) end
                    end
                end
            end)
        end
    end
end)

-- Learn the name of every node you gather, so names missing from our list
-- light up from the next one on.
M:On("UNIT_SPELLCAST_SENT", function(unit, target, _, spellID)
    if unit ~= "player" then return end
    local kind = GATHER_SPELL[spellID]
    if not kind or not Readable(target) or type(target) ~= "string" or target == "" then return end
    local key = target:lower()
    if not NODES[key] then Learnt()[key] = kind end
end)

-- ---------------------------------------------------------------------------
-- /aio sparkle: what is switched on
-- ---------------------------------------------------------------------------

M.slash = "sparkle"
function M:Slash()
    local function s(v) return v and L["on"] or L["off"] end
    local n = 0
    for _ in pairs(Learnt()) do n = n + 1 end
    self:Print(L["Sparkles: quest items %s, herbs %s, veins %s. Nodes learnt: %d."],
        s(self.db.quest), s(self.db.herb), s(self.db.ore), n)
    -- What the module sees right now (stand in front of a node and type it).
    local name, guid = UnitName("softinteract"), UnitGUID("softinteract")
    local node = NodeFor(name, guid)
    self:Print(("Soft target: name=%s guid=%s node=%s skill=%s/%s plate=%s showing=%s cvars: interact=%s plate=%s"):format(
        Readable(name) and tostring(name) or "secret", Readable(guid) and tostring(guid) or "secret",
        node and node.kind or "-", tostring(node and Skill(node.kind)), tostring(node and node.skill),
        tostring(FindPlate() ~= nil), tostring(glow and glow:IsShown() or false),
        tostring(GetCV("SoftTargetInteract")), tostring(GetCV(PLATE_CVAR))))
    local n, nf = 0, 0
    if C_NamePlate and C_NamePlate.GetNamePlates then
        n = #(C_NamePlate.GetNamePlates() or {})
        local ok, all = pcall(C_NamePlate.GetNamePlates, true)
        nf = ok and all and #all or 0
    end
    self:Print(("Nameplates: %d (with forbidden %d). Last ones up: %s"):format(n, nf,
        #plateLog > 0 and table.concat(plateLog, ", ") or "none"))
end

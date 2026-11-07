-- AllInOne: a glow on items you have just got (looted, bought, traded,
-- from the mail). The first time you open your bags afterwards, every new
-- item except junk shines, as in Blizzard's own bags. Pointing at an item or
-- closing the bags takes the glow away. Can be switched off (Bags & Bank >
-- General > Items).
--
-- How: clients that keep track of new items themselves (WoW Forever, like
-- Retail: C_NewItems) are asked directly. Elsewhere, what lies in every slot
-- of your bags (item and count) is noted at login and each time the bag
-- window closes; a slot whose item differs from that note, or whose stack
-- grew, holds something new. Nothing runs while the bags are closed; the
-- check happens while a slot is painted anyway.

local ADDON, ns = ...
if ns.env then setfenv(1, ns.env) end
local AIO, L = ns.AIO, ns.L

if GetLocale() == "deDE" then
    L["Glow on new items"] = "Leuchten bei neuen Gegenständen"
    L["Items you have just got shine the first time you open your bags. Not junk."] =
        "Gegenstände, die du gerade bekommen hast, leuchten beim ersten Öffnen der Taschen. Kein Schrott."
end

AIO.defaults.newGlow = true

local CLASS_QUEST = 12
-- The game's own list of new items, where there is one.
local CNI = C_NewItems and C_NewItems.IsNewItem and C_NewItems

-- What each slot held when you last looked: seen[bag][slot] = itemID,
-- seenCount[bag][slot] = stack size. A bag without a note yet gets one the
-- first time it is painted (and shows nothing new then).
local seen, seenCount = {}, {}

local function Note(bag)
    local ids, counts = seen[bag] or {}, seenCount[bag] or {}
    wipe(ids); wipe(counts)
    for slot = 1, AIO.NumSlots(bag) do
        local info = AIO.SlotInfo(bag, slot)
        if info then
            ids[slot] = info.itemID or AIO.ItemID(info.hyperlink) or 0
            counts[slot] = info.stackCount or 1
        end
    end
    seen[bag], seenCount[bag] = ids, counts
end

local function NoteAll()
    for _, bag in ipairs(AIO:InventoryBags()) do
        if AIO.NumSlots(bag) > 0 then Note(bag) end
    end
end

local function IsNew(bag, slot, info)
    if CNI then
        local ok, new = pcall(CNI.IsNewItem, bag, slot)
        return ok and new and true or false
    end
    local ids = seen[bag]
    if not ids then return false end
    local id = info.itemID or AIO.ItemID(info.hyperlink) or 0
    if ids[slot] ~= id then return true end
    return (info.stackCount or 1) > (seenCount[bag][slot] or 0)
end

local function Wanted(info)
    return info.quality ~= 0                              -- not junk
end

-- ---------------------------------------------------------------------------
-- The glow
-- ---------------------------------------------------------------------------

local ATLAS
if C_Texture and C_Texture.GetAtlasInfo then
    local ok, info = pcall(C_Texture.GetAtlasInfo, "bags-glow-white")
    if ok and info then ATLAS = "bags-glow-white" end
end

--- Pointing at a glowing item: it counts as seen.
local function Seen(b)
    local g = b.aioNew
    if not (g and g:IsShown()) then return end
    if CNI and CNI.RemoveNewItem then pcall(CNI.RemoveNewItem, b.bag, b.slot) end
    local info = AIO.SlotInfo(b.bag, b.slot)
    local ids = seen[b.bag]
    if ids and info then
        ids[b.slot] = info.itemID or AIO.ItemID(info.hyperlink) or 0
        seenCount[b.bag][b.slot] = info.stackCount or 1
    end
    g.pulse:Stop()
    g:Hide()
end

local function Glow(b)
    local g = b.aioNew
    if g then return g end
    g = b:CreateTexture(nil, "OVERLAY", nil, 1)
    if ATLAS then
        g:SetAtlas(ATLAS)
        g:SetAllPoints()
    else
        -- The old item glow: a soft ring, wider than the slot.
        g:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        g:SetPoint("CENTER")
        local s = AIO.SIZE * 1.8
        g:SetSize(s, s)
    end
    g:SetBlendMode("ADD")
    g:Hide()
    local pulse = g:CreateAnimationGroup()
    local a = pulse:CreateAnimation("Alpha")
    a:SetFromAlpha(1)
    a:SetToAlpha(0.35)
    a:SetDuration(0.8)
    pulse:SetLooping("BOUNCE")
    g.pulse = pulse
    b.aioNew = g
    b:HookScript("OnEnter", Seen)
    return g
end

local function Hide(b)
    local g = b.aioNew
    if g and g:IsShown() then g.pulse:Stop(); g:Hide() end
end

-- Closing the bags: everything in them has been seen. Hooked the first time
-- a slot of the bag window is painted (the window is made after this file).
local hooked = false
local function HookWindow()
    local w = AIO.windows and AIO.windows.inventory
    if hooked or not w then return end
    hooked = true
    w:HookScript("OnHide", function(self)
        if self.owner and self.owner ~= AIO.player then return end
        if CNI and CNI.ClearAll then pcall(CNI.ClearAll) end
        NoteAll()
        for _, slots in pairs(self.live or {}) do
            for _, b in pairs(slots) do Hide(b) end
        end
    end)
end

-- Every live slot is painted here; the glow is decided on the way.
local PaintLive = AIO.PaintLive
function AIO:PaintLive(b)
    if not hooked then HookWindow() end
    local info = PaintLive(self, b)
    if not self:IsInventoryBag(b.bag) or b.bag == self.KEYRING or not self.settings.newGlow then
        Hide(b)
        return info
    end
    if not seen[b.bag] then Note(b.bag) end
    if info and IsNew(b.bag, b.slot, info) and Wanted(info) then
        local g = Glow(b)
        local class = self:ItemClassLevel(info.hyperlink)
        if class == CLASS_QUEST then
            g:SetVertexColor(1, 0.82, 0)
        else
            local r, gr, bl = self.QualityColor(info.quality or 1)
            g:SetVertexColor(r or 1, gr or 1, bl or 1)
        end
        if not g:IsShown() then
            g:Show()
            g.pulse:Play()
        end
    else
        Hide(b)
    end
    return info
end

-- ---------------------------------------------------------------------------
-- Noting what is there
-- ---------------------------------------------------------------------------

AIO:On("PLAYER_LOGIN", function()
    if not CNI then NoteAll() end
    HookWindow()
end)

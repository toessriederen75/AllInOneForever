-- AllInOne: "Well Fed" reminder. One large icon of its own that glows red
-- while you are not well fed, and shows the time left while you are (warns
-- in yellow when it runs out soon). Alt + drag moves it.
--
-- Cost: an aura look-up when your buffs change; while the icon is shown a
-- countdown once a second, nothing else.

local ADDON, ns = ...
if ns.env then setfenv(1, ns.env) end
local AIO, L = ns.AIO, ns.L
local Style = AIO.Style
local C = Style.color

if GetLocale() == "deDE" then
    L["Well Fed reminder"]      = "Satt-Erinnerung"
    L["A large icon so you don't forget your buff food."] = "Ein grosses Symbol, damit du dein Bufffood nicht vergisst."
    L["A large icon of its own glows red while you are not Well Fed and shows the time left while you are; it turns yellow shortly before the buff runs out. Hold Alt and drag it to move it."] =
        "Ein eigenes, grosses Symbol leuchtet rot, solange du nicht satt bist, und zeigt die Restzeit, solange du es bist; kurz vor Ablauf wird es gelb. Mit gedrückter Alt-Taste verschiebst du es."
    L["Show while Well Fed (time left)"] = "Auch zeigen, wenn satt (Restzeit)"
    L["Only in dungeons and raids"] = "Nur in Dungeons und Schlachtzügen"
    L["Not in cities and inns"]  = "Nicht in Städten und Gasthäusern"
    L["Not in combat"]           = "Nicht im Kampf"
    L["Warn before expiry"]      = "Warnen vor Ablauf"
    L["%d min"]                  = "%d Min."
    L["Size"]                    = "Grösse"
    L["Reset position"]          = "Position zurücksetzen"
    L["Well Fed"]                = "Satt"
    L["Not Well Fed – eat your buff food!"] = "Nicht satt – iss dein Bufffood!"
    L["%s left"]                 = "Noch %s"
    L["Alt + drag: move"]        = "Alt + Ziehen: verschieben"
end

local WELL_FED = 19705
local ICON = "Interface\\Icons\\Spell_Misc_Food"

local defaults = {
    showWhileFed = false, instanceOnly = false, notResting = false, hideCombat = false,
    warn = 5, size = 56,
    point = { "CENTER", "UIParent", "CENTER", 0, -120 },
}

local M = AIO:NewModule("wellfed", {
    title    = L["Well Fed reminder"],
    short    = L["A large icon so you don't forget your buff food."],
    desc     = L["A large icon of its own glows red while you are not Well Fed and shows the time left while you are; it turns yellow shortly before the buff runs out. Hold Alt and drag it to move it."],
    category = "buffs",
    default  = true,
    defaults = defaults,
    options  = {
        { type = "toggle", key = "showWhileFed", label = L["Show while Well Fed (time left)"] },
        { type = "toggle", key = "instanceOnly", label = L["Only in dungeons and raids"], half = true },
        { type = "toggle", key = "notResting", label = L["Not in cities and inns"], half = true },
        { type = "toggle", key = "hideCombat", label = L["Not in combat"], half = true },
        { type = "select", key = "warn", label = L["Warn before expiry"], width = 120, values = {
            { value = 0, label = L["Off"] }, { value = 2, label = L["%d min"]:format(2) },
            { value = 5, label = L["%d min"]:format(5) }, { value = 10, label = L["%d min"]:format(10) } } },
        { type = "slider", key = "size", label = L["Size"], min = 32, max = 96, step = 4 },
        { type = "button", label = L["Reset position"], func = function(m)
            m.db.point = nil
            AIO.CopyDefaults(m.db, defaults)
            m:Place()
        end },
    },
})

-- ---------------------------------------------------------------------------
-- Is the player Well Fed? Returns found, end time (GetTime) or nil.
-- ---------------------------------------------------------------------------

local foodName
local function FoodName()
    if foodName then return foodName end
    if C_Spell and C_Spell.GetSpellInfo then
        local ok, info = pcall(C_Spell.GetSpellInfo, WELL_FED)
        if ok and type(info) == "table" then foodName = info.name end
    elseif GetSpellInfo then
        foodName = GetSpellInfo(WELL_FED)
    end
    return foodName
end

--- found, expires; nil when the buffs can't be read right now.
local function Scan()
    local name = FoodName()
    for i = 1, 40 do
        local n, expires, icon
        if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
            local a, blocked = ns.SafeAura("player", i, "HELPFUL")
            if blocked then return nil end
            if not a then break end
            n, expires, icon = a.name, a.expirationTime, a.icon
        elseif UnitBuff then
            local bn, ic, _, _, _, x = UnitBuff("player", i)
            if not bn then break end
            n, expires, icon = bn, x, ic
        else
            break
        end
        if n and name and n == name then
            return true, (expires and expires > 0) and expires or nil, icon
        end
    end
    return false
end

-- ---------------------------------------------------------------------------
-- The icon
-- ---------------------------------------------------------------------------

local f
local state = { fed = false }

local function SavePosition()
    local point, _, rel, x, y = f:GetPoint(1)
    if point then M.db.point = { point, "UIParent", rel, math.floor((x or 0) + 0.5), math.floor((y or 0) + 0.5) } end
end

function M:Place()
    if not f then return end
    local p = self.db.point or defaults.point
    f:ClearAllPoints()
    f:SetPoint(p[1], UIParent, p[3] or p[1], p[4] or 0, p[5] or 0)
    f:SetSize(self.db.size, self.db.size)
    f.time:SetFont(f.time:GetFont(), math.max(10, math.floor(self.db.size / 4)), "OUTLINE")
end

local function Clock(sec)
    if sec >= 3600 then return ("%d:%02d h"):format(sec / 3600, (sec % 3600) / 60) end
    if sec >= 60 then return ("%d min"):format(math.ceil(sec / 60)) end
    return ("%d s"):format(sec)
end

local function Paint()
    local left = state.expires and (state.expires - GetTime())
    local warn = (M.db.warn or 0) * 60
    if not state.fed then
        f.icon:SetDesaturated(true)
        f.icon:SetAlpha(0.8)
        f.border:SetVertexColor(C.bad[1], C.bad[2], C.bad[3], 1)
        f.time:SetText(L["Well Fed"])
        f.time:SetTextColor(C.bad[1], C.bad[2], C.bad[3])
        if not f.pulse:IsPlaying() then f.pulse:Play() end
    else
        local soon = left and warn > 0 and left <= warn
        f.icon:SetDesaturated(false)
        f.icon:SetAlpha(1)
        local c = soon and C.warn or C.good
        f.border:SetVertexColor(c[1], c[2], c[3], soon and 1 or 0.6)
        f.time:SetText(left and Clock(math.max(0, math.floor(left))) or "")
        f.time:SetTextColor(soon and C.warn[1] or 1, soon and C.warn[2] or 1, soon and C.warn[3] or 1)
        if soon then
            if not f.pulse:IsPlaying() then f.pulse:Play() end
        elseif f.pulse:IsPlaying() then
            f.pulse:Stop()
            f.icon:SetAlpha(1)
        end
    end
end

local function Build()
    if f then return end
    f = CreateFrame("Button", "AllInOneWellFed", UIParent)
    f:SetFrameStrata("MEDIUM")
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:RegisterForClicks()   -- no click action, only the tooltip and Alt + drag

    f.border = f:CreateTexture(nil, "BACKGROUND")
    f.border:SetTexture(Style.WHITE)
    f.border:SetPoint("TOPLEFT", -2, 2)
    f.border:SetPoint("BOTTOMRIGHT", 2, -2)

    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetAllPoints()
    f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    f.icon:SetTexture(ICON)

    f.time = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.time:SetPoint("TOP", f, "BOTTOM", 0, -3)

    -- A soft pulse while missing or running out.
    local ag = f.icon:CreateAnimationGroup()
    ag:SetLooping("BOUNCE")
    local a = ag:CreateAnimation("Alpha")
    a:SetFromAlpha(1)
    a:SetToAlpha(0.35)
    a:SetDuration(0.8)
    f.pulse = ag

    f:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        if state.fed then
            GameTooltip:SetText(L["Well Fed"], 1, 1, 1)
            local left = state.expires and (state.expires - GetTime())
            if left then GameTooltip:AddLine(L["%s left"]:format(Clock(math.max(0, math.floor(left)))), 0.8, 0.8, 0.8) end
        else
            GameTooltip:SetText(L["Not Well Fed – eat your buff food!"], C.bad[1], C.bad[2], C.bad[3])
        end
        GameTooltip:AddLine(L["Alt + drag: move"], 0.5, 0.5, 0.5)
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function() GameTooltip_Hide() end)
    Style.AltDrag(f, f, SavePosition)

    -- Countdown once a second while shown.
    local acc = 0
    f:SetScript("OnUpdate", function(_, dt)
        acc = acc + dt
        if acc < 1 then return end
        acc = 0
        if state.fed and state.expires and state.expires <= GetTime() then
            state.fed, state.expires = false, nil
            M:Update()
        else
            Paint()
        end
    end)
    f:Hide()
    M:Place()
end

local function Wanted()
    local db = M.db
    if UnitIsDeadOrGhost("player") then return false end
    if db.instanceOnly then
        local inside, kind = IsInInstance()
        if not inside or (kind ~= "party" and kind ~= "raid") then return false end
    end
    if db.notResting and IsResting() then return false end
    if db.hideCombat and InCombatLockdown() then return false end
    if state.fed and not db.showWhileFed then return false end
    return true
end

function M:Update()
    if not self.enabled then if f then f:Hide() end return end
    Build()
    local found, expires = Scan()
    if found ~= nil then state.fed, state.expires = found, expires end
    if Wanted() then
        Paint()
        f:Show()
    else
        f.pulse:Stop()
        f:Hide()
    end
end

local pending = false
local function Later()
    if pending then return end
    pending = true
    C_Timer.After(0.3, function() pending = false; M:Update() end)
end

function M:OnEnable() self:Update() end
function M:OnDisable() if f then f.pulse:Stop(); f:Hide() end end
function M:OnSettingChanged()
    if f then self:Place() end
    self:Update()
end

M:On("UNIT_AURA", function(unit) if unit == "player" then Later() end end)
M:On("PLAYER_ENTERING_WORLD", Later)
M:On("PLAYER_UPDATE_RESTING", Later)
M:On("ZONE_CHANGED_NEW_AREA", Later)
M:On("PLAYER_REGEN_DISABLED", Later)
M:On("PLAYER_REGEN_ENABLED", Later)
M:On("PLAYER_DEAD", Later)
M:On("PLAYER_ALIVE", Later)
M:On("PLAYER_UNGHOST", Later)

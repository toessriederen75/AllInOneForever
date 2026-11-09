-- AllInOne: quest items glitter. The game has its own glitter on objects you
-- can loot for a quest, but its "outline" graphics setting hides it. With
-- this on, the outline stays off and the glitter on.
--
-- Every game setting we change is noted first and put back as it was when
-- the module is switched off.
--
-- Cost: nothing runs on a timer; only a graphics preset that turns the
-- outline back on makes us set it again.

local ADDON, ns = ...
if ns.env then setfenv(1, ns.env) end
local AIO, L = ns.AIO, ns.L

if GetLocale() == "deDE" then
    L["Quest items glitter"]   = "Questgegenstände glitzern"
    L["Objects you need for a quest glitter again."] = "Gegenstände für Quests glitzern wieder."
    L["The game's own glitter on objects you can loot for a quest. The outline around objects under the mouse is switched off for it, because the game shows only one of the two."] =
        "Das Glitzern des Spiels auf Gegenständen, die du für eine Quest plündern kannst. Dafür wird der Umriss um Objekte unter der Maus ausgeschaltet, weil das Spiel nur eines von beiden zeigt."
end

local M = AIO:NewModule("sparkle", {
    title    = L["Quest items glitter"],
    short    = L["Objects you need for a quest glitter again."],
    desc     = L["The game's own glitter on objects you can loot for a quest. The outline around objects under the mouse is switched off for it, because the game shows only one of the two."],
    category = "display",
    default  = true,
    defaults = {},
})

local QUEST_CVARS = {
    graphicsOutlineMode = "0",
    raidGraphicsOutlineMode = "0",
    outlineModeShowLootEffectWhenDisabled = "1",
}

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

--- Sets our values while `on`; otherwise, and for every setting an earlier
--- version changed (herb and vein glow), puts back what was there before.
local function Use(on)
    local db = M.db
    db.saved = db.saved or {}
    local saved = db.saved
    for name, old in pairs(saved) do
        if not (on and QUEST_CVARS[name]) then
            if GetCV(name) ~= old then SetCV(name, old) end
            saved[name] = nil
        end
    end
    if on then
        for name, value in pairs(QUEST_CVARS) do
            local now = GetCV(name)
            if now ~= nil then
                if saved[name] == nil then saved[name] = now end
                if now ~= value then SetCV(name, value) end
            end
        end
    end
end

function M:Apply()
    if InCombatLockdown() then self.pending = true return end
    self.pending = nil
    Use(self.enabled)
    -- Left over from the herb and vein glow of earlier versions.
    self.db.learnt, self.db.alertPos = nil, nil
end

function M:OnEnable() self:Apply() end
function M:OnDisable() self:Apply() end

M:On("PLAYER_REGEN_ENABLED", function()
    if M.pending then M:Apply() end
end)

-- A graphics preset turns the outline back on: put the glitter back.
M:On("CVAR_UPDATE", function(name)
    if busy or type(name) ~= "string" then return end
    local n = name:lower()
    if (n:find("outline", 1, true) or n:find("graphicsquality", 1, true)) and C_Timer and not M.queued then
        M.queued = true
        C_Timer.After(1, function()
            M.queued = nil
            if M.enabled and not InCombatLockdown() then
                for cvar, value in pairs(QUEST_CVARS) do
                    if GetCV(cvar) ~= nil and GetCV(cvar) ~= value then SetCV(cvar, value) end
                end
            end
        end)
    end
end)

-- The module may be off: still put back what earlier versions changed, and
-- forget the data of the gathering map that is gone.
AIO:On("PLAYER_ENTERING_WORLD", function()
    local mods = AIO.settings and AIO.settings.modules
    if not mods then return end
    mods.gather = nil
    if not M.enabled and M.db and M.db.saved and next(M.db.saved) and not InCombatLockdown() then
        Use(false)
    end
end)

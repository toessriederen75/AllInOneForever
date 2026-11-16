-- AllInOne: tells your group when you have finished a quest. As soon as the
-- last item of a quest is looted (6/6), "<quest> -> Completed" goes to the
-- party chat, so nobody has to ask; the same for kill and explore quests
-- once the last objective is done. Only in a group.
--
-- How: the quest log is looked at after it changes (at most once a frame).
-- A quest that was not complete before and is now gets announced once. What
-- was already complete when you logged in or accepted it is not announced.

local ADDON, ns = ...
if ns.env then setfenv(1, ns.env) end
local AIO, L = ns.AIO, ns.L

if GetLocale() == "deDE" then
    L["Tell the group about finished quests"] = "Gruppe über erledigte Quests informieren"
    L["\"Quest -> Completed\" in the party chat when you have finished a quest."] =
        "„Quest -> Abgeschlossen“ im Gruppenchat, wenn du eine Quest erledigt hast."
    L["As soon as a quest is done – the last item looted (6/6) or the last enemy killed – a line \"Quest -> Completed\" goes to the party chat. Only while you are in a group."] =
        "Sobald eine Quest erledigt ist – der letzte Gegenstand gelootet (6/6) oder der letzte Gegner getötet –, geht eine Zeile „Quest -> Abgeschlossen“ in den Gruppenchat. Nur, solange du in einer Gruppe bist."
    L["Completed"]                 = "Abgeschlossen"
    L["Only quests with items"]    = "Nur Quests mit Gegenständen"
    L["Leaves out kill, explore and event quests."] = "Lässt Quests zum Töten, Erkunden und für Ereignisse weg."
    L["In a raid: raid chat"]      = "Im Schlachtzug: Schlachtzugchat"
    L["Otherwise the message goes to your own party within the raid."] =
        "Sonst geht die Nachricht an deine eigene Gruppe im Schlachtzug."
end

local M = AIO:NewModule("questdone", {
    title    = L["Tell the group about finished quests"],
    short    = L["\"Quest -> Completed\" in the party chat when you have finished a quest."],
    desc     = L["As soon as a quest is done – the last item looted (6/6) or the last enemy killed – a line \"Quest -> Completed\" goes to the party chat. Only while you are in a group."],
    category = "quests",
    default  = true,
    defaults = { itemsOnly = false, raid = false },
    options  = {
        { type = "toggle", key = "itemsOnly", label = L["Only quests with items"], desc = L["Leaves out kill, explore and event quests."] },
        { type = "toggle", key = "raid", label = L["In a raid: raid chat"], desc = L["Otherwise the message goes to your own party within the raid."] },
    },
})

local CQ = C_QuestLog
-- Note: the quest log functions are looked up through AllInOne's own
-- environment (no _G.), where Compat.lua fills in what WoW Forever only has
-- under C_QuestLog.

local function Call(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d, e, f, g, h = pcall(fn, ...)
    if ok then return a, b, c, d, e, f, g, h end
end

-- Quests we know of: state[key] = true (complete) or false. title[key] and
-- items[key] (asks for items) beside it. The key is the quest ID, or the
-- title where a client gives none.
local state, titles, items = {}, {}, {}
local ready = false   -- the first look after login only notes, never announces

--- Does the quest at log index i ask for items? Also returns whether it has
--- any objective at all.
local function Objectives(i, id)
    local any, item = false, false
    if id and CQ and CQ.GetQuestObjectives then
        local list = Call(CQ.GetQuestObjectives, id)
        if type(list) == "table" and #list > 0 then
            for _, o in ipairs(list) do
                any = true
                if o.type == "item" then item = true end
            end
            return item, any
        end
    end
    if type(GetNumQuestLeaderBoards) ~= "function" then
        -- Nothing to tell the kinds apart: count it as a quest with goals.
        return false, true
    end
    local n = Call(GetNumQuestLeaderBoards, i) or 0
    for j = 1, n do
        local _, kind = Call(GetQuestLogLeaderBoard, j, i)
        any = true
        if kind == "item" then item = true end
    end
    return item, any
end

local function Announce(key)
    if not (IsInGroup and IsInGroup()) then return end
    local channel = "PARTY"
    if M.db.raid and IsInRaid and IsInRaid() then channel = "RAID" end
    local text = ("%s -> %s"):format(titles[key] or "?", L["Completed"])
    -- Newer clients (WoW Forever) send chat through C_ChatInfo.
    local send = (C_ChatInfo and C_ChatInfo.SendChatMessage) or SendChatMessage
    local ok, err = pcall(send, text, channel)
    if not ok and not M.warned then
        M.warned = true
        M:Print("|cffff6060" .. tostring(err) .. "|r")
    end
end

local seen = {}
local function Scan()
    wipe(seen)
    local n = Call(GetNumQuestLogEntries) or 0
    for i = 1, n do
        local title, _, _, isHeader, _, isComplete, _, id = Call(GetQuestLogTitle, i)
        if title and not isHeader then
            local key = id and id > 0 and id or title
            seen[key] = true
            local done = isComplete == 1 or isComplete == true
            local was = state[key]
            if was == nil then
                -- New in the log (or the first look): only noted.
                titles[key] = title
                items[key] = (Objectives(i, id))
            elseif done and not was and ready then
                local hasItems, any = Objectives(i, id)
                items[key] = hasItems
                if any and (hasItems or not M.db.itemsOnly) then Announce(key) end
            end
            state[key] = done
        end
    end
    -- Quests under a folded header do not show in the log: ask the game
    -- about them by ID where it can; drop the ones that are gone.
    for key, was in pairs(state) do
        if not seen[key] then
            local onQuest = type(key) == "number" and CQ and CQ.IsOnQuest and Call(CQ.IsOnQuest, key)
            if onQuest then
                local done = CQ.IsComplete and Call(CQ.IsComplete, key) and true or false
                if done and not was and ready and (items[key] or not M.db.itemsOnly) then Announce(key) end
                state[key] = done
            elseif onQuest == false or type(key) ~= "number" then
                state[key], titles[key], items[key] = nil, nil, nil
            end
        end
    end
    ready = true
end

local function Later() AIO:Later("questdone", Scan) end

function M:OnEnable()
    wipe(state); wipe(titles); wipe(items)
    ready = false
    Scan()
end

M:On("QUEST_LOG_UPDATE", Later)
M:On("PLAYER_ENTERING_WORLD", function() if not ready then Later() end end)

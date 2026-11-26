-- AllInOne: a small error log in the saved variables.
--
-- Lua errors that come from this addon or from a bank window, and every
-- "action blocked" the game reports, are kept (the last 25, repeats only
-- counted) in AllInOneForeverDB.errorLog. They are written to disk at
-- /reload or logout, so a problem can be looked at later without copying
-- error windows by hand.
--
-- Cost: nothing until an error happens.

local ADDON, ns = ...
local MAX = 25

local log = {}           -- until the saved variables are loaded
local function Store()
    local db = _G[ns.dbName or "AllInOneDB"]
    if type(db) ~= "table" then return log end
    if type(db.errorLog) ~= "table" then db.errorLog = {} end
    if db.errorLog ~= log then
        for _, e in ipairs(log) do db.errorLog[#db.errorLog + 1] = e end
        log = db.errorLog
    end
    return log
end

local function Add(kind, msg, stack)
    msg = tostring(msg or "")
    local list = Store()
    for _, e in ipairs(list) do
        if e.msg == msg then
            e.count = (e.count or 1) + 1
            e.last = date("%Y-%m-%d %H:%M:%S")
            return
        end
    end
    list[#list + 1] = {
        kind = kind, msg = msg, count = 1,
        first = date("%Y-%m-%d %H:%M:%S"),
        stack = stack and stack:sub(1, 2000) or nil,
        version = C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(ADDON, "Version") or nil,
    }
    while #list > MAX do table.remove(list, 1) end
end

-- Lua errors: ours, or anything about a bank window.
local IsSecret = _G.issecretvalue or function() return false end

local function Consider(msg, stack)
    if IsSecret(msg) then return end
    local text = tostring(msg)
    stack = stack or ""
    if text:find(ADDON, 1, true) or stack:find(ADDON, 1, true)
        or text:find("Bank", 1, true) or stack:find("Bank", 1, true) then
        Add("error", text, stack)
    end
end

-- Newer client (WoW Forever): the game's error handler must stay the game's,
-- else every error with a "secret" text fails a second time in Blizzard's
-- error window. We only look at what that window is handed (afterwards).
local hookedWindow = false
local function HookErrorWindow()
    local w = _G.ScriptErrorsFrame
    if hookedWindow or not (w and w.OnError) then return end
    hookedWindow = true
    hooksecurefunc(w, "OnError", function(_, msg)
        pcall(Consider, msg, nil)
    end)
end

if _G.issecretvalue then
    HookErrorWindow()
elseif seterrorhandler then
    local previous = geterrorhandler and geterrorhandler()
    local busy = false
    seterrorhandler(function(msg, ...)
        if not busy then
            busy = true
            pcall(Consider, msg, debugstack and debugstack(3) or "")
            busy = false
        end
        if previous then return previous(msg, ...) end
    end)
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("ADDON_ACTION_BLOCKED")
f:RegisterEvent("ADDON_ACTION_FORBIDDEN")
f:SetScript("OnEvent", function(_, event, a, b)
    if event == "ADDON_LOADED" then
        if a == ADDON then Store() end
        if a == "Blizzard_ScriptErrorsFrame" and _G.issecretvalue then HookErrorWindow() end
        return
    end
    -- The game names the addon it blames and the protected function.
    Add(event == "ADDON_ACTION_FORBIDDEN" and "forbidden" or "blocked",
        tostring(a) .. " -> " .. tostring(b), debugstack and debugstack(2) or nil)
end)

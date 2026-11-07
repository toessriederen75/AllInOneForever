-- AllInOne: the three windows — bags, bank and guild bank.

local ADDON, ns = ...
if ns.env then setfenv(1, ns.env) end
local AIO, L = ns.AIO, ns.L

-- ---------------------------------------------------------------------------
-- Shared pieces
-- ---------------------------------------------------------------------------

local function OwnerName(w)
    return w.owner or AIO.player
end

local function IsMe(w)
    return w.owner == nil or w.owner == AIO.player
end

local function CharacterMenu(w)
    local items = {}
    local realm = AIO:RealmData()
    for _, name in ipairs(AIO:Characters()) do
        local c = realm[name]
        items[#items + 1] = {
            text = AIO.ClassColored(name, c and c.class),
            checked = (OwnerName(w) == name),
            func = function()
                w.owner = (name ~= AIO.player) and name or nil
                w:Refresh()
            end,
        }
    end
    return items
end

--- Entries for a list of bags out of saved data.
local function SavedEntries(char, bags, list, gapFirst)
    list = list or {}
    local first = true
    for _, bag in ipairs(bags) do
        local data = char and char.bags and char.bags[bag]
        if data and data.size then
            for slot = 1, data.size do
                local v = data.items and data.items[slot]
                local link, icon, quality
                if v then link, icon, quality = AIO:ItemFace(v) end
                list[#list + 1] = {
                    mode = "offline", slot = slot,
                    link = link, icon = icon, quality = quality,
                    count = v and ((data.counts and data.counts[slot]) or 1),
                    gap = (first and gapFirst) or nil,
                }
                first = false
            end
        end
    end
    return list
end

local function LiveEntries(bags, list, gapFirst)
    list = list or {}
    local first = true
    for _, bag in ipairs(bags) do
        local n = AIO.NumSlots(bag)
        for slot = 1, n do
            list[#list + 1] = { live = true, bag = bag, slot = slot, gap = (first and gapFirst) or nil }
            first = false
        end
    end
    return list
end

--- "Free: x/y" over the bags that take any item.
local function FreeText(bags, char, live)
    local free, total = 0, 0
    for _, bag in ipairs(bags) do
        if live then
            local n = AIO.NumSlots(bag)
            if n > 0 and AIO.BagFamily(bag) == 0 then
                total = total + n
                free = free + AIO.FreeSlots(bag)
            end
        else
            local data = char and char.bags and char.bags[bag]
            if data and data.size then
                total = total + data.size
                for slot = 1, data.size do
                    if not (data.items and data.items[slot]) then free = free + 1 end
                end
            end
        end
    end
    if total == 0 then return nil end
    return L["Free: %d/%d"]:format(free, total)
end

--- Forever: free slots of the reagent bag, or nil without one.
local function ReagentFree(char, live)
    local bag = AIO.REAGENTBAG
    if not bag then return nil end
    if live then
        local n = AIO.NumSlots(bag)
        if n <= 0 then return nil end
        return AIO.FreeSlots(bag), n
    end
    local data = char and char.bags and char.bags[bag]
    if not (data and data.size) then return nil end
    local free = 0
    for slot = 1, data.size do
        if not (data.items and data.items[slot]) then free = free + 1 end
    end
    return free, data.size
end

-- ---------------------------------------------------------------------------
-- Bags
-- ---------------------------------------------------------------------------

-- Bank button in the header of the bags: opens the bank window of the same
-- character (live at a banker, otherwise as last seen), a second click closes it.
local bankButton = {
    glyph = "bank", tip = L["Open the bank (as last seen when you are not at a banker)"],
    active = function() local b = AIO.windows.bank; return b ~= nil and b:IsShown() end,
    click = function(w)
        local b = AIO.windows.bank
        if not b then return end
        if b:IsShown() then
            b:Hide()
        else
            b.owner = w.owner
            AIO:Show("bank")
        end
    end,
}

-- Key button in the header: shows or hides the keyring under the bags.
local keyButton = AIO.KEYRING and {
    glyph = "key", tip = L["Show or hide the keyring"],
    active = function() return AIO.settings.showKeyring end,
    click = function(w)
        AIO.settings.showKeyring = not AIO.settings.showKeyring
        AIO:RefreshAll()
        if AIO.RefreshOptionsPage then AIO:RefreshOptionsPage() end
    end,
} or nil

local inventory = {
    headerButtons = { bankButton, keyButton },
    Owners = CharacterMenu,
    IsLive = function(w) return IsMe(w) end,
    CanSort = function(w) return IsMe(w) end,
    Title = function(w)
        local text = L["%s's bags"]:format(OwnerName(w))
        if not IsMe(w) then text = text .. " |cff888888" .. L["(offline)"] .. "|r" end
        return text
    end,
    Entries = function(w)
        local showKeys = AIO.KEYRING and AIO.settings.showKeyring
        local reagent = AIO.REAGENTBAG
        if IsMe(w) then
            local list = LiveEntries(AIO:MainBags())
            -- The reagent bag as its own block under the bags, as Blizzard does.
            if reagent and AIO.NumSlots(reagent) > 0 then LiveEntries({ reagent }, list, true) end
            if showKeys and AIO.NumSlots(AIO.KEYRING) > 0 then
                LiveEntries({ AIO.KEYRING }, list, true)
            end
            return list
        end
        local char = AIO:CharData(w.owner)
        local list = SavedEntries(char, AIO:MainBags())
        if reagent then SavedEntries(char, { reagent }, list, true) end
        if showKeys then SavedEntries(char, { AIO.KEYRING }, list, true) end
        return list
    end,
    Footer = function(w)
        local char, live = AIO:CharData(OwnerName(w)), IsMe(w)
        local text = FreeText(AIO:MainBags(), char, live)
        local rf, rn = ReagentFree(char, live)
        if rf then
            local r = L["Reagents: %d/%d"]:format(rf, rn)
            text = text and (text .. "   " .. r) or r
        end
        return text
    end,
    Money = function(w)
        if IsMe(w) then return GetMoney() end
        local c = AIO:CharData(w.owner)
        return c and c.money
    end,
}

-- ---------------------------------------------------------------------------
-- Bank
-- ---------------------------------------------------------------------------

local function BankLive(w)
    return AIO.atBank and IsMe(w)
end

-- Bank bag slots: the old way (GetNumBankSlots / PurchaseSlot) or, on newer
-- clients, bank tabs (C_Bank). Returns bought, all bought?, cost of the next.
local CB = C_Bank
local CHAR_BANK = Enum and Enum.BankType and Enum.BankType.Character or 0

local function BankSlots()
    if GetNumBankSlots then
        local num, full = GetNumBankSlots()
        return num or 0, full, GetBankSlotCost and GetBankSlotCost(num or 0) or 0
    end
    if CB and CB.FetchNumPurchasedBankTabs then
        local num = CB.FetchNumPurchasedBankTabs(CHAR_BANK) or 0
        local nextTab = CB.FetchNextPurchasableBankTabData and CB.FetchNextPurchasableBankTabData(CHAR_BANK)
        local full = CB.HasMaxBankTabs and CB.HasMaxBankTabs(CHAR_BANK) or not nextTab
        return num, full, nextTab and nextTab.tabCost or 0
    end
    return 0, true, 0
end

local function BuyBankSlot()
    if PurchaseSlot then PurchaseSlot()
    elseif CB and CB.PurchaseBankTab then CB.PurchaseBankTab(CHAR_BANK) end
end

--- Inventory slot of a bank bag (for putting a bag in or taking it out).
local function BankBagInv(bag)
    if C_Container and C_Container.ContainerIDToInventoryID then
        local ok, inv = pcall(C_Container.ContainerIDToInventoryID, bag)
        if ok and inv then return inv end
    end
    if ContainerIDToInventoryID then
        local ok, inv = pcall(ContainerIDToInventoryID, bag)
        if ok and inv then return inv end
    end
    return nil
end

StaticPopupDialogs["ALLINONE_BUY_BANKSLOT"] = {
    text = "%s",
    button1 = YES,
    button2 = NO,
    OnAccept = function() BuyBankSlot() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

local bank = {
    Owners = CharacterMenu,
    IsLive = BankLive,
    CanSort = BankLive,
    Title = function(w)
        local text = L["%s's bank"]:format(OwnerName(w))
        if not BankLive(w) then text = text .. " |cff888888" .. L["(offline)"] .. "|r" end
        return text
    end,
    Entries = function(w)
        if BankLive(w) then return LiveEntries(AIO:BankBags()) end
        return SavedEntries(AIO:CharData(OwnerName(w)), AIO:BankBags())
    end,
    EmptyNote = function(w)
        if BankLive(w) then return nil end
        local c = AIO:CharData(OwnerName(w))
        local has = c and c.bags and c.bags[AIO.BANK]
        if not has then return L["No bank data yet. Visit a banker once with this character."] end
    end,
    Footer = function(w)
        return FreeText(AIO:BankBags(), AIO:CharData(OwnerName(w)), BankLive(w))
    end,
    Money = inventory.Money,
    Build = function(w)
        -- A row of the bank bag slots (put a bag in, take it out; red ones
        -- are not bought yet) and the button to buy the next one.
        w.bagSlots = {}
        for i = 1, AIO.NUM_BANKBAGS do
            local bag = AIO.FIRST_BANKBAG + i - 1
            local b = CreateFrame("Button", nil, w)
            b:SetSize(26, 26)
            b:SetPoint("BOTTOMLEFT", 12 + (i - 1) * 29, 38)
            b.bg = b:CreateTexture(nil, "BACKGROUND")
            b.bg:SetAllPoints()
            b.bg:SetColorTexture(0, 0, 0, 0.6)
            b.icon = b:CreateTexture(nil, "ARTWORK")
            b.icon:SetPoint("TOPLEFT", 1, -1)
            b.icon:SetPoint("BOTTOMRIGHT", -1, 1)
            b.lock = b:CreateTexture(nil, "OVERLAY")
            b.lock:SetAllPoints()
            b.lock:SetColorTexture(0.8, 0.1, 0.1, 0.35)
            b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
            b.bag, b.index = bag, i
            b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            b:RegisterForDrag("LeftButton")
            local function use(self)
                local inv = BankBagInv(self.bag)
                if not inv or self.locked then return end
                if CursorHasItem() then PutItemInBag(inv) else PickupBagFromSlot(inv) end
            end
            b:SetScript("OnClick", use)
            b:SetScript("OnDragStart", use)
            b:SetScript("OnReceiveDrag", use)
            b:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                local inv = BankBagInv(self.bag)
                if self.locked then
                    GameTooltip:SetText(L["Bank bag slot (not bought yet)"], 1, 0.3, 0.3)
                elseif inv and GetInventoryItemTexture("player", inv) then
                    GameTooltip:SetInventoryItem("player", inv)
                else
                    GameTooltip:SetText(L["Bank bag slot: drop a bag here"], 1, 1, 1)
                end
                GameTooltip:Show()
            end)
            b:SetScript("OnLeave", GameTooltip_Hide)
            b:Hide()
            w.bagSlots[i] = b
        end
        w.buy = AIO.Style.Button(w, L["Buy bank slot"], 130, 22)
        w.buy:SetScript("OnClick", function()
            local _, _, cost = BankSlots()
            StaticPopup_Show("ALLINONE_BUY_BANKSLOT", L["Buy a bank bag slot for %s?"]:format(AIO.Money(cost)))
        end)
        w.buy:Hide()
    end,
    Update = function(w)
        local live = BankLive(w)
        local num, full = BankSlots()
        local anySlot = false
        for i, b in ipairs(w.bagSlots) do
            local inv = live and BankBagInv(b.bag)
            if inv then
                anySlot = true
                b.locked = i > num
                b.icon:SetTexture(GetInventoryItemTexture("player", inv) or "Interface\\PaperDoll\\UI-PaperDoll-Slot-Bag")
                b.lock:SetShown(b.locked)
                b:Show()
            else
                b:Hide()
            end
        end
        local buy = live and not full
        w.buy:ClearAllPoints()
        if anySlot then
            w.buy:SetPoint("LEFT", w.bagSlots[#w.bagSlots], "RIGHT", 8, 0)
        else
            w.buy:SetPoint("BOTTOMLEFT", 12, 40)
        end
        w.buy:SetShown(buy)
        w.extra = (anySlot or buy) and 32 or 0
    end,
    extraHeight = function(w) return w.extra or 0 end,
    OnHide = function(w)
        if AIO.atBank and not AIO.closingBank then AIO:CloseBank() end
    end,
}

-- ---------------------------------------------------------------------------
-- Guild bank
-- ---------------------------------------------------------------------------

local function GuildName(w)
    return w.owner or GetGuildInfo("player")
end

local function GuildLive(w)
    return AIO.atGuild and GuildName(w) == GetGuildInfo("player")
end

local MAX_TABS = 8

local function SelectTab(w, tab)
    w.tab = tab
    if GuildLive(w) then
        if SetCurrentGuildBankTab then SetCurrentGuildBankTab(tab) end
        if QueryGuildBankTab then
            AIO.guildQueried = AIO.guildQueried or {}
            AIO.guildQueried[tab] = true
            QueryGuildBankTab(tab)
        end
    end
    w:Refresh()
end

local guild = {
    ownerTip = L["Choose guild"],
    Owners = function(w)
        local items = {}
        for _, name in ipairs(AIO:Guilds()) do
            items[#items + 1] = {
                text = "<" .. name .. ">",
                checked = (GuildName(w) == name),
                func = function()
                    w.owner = (name ~= GetGuildInfo("player")) and name or nil
                    w.tab = 1
                    w:Refresh()
                end,
            }
        end
        return items
    end,
    IsLive = GuildLive,
    Title = function(w)
        local name = GuildName(w)
        if not name then return L["Guild Bank"] end
        local text = "<" .. name .. ">"
        local data = AIO:GuildData(name)
        local t = data and data.tabs and data.tabs[w.tab or 1]
        if t and t.name then text = text .. " - " .. t.name end
        if not GuildLive(w) then text = text .. " |cff888888" .. L["(offline)"] .. "|r" end
        return text
    end,
    Entries = function(w)
        local tab = w.tab or 1
        local list = {}
        if GuildLive(w) then
            for slot = 1, AIO.GUILD_SLOTS do
                local icon, count, locked, _, quality = GetGuildBankItemInfo(tab, slot)
                local link = icon and GetGuildBankItemLink(tab, slot)
                list[slot] = { mode = "guild", guildLive = true, tab = tab, slot = slot,
                               icon = icon, count = count, locked = locked, quality = quality, link = link }
            end
            return list
        end
        local data = AIO:GuildData(GuildName(w))
        local t = data and data.tabs and data.tabs[tab]
        if not (t and t.items) then return list end
        for slot = 1, AIO.GUILD_SLOTS do
            local v = t.items[slot]
            local link, icon, quality
            if v then link, icon, quality = AIO:ItemFace(v) end
            list[slot] = { mode = "guild", tab = tab, slot = slot,
                           link = link, icon = icon, quality = quality,
                           count = v and ((t.counts and t.counts[slot]) or 1) }
        end
        return list
    end,
    EmptyNote = function(w)
        local name = GuildName(w)
        if not name then return L["Not in a guild."] end
        if GuildLive(w) then return nil end
        local data = AIO:GuildData(name)
        local t = data and data.tabs and data.tabs[w.tab or 1]
        if not (t and t.items) then return L["No data for this guild yet. Open the guild bank once."] end
    end,
    Footer = function(w)
        if not GuildLive(w) then return nil end
        local _, _, _, _, _, remaining = GetGuildBankTabInfo(w.tab or 1)
        if remaining == nil then return nil end
        return L["Withdrawals left: %s"]:format(remaining < 0 and L["unlimited"] or remaining)
    end,
    Money = function(w)
        if GuildLive(w) and GetGuildBankMoney then return GetGuildBankMoney() end
        local data = AIO:GuildData(GuildName(w))
        return data and data.money
    end,
    MoneyTooltip = function(w, owner)
        GameTooltip:SetOwner(owner, "ANCHOR_TOPRIGHT")
        GameTooltip:AddLine(L["Guild Bank"])
        local money = w.def.Money(w)
        GameTooltip:AddLine(AIO.Money(money or 0), 1, 1, 1)
        GameTooltip:Show()
    end,
    Build = function(w)
        w.tabButtons = {}
        for i = 1, MAX_TABS do
            local b = AIO.SideButton(w, "Interface\\Icons\\INV_Misc_QuestionMark",
                function(self) return self.tabName or L["Tab %d"]:format(i) end,
                function() SelectTab(w, i) end)
            b:SetPoint("TOPLEFT", w, "TOPRIGHT", 3, -(i - 1) * 33)
            b:Hide()
            w.tabButtons[i] = b
        end

        w.deposit = AIO.Style.Button(w, L["Deposit"], 90, 20)
        w.deposit:SetPoint("BOTTOMLEFT", 10, 34)
        w.deposit:SetScript("OnClick", function()
            if StaticPopupDialogs["GUILDBANK_DEPOSIT"] then StaticPopup_Show("GUILDBANK_DEPOSIT") end
        end)
        w.withdraw = AIO.Style.Button(w, L["Withdraw"], 90, 20)
        w.withdraw:SetPoint("LEFT", w.deposit, "RIGHT", 4, 0)
        w.withdraw:SetScript("OnClick", function()
            if StaticPopupDialogs["GUILDBANK_WITHDRAW"] then StaticPopup_Show("GUILDBANK_WITHDRAW") end
        end)
    end,
    Update = function(w)
        local live = GuildLive(w)
        local name = GuildName(w)
        local data = name and AIO:GuildData(name)
        local n = live and GetNumGuildBankTabs and GetNumGuildBankTabs() or (data and data.numTabs) or 0
        w.tab = math.min(math.max(1, w.tab or 1), math.max(1, n))
        for i, b in ipairs(w.tabButtons) do
            if i <= n then
                local tabName, icon, viewable
                if live then
                    tabName, icon, viewable = GetGuildBankTabInfo(i)
                else
                    local t = data.tabs and data.tabs[i]
                    tabName, icon, viewable = t and t.name, t and t.icon, t and t.viewable
                end
                b.tabName = tabName
                b.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
                b.icon:SetDesaturated(not viewable)
                b:SetChecked(i == w.tab)
                b:Show()
            else
                b:Hide()
            end
        end
        local money = live and StaticPopupDialogs["GUILDBANK_DEPOSIT"] ~= nil
        w.deposit:SetShown(money)
        w.withdraw:SetShown(money and CanWithdrawGuildBankMoney and CanWithdrawGuildBankMoney() or false)
        w.extra = money and 24 or 0
    end,
    extraHeight = function(w) return w.extra or 0 end,
    OnHide = function(w)
        if AIO.atGuild and not AIO.closingGuild then AIO:CloseGuild() end
    end,
}

function AIO:CreateWindows()
    self:CreateWindow("inventory", inventory)
    self:CreateWindow("bank", bank)
    self:CreateWindow("guild", guild)
    -- The bank button in the bags is lit exactly while the bank window is
    -- open, however it is opened or closed.
    local inv, b = self.windows.inventory, self.windows.bank
    if inv and b then
        local function lit()
            for _, hb in ipairs(inv.headerButtons or {}) do
                if hb.def.active then hb:SetActive(hb.def.active(inv)) end
            end
        end
        b:HookScript("OnShow", lit)
        b:HookScript("OnHide", lit)
    end
end

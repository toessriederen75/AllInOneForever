-- AllInOneForever: AllInOne for WoW Forever, built from the same sources.
-- Its own name and saved settings; the own bag, bank and guild bank windows
-- are switched on by default (can be turned off in the Bags & Bank tab).
local ADDON, ns = ...
ns.title  = "AllInOneForever"
ns.skin   = "modern"   -- Blizzard's modern bag look
ns.ui     = "blizzard" -- every window drawn in the modern Blizzard look (as in AllInOne)
ns.dbName = "AllInOneForeverDB"
-- Our own bank window again (with Forever's bank tabs). Blizzard's bank
-- window stays open but is parked in a frame scaled down to nothing, so it
-- takes no room and no clicks (moving it away broke it before). Buying a
-- tab goes through Blizzard's own button, laid invisibly over ours.
ns.parkPanels = true
-- The same for the guild bank: Blizzard's window. The tabs you look at are
-- still noted, for the guild bank line in tooltips (if switched on).
ns.noGuild = true
ns.defaults = { replaceBags = true, replaceBank = true, replaceGuild = false, tooltipCounts = true,
                showKeyring = false }   -- Blizzard's Forever bags leave the keyring out
-- Applied once to existing saved settings too (they were saved as "off" before).
ns.resetOnce = { showKeyring = false, replaceBags = true, tooltipCounts = true, replaceBank = true }

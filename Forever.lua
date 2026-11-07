-- AllInOneForever: AllInOne for WoW Forever, built from the same sources.
-- Its own name and saved settings; the own bag, bank and guild bank windows
-- are switched on by default (can be turned off in the Bags & Bank tab).
local ADDON, ns = ...
ns.title  = "AllInOneForever"
ns.skin   = "modern"   -- Blizzard's modern bag look
ns.ui     = "blizzard" -- every window drawn in the modern Blizzard look (as in AllInOne)
ns.dbName = "AllInOneForeverDB"
-- No bank window of our own: Forever's bank (with its bank tabs) stays
-- Blizzard's. What lies in the bank is still noted for tooltips and counts.
ns.noBank = true
ns.defaults = { replaceBags = true, replaceBank = false, replaceGuild = true, tooltipCounts = false,
                showKeyring = false }   -- Blizzard's Forever bags leave the keyring out
-- Applied once to existing saved settings too (they were saved as "off" before).
ns.resetOnce = { showKeyring = false, replaceBags = true, replaceGuild = true }

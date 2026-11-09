# Changelog

## 2.30.2
- Sparkles: German vein names as the game uses them (Kupfervorkommen, Zinnvorkommen …), so skill and icon are right. The node's nameplate is also taken when the game announces it, so the glow sits on the node more often. `/aio sparkle` also lists the nameplates that came up.

## 2.30.1
- Sparkles: the glow now finds herbs and veins also when WoW Forever hands out no readable name (by the node's object ID) and finds the node's nameplate in more ways. Without a nameplate the glow with name and icon shows above your character. `/aio sparkle` now also tells what the module sees in front of you.

## 2.30.0
- New: Gathering map (Maps). Every herb, mining vein and treasure chest you gather is noted with its place and shown on the world map and the minimap (with the icon of what it gives; pointing at it tells the name and how often you found it). All your characters fill the same map. Kinds, maps and pin size can be switched in the options. `/aio gather` tells what is known in your zone, `/aio gather clear` forgets the zone.

## 2.29.0
- New: Sparkles (Display). Quest items glitter again – the game's own glitter, which its outline setting hides. The herb or mining vein in front of you gets a golden glow with the icon of what it gives and its name in the colour of the skill-up chance (red with the skill needed when yours is too low). Only for your own professions if wanted; reach adjustable. Names not on the list are learnt the first time you gather them. Every game setting changed for it is put back when you switch it off.

## 2.28.0
- WoW Forever: no own guild bank window any more – the guild bank is Blizzard's again. The tabs you look at are still noted for the guild bank line in tooltips (if switched on).

## 2.27.0
- Bags: mark items. Alt + left click puts a yellow frame around an item (for all characters, every stack of it), Alt + right click takes it away. Marked items are never sold as junk; the tooltip says it is marked.

## 2.26.0
- Item tooltips: how many of the item each of your characters holds in bags and bank (switched on). The guild bank can be added in the options ("Include the guild bank", off by default).

## 2.25.1
- Bank (WoW Forever): Blizzard's bank window opens again. After closing the bank it was moved off screen and made invisible, so the next visit showed nothing.

## 2.25.0
- Info bar: a right click on the experience segment resets XP per hour; the tooltip shows how long it has been measured.

## 2.24.2
- Bags (WoW Forever): the bag window opens again. Blizzard's bag frames are now kept shown but invisible off screen, so the game sees them as open and our window follows.

## 2.24.1
- Skip gossip: no error when WoW Forever hands out the NPC as a "secret" value.

## 2.24.0
- WoW Forever: Blizzard's bag functions are no longer replaced but only followed. Replacing them "tainted" Blizzard's interface, so the game blocked actions such as buying a bank tab or using some items from the bags.

## 2.23.0
- WoW Forever: no own bank window any more – the bank with its bank tabs is Blizzard's again. Bags and guild bank stay. What lies in the bank is still noted for item counts.

## 2.22.1
- Bank (WoW Forever): bank tabs are recognised (all nine). "Buy bank tab" brings Blizzard's own bank window up next to ours, because only Blizzard's button may buy a tab; it goes away again by itself once the tab is bought. No more blocked-action message.

## 2.22.0
- Bank: a row of the bank bag slots at the bottom of the bank window – drop a bag in, click to take it out; slots not bought yet are red. Next to it the button to buy the next slot (works with bank bag slots and with bank tabs). /aio info also lists which bank functions the client has.

## 2.21.0
- Travel routes: every WoW Forever boat and zeppelin, with the exact dock positions – Stormwind Harbor, the Menethil–Southshore–Auberdine round trip (one way), Steamwheedle Port–Powderfuse Port, Zephras Isle from Dalaran and Skywatcher Plateau, Feathermoon, and the classic routes.

## 2.20.2
- Travel routes: Feathermoon ferry, and the WoW Forever routes from Skywatcher Plateau and Dalaran to Valanaar. /aio map here prints your map and position.

## 2.20.1
- Travel routes: zones are found by name when the client numbers its maps differently; new command /aio map shows what the map module sees.

## 2.20.0
- New "Map" tab: travel routes. Every boat dock and zeppelin tower gets a pin on the world map; pointing at it tells where it goes. On continent and world maps a coloured line joins both ends (blue Alliance, red Horde, gold neutral). Only your own faction by default.

## 2.19.0
- Options: one search box at the top right that searches everything – every tab, every helper and the names and descriptions of all their settings. Hits are listed under their tab; Esc clears the search.

## 2.18.3
- Glow on new items: works again in WoW Forever. Uses the game's own list of new items, so everything you just got (looted, bought, traded, mailed) shines, except junk; pointing at it or closing the bags takes the glow away.

## 2.18.2
- Options: the separate "Minimap button" page is gone. The AllInOne button is always there and is collected with the other addons' buttons under "Addon buttons".

## 2.18.1
- Header symbols of the bag windows now sit on small dark slate buttons with a bevelled edge, like Blizzard's own sort button; the edge turns gold under the mouse and while active.

## 2.18.0
- Mail: saved contacts under your characters on the send page. Type a name (or leave it empty to take the one in the "To:" field) and press "+"; a click fills in the recipient, a right click removes the contact. Shared by all your characters.

## 2.17.0
- Bag, bank and guild bank windows: new header symbols (sort, options, bank, keyring, character) as plain pale-gold line icons that glow under the mouse and while active.

## 2.16.0
- Bags: a bank button in the header opens the bank of the same character (live at a banker, otherwise as last seen); it stays lit while the bank is open.

## 2.15.0
- Missing buffs: gathering tracking. Find Minerals, Find Herbs and Find Fish show up while the search of a profession you have is switched off (Find Treasure for dwarves can be switched on). Click to switch it on.

## 2.14.2
- New logo: the AllInOne crest (bag, gold, quest scroll and cogwheel) in the addon list, the options window and on the minimap button.

## 2.14.1
- Releases now carry a release.json that marks them for WoW Forever (for WowUp Hub).

## 2.14.0
- First public release on GitHub / WowUp Hub.
- Reagent bag (WoW Forever): shown as its own block under the bags, with its free slots in the footer; sorted on its own.
- Bank: bank bag slots now start after the reagent bag slot, as WoW Forever counts them.
- Mail helper: the characters list fills in the whole "first last" name.
- Bags, bank and guild bank windows are switched on by default.
- Missing buffs: hold Alt to drag the whole row.
- Danger alarm (formerly "GTFO"): own detection without a spell list, own alarm sounds.
- Fixes for WoW Forever's "secret" values in tooltips and chat, for the minimap button collector and for the druid buff reminder (Omen of Clarity is passive now).
- A right click on an empty part of a window no longer opens the options.

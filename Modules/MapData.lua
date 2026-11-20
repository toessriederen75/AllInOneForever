-- AllInOneForever: zone crossings, flight masters and instance entrances for the world map.
-- Places taken from Leatrix Maps 1.60.35 by Leatrix (WoW Forever), who mapped them
-- first; the code that shows them is our own (Modules/MapInfo.lua).
--   ns.mapArrows[zone]  = { { x, y, destination map, rotation, name, note }, ... }
--   ns.mapFlights[zone] = { { faction (A/H/N), x, y, name }, ... }
--   ns.mapInstances[zone] = { { kind (D dungeon, R raid, B both), x, y, name, note, lowest, highest level }, ... }
-- Positions in percent of the zone map, as the game's coordinates show them.

local ADDON, ns = ...
local L = ns.L

if GetLocale() == "deDE" then
    L["Aerie Peak, The Hinterlands"] = "Aerie Peak, Hinterland"
    L["Alcaz Prison"] = "Gefängnis von Alcaz"
    L["Alterac Mountains"] = "Alteracgebirge"
    L["Arathi Highlands"] = "Arathihochland"
    L["Auberdine, Darkshore"] = "Auberdine, Dunkelküste"
    L["Badlands"] = "Ödland"
    L["Blackfathom Deeps"] = "Blackfathom-Tiefe"
    L["Blackmaw Hold"] = "Die Schwarzschlundfeste"
    L["Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire, |nMolten Core, Blackwing Lair"] = "Schwarzfelstiefen, Untere Schwarzfelsspitze, Obere Schwarzfelsspitze, |nGeschmolzener Kern, Pechschwingenhort"
    L["Blackrock Mountain"] = "Der Blackrock"
    L["Blackrock Pass"] = "Blackrockpass"
    L["Blasted Lands"] = "Verwüstete Lande"
    L["Bloodvenom Post, Felwood"] = "Blutgiftposten, Teufelswald"
    L["Booty Bay, Stranglethorn"] = "Booty Bay, Schlingendorntal"
    L["Brackenwall Village, Dustwallow Marsh"] = "Brackenwall, Düstermarschen"
    L["Burning Steppes"] = "Brennende Steppe"
    L["Camp Taurajo, The Barrens"] = "Camp Taurajo, Das Brachland"
    L["Cenarion Hold, Silithus"] = "Burg Cenarius, Silithus"
    L["Chillwind Camp, Western Plaguelands"] = "Chillwind-Lager, Westliche Pestländer"
    L["City of Dalaran"] = "Dalaran"
    L["Crossroads, The Barrens"] = "Crossroads, Das Brachland"
    L["Darkshire"] = "Dunkelhain"
    L["Darkshire, Duskwood"] = "Dunkelhain, Dämmerwald"
    L["Darkshore"] = "Dunkelküste"
    L["Deadwind Pass"] = "Gebirgspass der Totenwinde"
    L["Dire Maul (East)"] = "Düsterbruch (Ost)"
    L["Dire Maul (North)"] = "Düsterbruch (Nord)"
    L["Dire Maul (West)"] = "Düsterbruch (West)"
    L["Dungeon"] = "Instanz"
    L["Duskwood"] = "Dämmerwald"
    L["Dustwallow Marsh"] = "Düstermarschen"
    L["Eastern Plaguelands"] = "Östliche Pestländer"
    L["Eastvale Logging Camp"] = "Holzfällerlager des Osttals"
    L["Elwynn Forest"] = "Wald von Elwynn"
    L["Excavation Site: Wetlands"] = "Ausgrabungsstätte: Sumpfland"
    L["Faldir's Cove"] = "Die Faldirbucht"
    L["Farholde Keep, Riverglades"] = "Burg Farholde, Flusslande"
    L["Felwood"] = "Teufelswald"
    L["Felwood, Winterspring"] = "Teufelswald, Winterspring"
    L["Flame Crest, Burning Steppes"] = "Flammenkamm, Brennende Steppe"
    L["Follow the eastward path"] = "Folge dem Weg nach Osten"
    L["Follow the westward path"] = "Folge dem Weg nach Westen"
    L["Freewind Post, Thousand Needles"] = "Freiwindposten, Tausend Nadeln"
    L["Grom'gol, Stranglethorn"] = "Grom'gol, Schlingendorntal"
    L["Hillsbrad Foothills"] = "Vorgebirge von Hillsbrad"
    L["Just follow the path west"] = "Folge dem Weg nach Westen"
    L["Kargath, Badlands"] = "Kargath, Ödland"
    L["Krol'dok Stronghold"] = "Feste Krol'dok"
    L["Lakeshire, Redridge"] = "Seenhain, Rotkammgebirge"
    L["Light's Hope Chapel, Eastern Plaguelands"] = "Kapelle des hoffnungsvollen Lichts, Östliche Pestländer"
    L["Marshal's Refuge, Un'Goro Crater"] = "Marshals Zuflucht, Un'Goro-Krater"
    L["Menethil Harbor, Wetlands"] = "Der Hafen von Menethil, Sumpfland"
    L["Morgan's Vigil, Burning Steppes"] = "Morgans Wacht, Brennende Steppe"
    L["Mountain Pass (Horde Only)"] = "Gebirgspass (nur Horde)"
    L["Nethergarde Keep, Blasted Lands"] = "Burg Nethergarde, Verwüstete Lande"
    L["Nijel's Point, Desolace"] = "Die Nijelspitze, Desolace"
    L["North"] = "Norden"
    L["North Gate Pass"] = "Nordtorpass"
    L["North of Twilight's Shroud"] = "Nördlich von Zwielichtschleier"
    L["Onyxia's Lair"] = "Onyxias Hort"
    L["Ragefire Chasm"] = "Ragefireabgrund"
    L["Raid"] = "Schlachtzug"
    L["Ratchet, The Barrens"] = "Ratchet, Das Brachland"
    L["Ravenholdt Manor"] = "Ravenholdt-Anwesen"
    L["Razorfen Downs"] = "Die Hügel von Razorfen"
    L["Razorfen Kraul"] = "Der Kral von Razorfen"
    L["Redridge Mountains"] = "Rotkammgebirge"
    L["Refuge Pointe, Arathi"] = "Die Zuflucht, Arathi"
    L["Requires Key to Searing Gorge"] = "Benötigt Schlüssel für Brennende Schlucht"
    L["Revantusk Village, The Hinterlands"] = "Revantusk, Hinterland"
    L["Riverglades"] = "Flusslande"
    L["Rog'mar, Riverglades"] = "Rog'mar, Flusslande"
    L["Ruins of Ahn'Qiraj, Temple of Ahn'Qiraj"] = "Ruinen von Ahn'Qiraj, Tempel von Ahn'Qiraj"
    L["Rut'theran Village"] = "Rut'theran"
    L["Rut'theran Village, Teldrassil"] = "Rut'theran, Teldrassil"
    L["Scarlet Monastery"] = "Das Scharlachrote Kloster"
    L["Searing Gorge"] = "Sengende Schlucht"
    L["Sentinel Hill, Westfall"] = "Späherkuppe, Westfall"
    L["Shadowfang Keep"] = "Burg Schattenfang"
    L["Shadowprey Village, Desolace"] = "Shadowprey, Desolace"
    L["Shaper's Terrace"] = "Terrasse des Formers"
    L["Silverpine Forest"] = "Silberwald"
    L["South"] = "Süden"
    L["South Gate Pass"] = "Südtorpass"
    L["Splintertree Post, Ashenvale"] = "Splintertreeposten, Ashenvale"
    L["Stonard, Swamp of Sorrows"] = "Stonard, Sümpfe des Elends"
    L["Stonetalon Mountains"] = "Steinkrallengebirge"
    L["Stonetalon Peak, Stonetalon Mountains"] = "Der Steinkrallengipfel, Steinkrallengebirge"
    L["Stormwind City"] = "Sturmwind"
    L["Stranglethorn Vale"] = "Schlingendorntal"
    L["Stratholme (Main Gate)"] = "Stratholme (Haupttor)"
    L["Stratholme (Service Gate)"] = "Stratholme (Dienstbotentor)"
    L["Summit of Eternity, Mount Hyjal"] = "Gipfel der Ewigkeit, Hyjal"
    L["Sun Rock Retreat"] = "Sonnenfels"
    L["Sun Rock Retreat, Stonetalon Mountains"] = "Sonnenfels, Steinkrallengebirge"
    L["Swamp of Sorrows"] = "Sümpfe des Elends"
    L["Tainted Foothills, Mount Hyjal"] = "Besudeltes Vorgebirge, Hyjal"
    L["Talonbranch Glade, Felwood"] = "Nachtlaublichtung, Teufelswald"
    L["Talrendis Point, Azshara"] = "Talrendisspitze, Azshara"
    L["Tarren Mill, Hillsbrad"] = "Tarrens Mühle, Hillsbrad"
    L["Temple of Atal'Hakkar"] = "Tempel von Atal'Hakkar"
    L["Thandol Span"] = "Thandolübergang"
    L["The Barrens"] = "Das Brachland"
    L["The Bulwark"] = "Das Bollwerk"
    L["The Deadmines"] = "Die Todesminen"
    L["The Drowned City"] = "Die Versunkene Stadt"
    L["The Great Lift"] = "Der Große Aufzug"
    L["The Hall of Thanes"] = "Die Halle der Thanen"
    L["The Hinterlands"] = "Hinterland"
    L["The Overlook Cliffs"] = "Die Aussichtsklippen"
    L["The Ruins of Lordaeron"] = "Die Ruinen von Lordaeron"
    L["The Sepulcher, Silverpine Forest"] = "Das Grabmal, Silberwald"
    L["The Stockade"] = "Das Verlies"
    L["The Talondeep Path"] = "Der Steinkrallenpfad"
    L["The Zoram Strand"] = "Der Zoramstrand"
    L["Theramore, Dustwallow Marsh"] = "Theramore, Düstermarschen"
    L["Thorium Point, Searing Gorge"] = "Thoriumspitze, Sengende Schlucht"
    L["Thousand Needles"] = "Tausend Nadeln"
    L["Timbermaw Hold"] = "Holzschlundfeste"
    L["Tirisfal Glades"] = "Tirisfal"
    L["Twilight Shore"] = "Zwielichtufer"
    L["Twilight's Shroud"] = "Zwielichtschleier"
    L["Un'Goro Crater"] = "Un'Goro-Krater"
    L["Wailing Caverns"] = "Die Höhlen des Wehklagens"
    L["Western Plaguelands"] = "Westliche Pestländer"
    L["Wetlands"] = "Sumpfland"
    L["You will die!"] = "Du wirst sterben!"
    L["Zoram'gar Outpost, Ashenvale"] = "Zoram'gar-Außenposten, Ashenvale"
end

ns.mapArrows = {
    [1411] = {
        { 35.1, 42.4, 1413, 1.5, "The Barrens" },
        { 45.5, 12.3, 1454, 0, "Orgrimmar" },
    },
    [1412] = {
        { 64.9, 64, 1413, 4.8, "The Barrens" },
        { 38.4, 40.8, 1456, 0.7, "Thunder Bluff", "South" },
        { 39.5, 29.4, 1456, 3.7, "Thunder Bluff", "North" },
        { 42.3, 29.8, 1456, 2.8, "Thunder Bluff", "North" },
        { 35.5, 36, 1456, 4.3, "Thunder Bluff", "South" },
    },
    [1413] = {
        { 41.2, 58.6, 1412, 1.6, "Mulgore" },
        { 49.8, 78.4, 1445, 4.7, "Dustwallow Marsh" },
        { 44.1, 91.5, 1441, 3, "Thousand Needles", "The Great Lift" },
        { 36.3, 27.5, 1442, 1.5, "Stonetalon Mountains" },
        { 48.8, 7.1, 1440, 0, "Ashenvale" },
        { 62.6, 19.2, 1411, 4.6, "Durotar" },
    },
    [1416] = {
        { 80.7, 34.2, 1422, 0, "Western Plaguelands" },
        { 51.8, 68.8, 1424, 3, "Hillsbrad Foothills" },
        { 81.7, 77.5, 1424, 2.2, "Hillsbrad Foothills", "Ravenholdt Manor" },
    },
    [1417] = {
        { 45.4, 88.9, 1437, 3.2, "Wetlands", "Thandol Span" },
        { 20.9, 30.6, 1424, 1, "Hillsbrad Foothills" },
        { 29.6, 67.5, 1417, 1.9, "Faldir's Cove", "Just follow the path west" },
    },
    [1418] = {
        { 51.1, 14.8, 1432, 0.8, "Loch Modan" },
        { 5.3, 61.1, 1427, 1.5, "Searing Gorge" },
        { 54.8, 92.5, 2548, 3.1, "Riverglades", "Twilight's Shroud" },
    },
    [1419] = {
        { 52.2, 10.7, 1435, 0, "Swamp of Sorrows" },
    },
    [1420] = {
        { 83.4, 70.6, 1422, 4.7, "Western Plaguelands", "The Bulwark" },
        { 61.9, 65, 1458, 3, "Undercity" },
        { 54.9, 72.7, 1421, 3, "Silverpine Forest" },
    },
    [1421] = {
        { 66.3, 79.8, 1424, 4.3, "Hillsbrad Foothills" },
        { 67.7, 5, 1420, 5.7, "Tirisfal Glades" },
    },
    [1422] = {
        { 44.1, 87.1, 1416, 3, "Alterac Mountains" },
        { 28.6, 57.5, 1420, 1.6, "Tirisfal Glades", "The Bulwark" },
        { 69.7, 50.3, 1423, 4.7, "Eastern Plaguelands" },
        { 65.3, 86.4, 1425, 3, "The Hinterlands" },
    },
    [1423] = {
        { 11.8, 61.5, 1422, 1.6, "Western Plaguelands" },
    },
    [1424] = {
        { 84.6, 31.8, 1425, 5.4, "The Hinterlands" },
        { 54.8, 11.3, 1416, 0, "Alterac Mountains" },
        { 13.7, 46.2, 1421, 1.5, "Silverpine Forest" },
        { 81, 56.1, 1417, 4.1, "Arathi Highlands" },
        { 75.5, 24.6, 1416, 0, "Alterac Mountains", "Ravenholdt Manor" },
    },
    [1425] = {
        { 24.1, 30.4, 1422, 0, "Western Plaguelands" },
        { 6.4, 61.5, 1424, 2.3, "Hillsbrad Foothills" },
        { 70.6, 63.7, 1425, 4.1, "The Overlook Cliffs", "Follow the westward path" },
        { 76.9, 61, 1425, 1.8, "The Hinterlands", "Follow the eastward path" },
    },
    [1426] = {
        { 84.3, 31.1, 1432, 0, "Loch Modan", "North Gate Pass" },
        { 82.2, 53.5, 1432, 5, "Loch Modan", "South Gate Pass" },
        { 30.5, 34.5, 1437, 6.2, "Wetlands", "You will die!" },
        { 53.3, 35.1, 1455, 5.4, "Ironforge" },
    },
    [1427] = {
        { 78.5, 17.4, 1432, 5.4, "Loch Modan", "Requires Key to Searing Gorge" },
        { 33.6, 79, 1428, 3, "Burning Steppes", "Blackrock Mountain" },
        { 68.8, 53.9, 1418, 4.5, "Badlands" },
    },
    [1428] = {
        { 78.3, 77.8, 1433, 3.3, "Redridge Mountains" },
        { 31.9, 50.4, 1427, 0.8, "Searing Gorge", "Blackrock Mountain" },
    },
    [1429] = {
        { 21, 79.6, 1436, 2.2, "Westfall" },
        { 93.2, 72.3, 1433, 4.7, "Redridge Mountains" },
        { 32.2, 49.7, 1453, 0.6, "Stormwind City" },
    },
    [1430] = {
        { 32, 35.3, 1431, 1.5, "Duskwood" },
        { 58.8, 42.2, 1435, 5.2, "Swamp of Sorrows" },
    },
    [1431] = {
        { 7.9, 63.8, 1436, 1.7, "Westfall" },
        { 44.6, 87.9, 1434, 3, "Stranglethorn Vale" },
        { 94.2, 10.3, 1433, 5.8, "Redridge Mountains" },
        { 88.4, 40.9, 1430, 4.6, "Deadwind Pass" },
    },
    [1432] = {
        { 18.4, 83, 1427, 2.6, "Searing Gorge", "Requires Key to Searing Gorge" },
        { 20.4, 17.4, 1426, 1.1, "Dun Morogh", "North Gate Pass" },
        { 46.8, 76.9, 1418, 3.2, "Badlands" },
        { 21.5, 66.2, 1426, 0.5, "Dun Morogh", "South Gate Pass" },
        { 25.4, 10.9, 1437, 0.1, "Wetlands", "Dun Algaz" },
    },
    [1433] = {
        { 2.2, 90.6, 1431, 2.4, "Duskwood", "Darkshire" },
        { 3, 72.3, 1429, 1.65, "Elwynn Forest", "Eastvale Logging Camp" },
        { 41.7, 7.1, 1428, 0, "Burning Steppes", "Blackrock Pass" },
        { 44.8, 9.8, 2548, 5.5, "Riverglades", "Blackrock Pass" },
        { 66.4, 18.6, 2548, 0.3, "Riverglades", "Redridge Pass" },
        { 96.5, 70.1, 1435, 2.7, "Swamp of Sorrows", "Redridge Pass" },
    },
    [1434] = {
        { 39.2, 6.5, 1431, 0, "Duskwood" },
    },
    [1435] = {
        { 3.7, 61.1, 1430, 1.5, "Deadwind Pass" },
        { 33.4, 74.8, 1419, 3.1, "Blasted Lands" },
    },
    [1436] = {
        { 62, 17.9, 1429, 5.4, "Elwynn Forest" },
        { 67.9, 62.8, 1431, 4.7, "Duskwood" },
    },
    [1437] = {
        { 51.3, 10.3, 1417, 0, "Arathi Highlands", "Thandol Span" },
        { 56, 70.3, 1432, 1.8, "Loch Modan", "Dun Algaz" },
    },
    [1438] = {
        { 55.9, 89.7, 1457, 0.3, "Darnassus" },
        { 36.2, 54.4, 1457, 1.5, "Darnassus" },
    },
    [1439] = {
        { 43.3, 94, 1440, 4, "Ashenvale" },
        { 37.5, 94.8, 1440, 3.1, "Ashenvale" },
        { 27.7, 92.9, 1440, 2.5, "Ashenvale", "The Zoram Strand" },
    },
    [1440] = {
        { 29.1, 14.8, 1439, 0, "Darkshore" },
        { 42.3, 71.1, 1442, 2.7, "Stonetalon Mountains", "The Talondeep Path" },
        { 55.8, 30.2, 1448, 0, "Felwood" },
        { 94.2, 47.3, 1447, 4.4, "Azshara" },
        { 68.6, 86.8, 1413, 3.2, "The Barrens" },
        { 20.6, 16.1, 1439, 6.1, "Darkshore" },
        { 9.5, 10.7, 1439, 5.3, "Darkshore", "Twilight Shore" },
    },
    [1441] = {
        { 74.9, 93.3, 1446, 3.2, "Tanaris" },
        { 8.3, 11.9, 1444, 0.7, "Feralas" },
        { 32.2, 23.9, 1413, 5.4, "The Barrens", "The Great Lift" },
    },
    [1442] = {
        { 80.2, 92.4, 1413, 3.4, "The Barrens" },
        { 30.4, 75.4, 1443, 2.7, "Desolace" },
        { 78.2, 42.8, 1440, 6.1, "Ashenvale", "The Talondeep Path" },
        { 37.9, 67.8, 1442, 4.1, "Sun Rock Retreat", "Mountain Pass (Horde Only)" },
    },
    [1443] = {
        { 53.4, 5.9, 1442, 5.9, "Stonetalon Mountains" },
        { 41.6, 94.4, 1444, 3.3, "Feralas" },
    },
    [1444] = {
        { 44.9, 7.7, 1443, 6, "Desolace" },
        { 88.7, 41.1, 1441, 4.5, "Thousand Needles" },
    },
    [1445] = {
        { 30, 47.1, 1413, 1.6, "The Barrens" },
    },
    [1446] = {
        { 50.6, 24.4, 1441, 5.7, "Thousand Needles" },
        { 27.1, 57.7, 1449, 0.5, "Un'Goro Crater" },
    },
    [1447] = {
        { 10.6, 75.3, 1440, 0.9, "Ashenvale" },
    },
    [1448] = {
        { 65, 8.3, 1452, 5.9, "Winterspring", "Timbermaw Hold" },
        { 54.5, 89.2, 1440, 3, "Ashenvale" },
    },
    [1449] = {
        { 70.5, 78.6, 1446, 3.3, "Tanaris" },
        { 29.4, 22.3, 1451, 0.9, "Silithus" },
    },
    [1450] = {
        { 35.7, 72.4, 1448, 3, "Felwood, Winterspring", "Timbermaw Hold" },
    },
    [1451] = {
        { 82.4, 16, 1449, 5.4, "Un'Goro Crater" },
    },
    [1452] = {
        { 27.9, 34.5, 1448, 0.7, "Felwood", "Timbermaw Hold" },
    },
    [1453] = {
        { 74.5, 92.3, 1429, 3.8, "Elwynn Forest" },
    },
    [1454] = {
        { 52.4, 83.7, 1411, 3, "Durotar" },
        { 18.1, 60.6, 1413, 2.1, "The Barrens" },
    },
    [1455] = {
        { 21.9, 77.5, 1426, 2.2, "Dun Morogh" },
    },
    [1456] = {
        { 35.7, 62.8, 1412, 2, "Mulgore", "South" },
        { 51.3, 31.3, 1412, 5.7, "Mulgore", "North" },
    },
    [1457] = {
        { 30.3, 41.4, 1438, 1.5, "Teldrassil", "Rut'theran Village" },
        { 86.9, 35.8, 1438, 4.8, "Teldrassil" },
    },
    [1458] = {
        { 66.2, 5.2, 1420, 0, "Tirisfal Glades" },
    },
    [2548] = {
        { 32, 30.2, 1418, 0, "Badlands", "North of Twilight's Shroud" },
        { 16.3, 69, 1433, 1.8, "Redridge Mountains", "Blackrock Pass" },
        { 25.3, 72.8, 1433, 3.2, "Redridge Mountains", "Redridge Pass" },
    },
}

ns.mapInstances = {
    [1413] = {
        { "D", 46, 36.4, "Wailing Caverns", "Dungeon", 17, 24 },
        { "D", 42.9, 90.2, "Razorfen Kraul", "Dungeon", 29, 38 },
        { "D", 49, 93.9, "Razorfen Downs", "Dungeon", 37, 46 },
    },
    [1416] = {
        { "D", 8.5, 59.3, "City of Dalaran", "Dungeon", 28, 33 },
    },
    [1418] = {
        { "D", 44.6, 12.1, "Uldaman", "Dungeon", 41, 51 },
    },
    [1420] = {
        { "D", 82.6, 33.8, "Scarlet Monastery", "Dungeon", 34, 45 },
    },
    [1421] = {
        { "D", 44.8, 67.8, "Shadowfang Keep", "Dungeon", 22, 30 },
    },
    [1422] = {
        { "D", 69.7, 73.2, "Scholomance", "Dungeon", 58, 60 },
    },
    [1423] = {
        { "D", 27.8, 11.6, "Stratholme (Main Gate)", "Dungeon", 58, 60 },
        { "D", 43.6, 19.5, "Stratholme (Service Gate)", "Dungeon", 58, 60 },
        { "R", 33.7, 20.7, "Naxxramas", "Raid", 60, 60 },
    },
    [1426] = {
        { "D", 24.3, 39.8, "Gnomeregan", "Dungeon", 29, 38 },
    },
    [1427] = {
        { "B", 34.8, 85.3, "Blackrock Mountain", "Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire, |nMolten Core, Blackwing Lair", 52, 60 },
    },
    [1428] = {
        { "B", 29.4, 38.3, "Blackrock Mountain", "Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire, |nMolten Core, Blackwing Lair", 52, 60 },
    },
    [1434] = {
        { "R", 53.9, 17.6, "Zul'Gurub", "Raid", 60, 60 },
        { "D", 21.3, 27.8, "The Drowned City", "Dungeon", 35, 40 },
    },
    [1435] = {
        { "D", 69.9, 53.6, "Temple of Atal'Hakkar", "Dungeon", 50, 60 },
    },
    [1436] = {
        { "D", 42.5, 71.7, "The Deadmines", "Dungeon", 17, 26 },
    },
    [1437] = {
        { "D", 47.8, 56.2, "Excavation Site: Wetlands", "Dungeon", 24, 29 },
    },
    [1440] = {
        { "D", 14.5, 14.2, "Blackfathom Deeps", "Dungeon", 24, 32 },
    },
    [1443] = {
        { "D", 29.1, 62.5, "Maraudon", "Dungeon", 46, 55 },
    },
    [1444] = {
        { "D", 62.5, 24.9, "Dire Maul (North)", "Dungeon", 56, 60 },
        { "D", 60.3, 30.2, "Dire Maul (West)", "Dungeon", 56, 60 },
        { "D", 64.8, 30.2, "Dire Maul (East)", "Dungeon", 56, 60 },
    },
    [1445] = {
        { "D", 75.3, 14.1, "Alcaz Prison", "Dungeon", 48, 53 },
        { "R", 52.6, 76.8, "Onyxia's Lair", "Raid", 60, 60 },
    },
    [1446] = {
        { "D", 38.7, 20, "Zul'Farrak", "Dungeon", 44, 54 },
    },
    [1447] = {
        { "D", 38.6, 33.2, "Blackmaw Hold", "Dungeon", 55, 60 },
    },
    [1449] = {
        { "D", 48.1, 6.1, "Shaper's Terrace", "Dungeon", 58, 60 },
    },
    [1451] = {
        { "R", 28.6, 92.4, "Ahn'Qiraj", "Ruins of Ahn'Qiraj, Temple of Ahn'Qiraj", 60, 60 },
    },
    [1453] = {
        { "D", 52.4, 70, "The Stockade", "Dungeon", 22, 30 },
    },
    [1454] = {
        { "D", 52.6, 49, "Ragefire Chasm", "Dungeon", 13, 18 },
    },
    [1455] = {
        { "D", 27.7, 47.9, "The Hall of Thanes", "Dungeon", 13, 18 },
    },
    [1458] = {
        { "D", 72.5, 11.4, "The Ruins of Lordaeron", "Dungeon", 15, 20 },
    },
    [2548] = {
        { "D", 37.5, 37.3, "Krol'dok Stronghold", "Dungeon", 40, 45 },
    },
}

ns.mapFlights = {
    [1413] = {
        { "H", 44.5, 59.1, "Camp Taurajo, The Barrens" },
        { "H", 51.5, 30.4, "Crossroads, The Barrens" },
        { "N", 63.1, 37.1, "Ratchet, The Barrens" },
    },
    [1417] = {
        { "A", 45.8, 46.1, "Refuge Pointe, Arathi" },
        { "H", 73.1, 32.6, "Hammerfall, Arathi" },
    },
    [1418] = {
        { "H", 4.1, 44.9, "Kargath, Badlands" },
    },
    [1419] = {
        { "A", 65.5, 24.4, "Nethergarde Keep, Blasted Lands" },
    },
    [1421] = {
        { "H", 45.6, 42.4, "The Sepulcher, Silverpine Forest" },
    },
    [1422] = {
        { "A", 42.9, 85, "Chillwind Camp, Western Plaguelands" },
    },
    [1423] = {
        { "A", 71.7, 49.6, "Light's Hope Chapel, Eastern Plaguelands" },
        { "H", 70.4, 47.6, "Light's Hope Chapel, Eastern Plaguelands" },
    },
    [1424] = {
        { "A", 49.4, 52.1, "Southshore, Hillsbrad" },
        { "H", 60.2, 18.8, "Tarren Mill, Hillsbrad" },
    },
    [1425] = {
        { "A", 11.1, 46.1, "Aerie Peak, The Hinterlands" },
        { "H", 81.7, 81.9, "Revantusk Village, The Hinterlands" },
    },
    [1427] = {
        { "A", 37.9, 30.4, "Thorium Point, Searing Gorge" },
        { "H", 34.8, 30.6, "Thorium Point, Searing Gorge" },
    },
    [1428] = {
        { "A", 84.4, 68.3, "Morgan's Vigil, Burning Steppes" },
        { "H", 65.6, 24.2, "Flame Crest, Burning Steppes" },
    },
    [1431] = {
        { "A", 77.6, 44.4, "Darkshire, Duskwood" },
    },
    [1432] = {
        { "A", 33.9, 50.8, "Thelsamar, Loch Modan" },
    },
    [1433] = {
        { "A", 25.3, 59, "Lakeshire, Redridge" },
    },
    [1434] = {
        { "A", 27.5, 77.7, "Booty Bay, Stranglethorn" },
        { "H", 26.8, 77, "Booty Bay, Stranglethorn" },
        { "H", 32.5, 29.3, "Grom'gol, Stranglethorn" },
    },
    [1435] = {
        { "H", 46.1, 54.7, "Stonard, Swamp of Sorrows" },
    },
    [1436] = {
        { "A", 56.6, 52.7, "Sentinel Hill, Westfall" },
    },
    [1437] = {
        { "A", 9.5, 59.7, "Menethil Harbor, Wetlands" },
    },
    [1438] = {
        { "A", 58.4, 93.9, "Rut'theran Village, Teldrassil" },
    },
    [1439] = {
        { "A", 36.4, 45.6, "Auberdine, Darkshore" },
    },
    [1440] = {
        { "A", 34.5, 48, "Astranaar, Ashenvale" },
        { "H", 73.3, 61.7, "Splintertree Post, Ashenvale" },
        { "H", 12.2, 33.8, "Zoram'gar Outpost, Ashenvale" },
    },
    [1441] = {
        { "H", 45, 49.1, "Freewind Post, Thousand Needles" },
    },
    [1442] = {
        { "A", 36.5, 7.2, "Stonetalon Peak, Stonetalon Mountains" },
        { "H", 45.2, 59.9, "Sun Rock Retreat, Stonetalon Mountains" },
    },
    [1443] = {
        { "A", 64.7, 10.4, "Nijel's Point, Desolace" },
        { "H", 21.6, 74, "Shadowprey Village, Desolace" },
    },
    [1444] = {
        { "A", 30.3, 43.3, "Feathermoon, Feralas" },
        { "A", 89.5, 45.9, "Thalanaar, Feralas" },
        { "H", 75.4, 44.3, "Camp Mojache, Feralas" },
    },
    [1445] = {
        { "A", 67.5, 51.2, "Theramore, Dustwallow Marsh" },
        { "H", 35.6, 31.8, "Brackenwall Village, Dustwallow Marsh" },
    },
    [1446] = {
        { "A", 51, 29.3, "Gadgetzan, Tanaris" },
        { "H", 51.6, 25.5, "Gadgetzan, Tanaris" },
    },
    [1447] = {
        { "A", 11.9, 77.5, "Talrendis Point, Azshara" },
        { "H", 22, 49.7, "Valormok, Azshara" },
    },
    [1448] = {
        { "A", 62.5, 24.2, "Talonbranch Glade, Felwood" },
        { "H", 34.4, 53.9, "Bloodvenom Post, Felwood" },
    },
    [1449] = {
        { "N", 45.3, 6, "Marshal's Refuge, Un'Goro Crater" },
    },
    [1450] = {
        { "A", 47.9, 67.1, "Moonglade" },
        { "H", 32.2, 66.3, "Moonglade" },
    },
    [1451] = {
        { "A", 50.7, 34.6, "Cenarion Hold, Silithus" },
        { "H", 48.8, 36.7, "Cenarion Hold, Silithus" },
    },
    [1452] = {
        { "A", 62.3, 36.6, "Everlook, Winterspring" },
        { "H", 60.5, 36.3, "Everlook, Winterspring" },
    },
    [1453] = {
        { "A", 71.6, 72.3, "Stormwind, Elwynn" },
    },
    [1454] = {
        { "H", 45.3, 63.7, "Orgrimmar, Durotar" },
    },
    [1455] = {
        { "A", 55.9, 47.9, "Ironforge, Dun Morogh" },
    },
    [1456] = {
        { "H", 46.7, 49.9, "Thunder Bluff, Mulgore" },
    },
    [1458] = {
        { "H", 63.1, 48.3, "Undercity, Tirisfal" },
    },
    [2482] = {
        { "N", 68.6, 44.1, "Summit of Eternity, Mount Hyjal" },
        { "N", 55.1, 82.5, "Tainted Foothills, Mount Hyjal" },
    },
    [2548] = {
        { "A", 60.6, 81.6, "Farholde Keep, Riverglades" },
        { "H", 59.6, 45.1, "Rog'mar, Riverglades" },
    },
}

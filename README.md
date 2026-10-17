# Atlas Plus

**Instance maps with every boss and its loot.** For World of Warcraft 3.3.5a (Wrath of the Lich King).

Version 1.10.1 · For World of Warcraft 3.3.5a (Wrath of the Lich King)

Atlas Plus puts the world map, the map of every dungeon and raid, their bosses and everything they drop in one clean window, and opens on the right map by itself. It also replaces map marker addons and removes the fog of war.

- **Localization / Локализация**: English and Russian (`enUS` / `ruRU`) supported natively.
- **Opens where you are**: in a dungeon or raid, on its map (and the right wing of Ulduar, Icecrown Citadel, Karazhan, Dire Maul...) with the loot of your difficulty. Outdoors, on the world map, on your zone.
- **Every instance**: Classic, Burning Crusade and Wrath dungeons and raids, plus entrance maps and dungeon locations.
- **Every boss and its loot**: Normal / Heroic, 10 / 25 / 10 Heroic / 25 Heroic, drop chance of each item ("2x" when two drop at once, like emblems), Ulduar hard modes, Alliance / Horde only items, chests, and trash drops. Class items (Vault of Archavon PvP sets, tier pieces...) are in a folded list per class (yours open).
- **World drops**: their own lists in the left panel (Classic, Burning Crusade, Wrath): rare and epic items and recipes any creature of the right level can drop, with the creature levels and the chance per kill.
- **World events**: Hallow's End, Brewfest, Love is in the Air, Midsummer, Winter Veil, Lunar Festival, Noblegarden, Children's Week, Pilgrim's Bounty, Darkmoon Faire and more: the holiday bosses and their reward bags, the event vendors with their prices, and the quest rewards.
- **Vendors**: what you can buy with each currency (badges and emblems, Stone Keeper's Shards, Champion's Seals, honor and arena points, battleground marks, Wintergrasp marks...), vendor by vendor with its zone and the price of every item.
- **Search** instances (also by short name and Russian acronyms: ICC / ЦЛК, Uld / Ульда, EoE / Око, VoA / СА...), bosses, events, vendors and items: every result says where the item comes from (boss, world drop, vendor or quest).
- **World map in the same window**: the map key (M) opens Atlas Plus with the game's own map inside, so quest objectives and Questie keep working. Zone levels, instances and fishing skill, clickable instance icons, coordinates.
- **Map markers**: dungeons, raids, world bosses, boats, zeppelins, the Deeprun Tram and portals. Click a transport or portal to go to where it leads. Filter them, or find any of them in a list.
- **No fog of war**: unexplored areas are shown (a bit darker, optional).

---

## Install

1. Download the repository archive.
2. Put the `AtlasPlus` folder into your `Interface\AddOns\` directory.
3. Keep the folder name as `AtlasPlus`.

---

## Commands

| Command | Action |
| --- | --- |
| `/ap` | Open / close |
| `/ap here` | The map of where you are |
| `/ap world` | The world map page |
| `/ap search <text>` | Search instances, bosses and the loot of every instance |
| `/ap settings` | Settings |
| `/ap reset` | Window position, size and opacity |

---

## About the data

- **Maps and legends**: [Atlas](http://www.atlasmod.com) by Dan Gilbert and contributors, released under the GNU GPL v2.
- **Loot and drop chances**: Standard 3.3.5a database ([wowroad.info](https://wowroad.info/)).
- **Zone levels and instances**: LibTourist-3.0 (MIT, ckknight and Arrowmaster).
- **Localization**: Supports English (`enUS`/`enGB`) and Russian (`ruRU`).

local ADDON_NAME, addon = ...
if GetLocale() ~= "ruRU" then return end

local AP = AtlasPlus
local L = AP.L

-- Categories
L["Classic Dungeons"] = "Подземелья Classic"
L["Classic Raids"] = "Рейды Classic"
L["Burning Crusade Dungeons"] = "Подземелья Burning Crusade"
L["Burning Crusade Raids"] = "Рейды Burning Crusade"
L["Wrath of the Lich King Dungeons"] = "Подземелья Wrath of the Lich King"
L["Wrath of the Lich King Raids"] = "Рейды Wrath of the Lich King"
L["World Drops"] = "Мировая добыча"
L["World Events"] = "Игровые события"
L["Vendors"] = "Торговцы"
L["Entrances"] = "Входы"
L["Dungeon Locations"] = "Расположение подземелий"

-- Modes
L["Normal"] = "Обычный"
L["Heroic"] = "Героический"
L["10 Heroic"] = "10 гер."
L["25 Heroic"] = "25 гер."

-- Classes
L["Warrior"] = "Воин"
L["Paladin"] = "Паладин"
L["Hunter"] = "Охотник"
L["Rogue"] = "Разбойник"
L["Priest"] = "Жрец"
L["Death Knight"] = "Рыцарь смерти"
L["Shaman"] = "Шаман"
L["Mage"] = "Маг"
L["Warlock"] = "Чернокнижник"
L["Druid"] = "Друид"

-- Top bar & tabs
L["World map"] = "Карта мира"
L["Atlas"] = "Атлас"
L["Game map"] = "Игровая карта"
L["Settings"] = "Настройки"
L["Search an instance, a boss or loot..."] = "Поиск подземелья, босса или добычи..."

-- Map header & instance info
L["Level %s"] = "Уровень %s"
L["min. %s"] = "мин. %s"
L["%d players"] = "%d игроков"
L["Entrance map"] = "Карта входа"
L["Instances"] = "Подземелья"

-- Instance list bar
L["Drag: list wider or narrower"] = "Потяните: изменить ширину списка"
L["Right-click: back to the first width"] = "Правый клик: сброс ширины списка"

-- Legend & loot panel
L["Click a boss (|r%s>|r|cff888888) to see its loot|r"] = "Нажмите на босса (|r%s>|r|cff888888), чтобы увидеть добычу|r"
L["Click a list (|r%s>|r|cff888888) to see its items|r"] = "Нажмите на строку (|r%s>|r|cff888888), чтобы увидеть список|r"
L["Trash mobs"] = "Обычные монстры"
L["loot >"] = "добыча >"
L["Items for this class"] = "Предметы для этого класса"
L["Click: fold"] = "Клик: свернуть"
L["Click: open"] = "Клик: развернуть"
L["Click: open this map"] = "Клик: открыть эту карту"
L["Click: see its loot"] = "Клик: посмотреть добычу"
L["Drop chance: %s%%"] = "Шанс выпадения: %s%%"
L["(hard mode)"] = "(сложный режим)"
L["Cost: free"] = "Цена: бесплатно"
L["Cost: "] = "Цена: "
L["Sold by: %s"] = "Продавец: %s"
L["Quest reward: %s"] = "Награда за задание: %s"
L["Quest"] = "Задание"
L["World drop: creatures of level %s can drop this."] = "Мировая добыча: падает с существ %s уровня."
L["Alliance only"] = "Только Альянс"
L["Horde only"] = "Только Орда"
L["Requires a personal arena rating of %d"] = "Требуется личный рейтинг арены: %d"
L["Type at least 2 letters."] = "Введите не менее 2 букв."
L["No loot for this mode."] = "Нет добычи для этого режима."
L["Nothing found."] = "Ничего не найдено."
L["Nothing on this continent."] = "Ничего нет на этом континенте."
L["Click a result to open its boss.  Shift-click: link in chat.  Ctrl-click: try on."] = "Нажмите на результат, чтобы перейти к боссу. Shift-клик: ссылка в чат. Ctrl-клик: примерка."
L["Prices from the game data.  Shift-click: link.  Ctrl-click: try on."] = "Цены из игровых данных. Shift-клик: ссылка в чат. Ctrl-клик: примерка."
L["Chances per kill, for a typical creature of the level.  Lx-y = creature levels.  Shift-click: link."] = "Шанс выпадения с типичного существа данного уровня. Lу-у = уровни существ. Shift-клик: ссылка в чат."
L["Drop chances from the 3.3.5a database (the server can differ).  HM = hard mode.  |cff4a9effA|r / |cffff4a4aH|r = Alliance / Horde only.  Shift-click: link.  Ctrl-click: try on."] = "Шансы выпадения по базе 3.3.5a (на сервере могут отличаться). HM = сложный режим. |cff4a9effA|r / |cffff4a4aH|r = только Альянс / Орда. Shift-клик: ссылка. Ctrl-клик: примерка."

-- Search count strings
L["%d instance"] = "%d подземелье"
L["%d instances"] = "%d подземелий"
L["%d boss"] = "%d босс"
L["%d bosses"] = "%d боссов"
L["%d item"] = "%d предмет"
L["%d items"] = "%d предметов"
L["%d list"] = "%d список"
L["%d lists"] = "%d списков"
L[" found"] = " найдено"
L[" (first 200)"] = " (первые 200)"

-- Settings: columns
L["Window"] = "Окно"
L["Map markers"] = "Метки на карте"

-- Settings: column 1 (Window)
L["Open on the map of where you are"] = "Открывать карту текущей локации"
L["In a dungeon or raid: its map and wing, with the loot of your difficulty. Outdoors: the world map, on your zone."] = "В подземелье/рейде: его карта и крыло с добычей для вашей сложности. В открытом мире: карта вашей зоны."
L["Open by itself in dungeons and raids"] = "Автоматически открывать в подземельях и рейдах"
L["Minimap button"] = "Кнопка у миникарты"
L["Lock the window"] = "Закрепить окно"
L["It can't be moved by its title bar."] = "Запрещает перемещение окна за заголовок."
L["Fade while moving"] = "Прозрачность при движении"
L["See-through while you move, unless the mouse is over it."] = "Делает окно полупрозрачным во время движения персонажа (если курсор не наведен)."
L["Opacity while moving"] = "Прозрачность в движении"
L["Window size"] = "Размер окна"
L["Window opacity"] = "Прозрачность окна"
L["Move the window: drag its title. Resize it: drag its bottom right corner."] = "Перемещение: за заголовок. Изменение размера: за правый нижний угол."

-- Settings: column 2 (World map)
L["The map key (M) opens Atlas Plus"] = "Клавиша карты (M) открывает Atlas Plus"
L["The game's map opens inside Atlas Plus, quests and map addons included. Untick to get the game's map back on M."] = "Стандартная карта открывается внутри Atlas Plus вместе с заданиями и аддонами. Снимите галочку, чтобы вернуть стандартную карту на клавишу M."
L["Game instance maps"] = "Игровые карты подземелий"
L["In a dungeon or raid with a game map (Ulduar, Icecrown Citadel...): open it, on your floor. The Atlas map stays in the Atlas tab."] = "В подземельях со встроенной картой (Ульдуар, ЦЛК и др.): открывать ее на вашем этаже. Карта Atlas останется на вкладке «Атлас»."
L["No fog of war"] = "Открыть туман войны"
L["Show the areas you have not explored yet."] = "Отображать еще не исследованные области на карте."
L["Darken unexplored areas"] = "Затемнять неисследованные зоны"
L["So you can still tell them apart."] = "Позволяет легко отличить неисследованные области от открытых."
L["Zone panel (top left of the map)"] = "Панель зоны (вверху слева на карте)"
L["Zone info under the cursor"] = "Информация о зоне под курсором"
L["Coordinates (yours and the cursor's)"] = "Координаты игрока и курсора"
L["Quest icon size"] = "Размер значков заданий"
L["Game map opacity"] = "Прозрачность игровой карты"
L["Game small map size"] = "Размер малой игровой карты"
L["These two: the game's map opened on its own (Game map button)."] = "Эти две настройки действуют при открытии карты отдельно (кнопка «Игровая карта»)."

-- Settings: column 3 (Map markers)
L["Dungeons (blue)"] = "Подземелья (синие)"
L["Raids (green)"] = "Рейды (зеленые)"
L["World bosses"] = "Мировые боссы"
L["Portals"] = "Порталы"
L["Boats"] = "Корабли"
L["Zeppelins"] = "Дирижабли"
L["Deeprun Tram"] = "Подземный поезд"
L["Flight masters"] = "Распорядители полетов"
L["Innkeepers"] = "Хозяева таверн"
L["Mailboxes"] = "Почтовые ящики"
L["Banks"] = "Банки"
L["Auction houses"] = "Аукционные дома"
L["Markers on continent maps"] = "Метки на картах континентов"
L["Not the town ones (flight masters, inns...)."] = "Кроме городских (полетов, таверн и т.д.)."
L["Hide Questie's dungeon and raid icons"] = "Скрывать значки Questie для подземелий/рейдов"
L["While the Atlas Plus ones are on. They come back when you turn these off."] = "Пока включены значки Atlas Plus, чтобы избежать дублирования. При отключении значки Questie вернутся."
L["Only my faction's"] = "Только для моей фракции"
L["Transports, portals and town markers. Neutral ones always show."] = "Транспорт, порталы и городские метки. Нейтральные отображаются всегда."
L["Marker size"] = "Размер меток"
L["Town marker size"] = "Размер городских меток"

-- Settings credits
L["Atlas Plus %s (Circle Edition) by Saranwrap & dadec666. Instance maps and legends from Atlas (GPL v2). Zone levels from LibTourist-3.0 (MIT). Database aligned with wowroad.info.\n/ap - open / close     /ap here - map of where you are     /ap world - world map     /ap search <item>     /ap reset - window position and size"] = "Atlas Plus %s [Circle Edition] (авторы: Saranwrap, dadec666). Карты подземелий и описания из Atlas (GPL v2). Уровни зон из LibTourist-3.0 (MIT). База данных согласована с wowroad.info.\n/ap — открыть/закрыть   /ap here — карта вашей локации   /ap world — карта мира   /ap search <текст>   /ap reset — сброс окна"

-- Interface options panel
L["Open Atlas Plus"] = "Открыть Atlas Plus"
L["Instance maps with every boss and its loot, item search, and world map zone info.\n\n/ap - open / close     /ap here - map of where you are     /ap settings"] = "Карты подземелий со всеми боссами и добычей, поиск предметов и информация о зонах карты мира.\n\n/ap — открыть / закрыть   /ap here — карта текущей локации   /ap settings — настройки"

-- World Map coords & combat notice
L["Player"] = "Игрок"
L["Cursor"] = "Курсор"
L["Map controls disabled in combat"] = "Управление картой отключено в бою"
L["could not %s the game's map (%s). It opens on its own instead; please report this message."] = "не удалось %s игровую карту (%s). Она откроется отдельно."

-- Markers
L["Dungeon"] = "Подземелье"
L["Raid"] = "Рейд"
L["World boss"] = "Мировой босс"
L["Boat"] = "Корабль"
L["Zeppelin"] = "Дирижабль"
L["Tram"] = "Поезд"
L["Portal"] = "Портал"
L["Click: map, bosses and loot"] = "Клик: карта, боссы и добыча"
L["Click: go to %s"] = "Клик: перейти к %s"
L["Show on the map"] = "Показывать на карте"
L["Transports and portals"] = "Транспорт и порталы"
L["Only my faction's"] = "Только моей фракции"
L["Find on the map"] = "Найти на карте"
L["Search a name or a zone..."] = "Поиск по названию или зоне..."
L["All"] = "Все"
L["Dungeons"] = "Подземелья"
L["Raids"] = "Рейды"
L["Bosses"] = "Боссы"
L["Boats"] = "Корабли"
L["Zeppelins"] = "Дирижабли"
L["Portals"] = "Порталы"

-- Slash commands & bindings
L["Open / close Atlas Plus"] = "Открыть / закрыть Atlas Plus"
L["Window position, size and opacity reset."] = "Положение, размер и прозрачность окна сброшены."
L["/ap - open / close    /ap here - map of where you are    /ap world - world map    /ap search <item>    /ap settings    /ap reset"] = "/ap — открыть / закрыть    /ap here — карта текущей локации    /ap world — карта мира    /ap search <текст>    /ap settings — настройки    /ap reset — сброс окна"

-- World Events (wowroad.info)
L["World Event: Brewfest"] = "Игровое событие: Хмельной фестиваль"
L["Brewfest"] = "Хмельной фестиваль"
L["World Event: Children's Week"] = "Игровое событие: Детская неделя"
L["Children's Week"] = "Детская неделя"
L["World Event: Darkmoon Faire"] = "Игровое событие: Ярмарка Новолуния"
L["Darkmoon Faire"] = "Ярмарка Новолуния"
L["World Event: Day of the Dead"] = "Игровое событие: День мертвых"
L["Day of the Dead"] = "День мертвых"
L["World Event: Fishing contests"] = "Игровое событие: Состязания рыболовов"
L["Fishing contests"] = "Состязания рыболовов"
L["World Event: Hallow's End"] = "Игровое событие: Тыквовин"
L["Hallow's End"] = "Тыквовин"
L["World Event: Harvest Festival"] = "Игровое событие: Неделя урожая"
L["Harvest Festival"] = "Неделя урожая"
L["World Event: Love is in the Air"] = "Игровое событие: Любовная лихорадка"
L["Love is in the Air"] = "Любовная лихорадка"
L["World Event: Lunar Festival"] = "Игровое событие: Лунный фестиваль"
L["Lunar Festival"] = "Лунный фестиваль"
L["World Event: Midsummer Fire Festival"] = "Игровое событие: Огненный солнцеворот"
L["Midsummer Fire Festival"] = "Огненный солнцеворот"
L["World Event: Noblegarden"] = "Игровое событие: Сад чудес"
L["Noblegarden"] = "Сад чудес"
L["World Event: Pilgrim's Bounty"] = "Игровое событие: Пиршество странников"
L["Pilgrim's Bounty"] = "Пиршество странников"
L["World Event: Feast of Winter Veil"] = "Игровое событие: Зимний Покров"
L["Feast of Winter Veil"] = "Зимний Покров"

-- Common WotLK Instance Acronyms & Names (wowroad.info / WoW Circle)
L["Icecrown Citadel"] = "Цитадель Ледяной Короны"
L["ЦЛК"] = "Icecrown Citadel"
L["The Ruby Sanctum"] = "Рубиновое святилище"
L["РС"] = "The Ruby Sanctum"
L["Trial of the Crusader"] = "Испытание крестоносца"
L["ИК"] = "Trial of the Crusader"
L["Trial of the Grand Crusader"] = "Испытание великого крестоносца"
L["ИВК"] = "Trial of the Grand Crusader"
L["Ulduar"] = "Ульдуар"
L["Ульда"] = "Ulduar"
L["Ульдуар"] = "Ulduar"
L["Naxxramas"] = "Наксрамас"
L["Накс"] = "Naxxramas"
L["Наксрамас"] = "Naxxramas"
L["The Obsidian Sanctum"] = "Обсидиановое святилище"
L["ОС"] = "The Obsidian Sanctum"
L["The Eye of Eternity"] = "Око Вечности"
L["Око"] = "The Eye of Eternity"
L["Vault of Archavon"] = "Склеп Аркавона"
L["СА"] = "Vault of Archavon"
L["Склеп"] = "Vault of Archavon"
L["The Forge of Souls"] = "Кузня Душ"
L["Кузня"] = "The Forge of Souls"
L["Pit of Saron"] = "Яма Сарона"
L["Яма"] = "Pit of Saron"
L["Halls of Reflection"] = "Залы Отражений"
L["Залы"] = "Halls of Reflection"
L["Trial of the Champion"] = "Испытание чемпиона"
L["ИЧ"] = "Trial of the Champion"
L["The Violet Hold"] = "Аметистовая крепость"
L["АК"] = "The Violet Hold"
L["Gundrak"] = "Гундрак"
L["Drak'Tharon Keep"] = "Крепость Драк'Тарон"
L["ДТК"] = "Drak'Tharon Keep"
L["Halls of Lightning"] = "Чертоги Молний"
L["ЧМ"] = "Halls of Lightning"
L["Halls of Stone"] = "Чертоги Камня"
L["ЧК"] = "Halls of Stone"
L["Azjol-Nerub"] = "Азжол-Неруб"
L["АН"] = "Azjol-Nerub"
L["Ahn'kahet: The Old Kingdom"] = "Ан'кахет: Старое Королевство"
L["АСК"] = "Ahn'kahet: The Old Kingdom"
L["The Nexus"] = "Нексус"
L["The Oculus"] = "Окулус"
L["Utgarde Keep"] = "Крепость Утгард"
L["Utgarde Pinnacle"] = "Вершина Утгард"

-- Additional strings
L["In combat: the map comes back when the fight ends.\nThe map key (M) opens the game's map meanwhile."] = "В бою: карта вернется после окончания боя.\nКлавиша карты (M) временно открывает стандартную карту."
L["In towns"] = "В городах"
L["Transports, portals, towns"] = "Транспорт, порталы, города"
L["Flights"] = "Полеты"
L["Inns"] = "Таверны"
L["Auction"] = "Аукцион"
L["Mail"] = "Почта"
L["Flight master"] = "Распорядитель полетов"
L["Innkeeper"] = "Хозяин таверны"
L["Mailbox"] = "Почтовый ящик"
L["Bank"] = "Банк"
L["Auction house"] = "Аукционный дом"

-- WorldView strings
L["< Zoom out"] = "< Отдалить"
L["Zone > continent > world. Right-click on the map does the same."] = "Зона > континент > мир. Правый клик по карте делает то же самое."
L["Zone"] = "Зона"
L["Find me"] = "Где я"
L["The map of your zone, with a pulse on your arrow."] = "Карта вашей локации с подсветкой стрелки игрока."
L["Game map"] = "Игровая карта"
L["The game's full screen map, with the quest list."] = "Полноэкранная карта игры со списком заданий."
L["Quests"] = "Задания"
L["Show or hide quest objectives on the map."] = "Показать или скрыть цели заданий на карте."
L["Find"] = "Поиск"
L["Find a dungeon, raid, world boss, boat, zeppelin, tram or portal and show it on the map."] = "Найти подземелье, рейд, босса, транспорт или портал на карте."
L["Markers"] = "Метки"
L["Choose which markers the map shows."] = "Выберите, какие метки отображать на карте."
L["Left-click: zoom in    Right-click: zoom out"] = "Левый клик: приблизить    Правый клик: отдалить"

-- UI additions
L["Location: "] = "Локация: "
L["Drops in: "] = "Падает в: "
L["Honor Points"] = "Очки чести"
L["Arena Points"] = "Очки арены"
L["Gold"] = "Золото"
L["Click: open / close"] = "Клик: открыть / закрыть"
L["Right-click: settings"] = "Правый клик: настройки"
L["Drag: move button"] = "Перетаскивание: переместить кнопку"
L["Resize: drag this corner"] = "Изменение размера: потяните за угол"

-- Совместимость с WDM-patch
L["Dungeons & Raids"] = "Подземелья и рейды"
L["Show the interactive game map for this dungeon (supports WDM-patch)."] = "Показать интерактивную карту подземелья из игры (поддерживает WDM-patch)."

-- Дополнительные строки интерфейса и подсказок
L["Resize"] = "Изменение размера"
L["Drag to make the window bigger or smaller."] = "Потяните, чтобы изменить размер окна."
L["Entrance"] = "Вход"
L["< Back"] = "< Назад"
L["(%d at once)"] = "(по %d шт.)"
L["Shift-click: link   Ctrl-click: try on"] = "Shift-клик: ссылка в чат   Ctrl-клик: примерка"
L["Left-click: open / close"] = "Левый клик: открыть / закрыть"
L["Drag: move"] = "Перетаскивание: переместить"
L["Fishing %d"] = "Рыбная ловля %d"
L["-man"] = " чел."

---------------------------------------------------------------------------
-- Russian pluralization & format helpers
---------------------------------------------------------------------------
function AP.GetPluralRu(n, one, two, five)
    local n10 = n % 10
    local n100 = n % 100
    if n10 == 1 and n100 ~= 11 then
        return one
    elseif n10 >= 2 and n10 <= 4 and (n100 < 10 or n100 >= 20) then
        return two
    else
        return five
    end
end

function AP.FormatInstances(n)
    return n .. " " .. AP.GetPluralRu(n, "подземелье", "подземелья", "подземелий")
end

function AP.FormatBosses(n)
    return n .. " " .. AP.GetPluralRu(n, "босс", "босса", "боссов")
end

function AP.FormatItems(n)
    return n .. " " .. AP.GetPluralRu(n, "предмет", "предмета", "предметов")
end

function AP.FormatLists(n)
    return n .. " " .. AP.GetPluralRu(n, "список", "списка", "списков")
end

---------------------------------------------------------------------------
-- Russian dungeon/raid map IDs (WDM-patch & Native game map)
---------------------------------------------------------------------------
AP.GAME_MAP_IDS = AP.GAME_MAP_IDS or {}
local ruMaps = {
    ["Огненная Пропасть"] = 680,
    ["Зул'Фаррак"] = 686,
    ["Затонувший храм"] = 687,
    ["Храм Атал'Хаккара"] = 687,
    ["Непроглядная Пучина"] = 688,
    ["Тюрьма"] = 690,
    ["Гномереган"] = 691,
    ["Ульдаман"] = 692,
    ["Забытый Город"] = 699,
    ["Глубины Черной горы"] = 704,
    ["Пик Черной горы"] = 721,
    ["Пещеры Стенаний"] = 749,
    ["Мародон"] = 750,
    ["Мертвые копи"] = 756,
    ["Курганы Иглошкурых"] = 760,
    ["Лабиринты Иглошкурых"] = 761,
    ["Монастырь Алого ордена"] = 762,
    ["Некроситет"] = 763,
    ["Крепость Темного Клыка"] = 764,
    ["Стратхольм"] = 765,
    ["Огненные Недра"] = 696,
    ["Зул'Гуруб"] = 697,
    ["Руины Ан'Киража"] = 717,
    ["Логово Крыла Тьмы"] = 755,
    ["Ан'Кираж"] = 766,
    ["Цитадель Адского Пламени: Бастионы"] = 797,
    ["Бастионы Адского Пламени"] = 797,
    ["Цитадель Адского Пламени: Кузня Крови"] = 725,
    ["Кузня Крови"] = 725,
    ["Цитадель Адского Пламени: Разрушенные залы"] = 710,
    ["Разрушенные залы"] = 710,
    ["Резервуар Кривого Клыка: Узилище"] = 728,
    ["Узилище"] = 728,
    ["Резервуар Кривого Клыка: Нижетопь"] = 726,
    ["Нижетопь"] = 726,
    ["Резервуар Кривого Клыка: Паровое подземелье"] = 727,
    ["Паровое подземелье"] = 727,
    ["Аукиндон: Гробницы маны"] = 732,
    ["Гробницы маны"] = 732,
    ["Аукиндон: Аукенайские гробницы"] = 722,
    ["Аукенайские гробницы"] = 722,
    ["Аукиндон: Сетеккские залы"] = 723,
    ["Сетеккские залы"] = 723,
    ["Аукиндон: Темный лабиринт"] = 724,
    ["Темный лабиринт"] = 724,
    ["Пещеры Времени: Старые предгорья Хилсбрада"] = 734,
    ["Старые предгорья Хилсбрада"] = 734,
    ["Пещеры Времени: Черные топи"] = 733,
    ["Черные топи"] = 733,
    ["Крепость Бурь: Ботаника"] = 729,
    ["Ботаника"] = 729,
    ["Крепость Бурь: Механар"] = 730,
    ["Механар"] = 730,
    ["Крепость Бурь: Аркатрац"] = 731,
    ["Аркатрац"] = 731,
    ["Терраса Магистров"] = 798,
    ["Каражан"] = 799,
    ["Логово Груула"] = 776,
    ["Логово Магтеридона"] = 779,
    ["Змеиное святилище"] = 780,
    ["Крепость Бурь"] = 782,
    ["Око"] = 782,
    ["Вершина Хиджала"] = 775,
    ["Черный храм"] = 796,
    ["Плато Солнечного Колодца"] = 789,
    ["Крепость Утгард"] = 523,
    ["Нексус"] = 520,
    ["Азжол-Неруб"] = 533,
    ["Ан'кахет: Старое Королевство"] = 522,
    ["Крепость Драк'Тарон"] = 534,
    ["Аметистовая крепость"] = 536,
    ["Гундрак"] = 530,
    ["Чертоги Камня"] = 526,
    ["Чертоги Молний"] = 525,
    ["Окулус"] = 528,
    ["Вершина Утгард"] = 524,
    ["Очищение Стратхольма"] = 521,
    ["Испытание чемпиона"] = 542,
    ["Кузня Душ"] = 601,
    ["Яма Сарона"] = 602,
    ["Залы Отражений"] = 603,
    ["Наксрамас"] = 535,
    ["Обсидиановое святилище"] = 531,
    ["Око Вечности"] = 527,
    ["Склеп Аркавона"] = 532,
    ["Ульдуар"] = 529,
    ["Испытание крестоносца"] = 543,
    ["Логово Ониксии"] = 718,
    ["Цитадель Ледяной Короны"] = 604,
    ["Рубиновое святилище"] = 609,
}
for k, v in pairs(ruMaps) do
    AP.GAME_MAP_IDS[k] = v
end

-- Categories short
L["Wrath Dungeons"] = "Подземелья Wrath"
L["Wrath Raids"] = "Рейды Wrath"

-- Factions
L["Alliance"] = "Альянс"
L["Horde"] = "Орда"
L["Neutral"] = "Нейтральный"

-- World Bosses
L["Ysondre"] = "Исондра"
L["Taerar"] = "Таэрар"
L["Emeriss"] = "Эмерисс"
L["Lethon"] = "Летон"
L["Azuregos"] = "Азурегос"
L["Lord Kazzak"] = "Владыка Каззак"

-- All WoW 3.3.5 Zones & Instances
L["Ahn'Qiraj"] = "Ан'Кираж"
L["Ahn'kahet: The Old Kingdom"] = "Ан'кахет: Старое Королевство"
L["Alterac Mountains"] = "Альтеракские горы"
L["Alterac Valley"] = "Альтеракская долина"
L["Amani Pass"] = "Перевал Амани"
L["Arathi Basin"] = "Низина Арати"
L["Arathi Highlands"] = "Нагорье Арати"
L["Armory"] = "Оружейная"
L["Ashenvale"] = "Ясеневый лес"
L["Auchenai Crypts"] = "Аукенайские гробницы"
L["Azeroth"] = "Азерот"
L["Azjol-Nerub"] = "Азжол-Неруб"
L["Azshara"] = "Азшара"
L["Azuremyst Isle"] = "Остров Лазурной Дымки"
L["Badlands"] = "Бесплодные земли"
L["Black Temple"] = "Черный храм"
L["Blackfathom Deeps"] = "Непроглядная Пучина"
L["Blackrock Depths"] = "Глубины Черной горы"
L["Blackrock Mountain"] = "Черная гора"
L["Blackrock Spire"] = "Пик Черной горы"
L["Blackwing Lair"] = "Логово Крыла Тьмы"
L["Blade's Edge Arena"] = "Арена Острогорья"
L["Blade's Edge Mountains"] = "Острогорье"
L["Blasted Lands"] = "Выжженные земли"
L["Bloodmyst Isle"] = "Остров Кровавой Дымки"
L["Borean Tundra"] = "Борейская тундра"
L["Burning Steppes"] = "Пылающие степи"
L["Cathedral"] = "Собор"
L["Caverns of Time"] = "Пещеры Времени"
L["Coilfang Reservoir"] = "Резервуар Кривого Клыка"
L["Coldarra"] = "Хладоарра"
L["Crystalsong Forest"] = "Лес Хрустальной Песни"
L["Dalaran"] = "Даларан"
L["Dalaran Arena"] = "Арена Даларана"
L["Darkshore"] = "Темные берега"
L["Darnassus"] = "Дарнас"
L["Deadwind Pass"] = "Перевал Мертвого Ветра"
L["Deeprun Tram"] = "Подземный поезд"
L["Desolace"] = "Пустоши"
L["Dire Maul"] = "Забытый Город"
L["Dragonblight"] = "Драконий Погост"
L["Drak'Tharon Keep"] = "Крепость Драк'Тарон"
L["Dun Morogh"] = "Дун Морог"
L["Durotar"] = "Дуротар"
L["Duskwood"] = "Сумеречный лес"
L["Dustwallow Marsh"] = "Пылевые топи"
L["Eastern Kingdoms"] = "Восточные королевства"
L["Eastern Plaguelands"] = "Восточные Чумные земли"
L["Elwynn Forest"] = "Элвиннский лес"
L["Eversong Woods"] = "Леса Вечной Песни"
L["Eye of the Storm"] = "Око Бури"
L["Felwood"] = "Оскверненный лес"
L["Feralas"] = "Фералас"
L["Ghostlands"] = "Призрачные земли"
L["Gnomeregan"] = "Гномереган"
L["Graveyard"] = "Кладбище"
L["Grizzly Hills"] = "Седые холмы"
L["Gruul's Lair"] = "Логово Груула"
L["Gundrak"] = "Гундрак"
L["Halls of Lightning"] = "Чертоги Молний"
L["Halls of Reflection"] = "Залы Отражений"
L["Halls of Stone"] = "Чертоги Камня"
L["Hellfire Citadel"] = "Цитадель Адского Пламени"
L["Hellfire Peninsula"] = "Полуостров Адского Пламени"
L["Hellfire Ramparts"] = "Бастионы Адского Пламени"
L["Hillsbrad Foothills"] = "Предгорья Хилсбрада"
L["Howling Fjord"] = "Ревущий фьорд"
L["Hrothgar's Landing"] = "Лагерь Хротгара"
L["Hyjal"] = "Хиджал"
L["Hyjal Summit"] = "Вершина Хиджала"
L["Icecrown"] = "Ледяная Корона"
L["Icecrown Citadel"] = "Цитадель Ледяной Короны"
L["Ironforge"] = "Стальгорн"
L["Isle of Quel'Danas"] = "Остров Кель'Данас"
L["Kalimdor"] = "Калимдор"
L["Karazhan"] = "Каражан"
L["Library"] = "Библиотека"
L["Loch Modan"] = "Лок Модан"
L["Magisters' Terrace"] = "Терраса Магистров"
L["Magtheridon's Lair"] = "Логово Магтеридона"
L["Mana-Tombs"] = "Гробницы маны"
L["Maraudon"] = "Мародон"
L["Molten Core"] = "Огненные Недра"
L["Moonglade"] = "Лунная поляна"
L["Mulgore"] = "Мулгор"
L["Nagrand"] = "Награнд"
L["Nagrand Arena"] = "Арена Награнда"
L["Naxxramas"] = "Наксрамас"
L["Netherstorm"] = "Пустоверть"
L["Northrend"] = "Нордскол"
L["Old Hillsbrad Foothills"] = "Старые предгорья Хилсбрада"
L["Onyxia's Lair"] = "Логово Ониксии"
L["Orgrimmar"] = "Оргриммар"
L["Outland"] = "Запределье"
L["Pit of Saron"] = "Яма Сарона"
L["Plaguelands: The Scarlet Enclave"] = "Чумные земли: Анклав Алого ордена"
L["Ragefire Chasm"] = "Огненная Пропасть"
L["Razorfen Downs"] = "Курганы Иглошкурых"
L["Razorfen Kraul"] = "Лабиринты Иглошкурых"
L["Redridge Mountains"] = "Красногорье"
L["Ring of Observance"] = "Кольцо Почитания"
L["Ruins of Ahn'Qiraj"] = "Руины Ан'Киража"
L["Ruins of Lordaeron"] = "Руины Лордерона"
L["Scarlet Monastery"] = "Монастырь Алого ордена"
L["Scholomance"] = "Некроситет"
L["Searing Gorge"] = "Тлеющее ущелье"
L["Serpentshrine Cavern"] = "Змеиное святилище"
L["Sethekk Halls"] = "Сетеккские залы"
L["Shadow Labyrinth"] = "Темный лабиринт"
L["Shadowfang Keep"] = "Крепость Темного Клыка"
L["Shadowmoon Valley"] = "Долина Призрачной Луны"
L["Shattrath City"] = "Шаттрат"
L["Sholazar Basin"] = "Низина Шолазар"
L["Silithus"] = "Силитус"
L["Silvermoon City"] = "Луносвет"
L["Silverpine Forest"] = "Серебряный бор"
L["Stonetalon Mountains"] = "Когтистые горы"
L["Stormwind City"] = "Штормград"
L["Strand of the Ancients"] = "Берег Древних"
L["Stranglethorn Vale"] = "Тернистая долина"
L["Stratholme"] = "Стратхольм"
L["Sunwell Plateau"] = "Плато Солнечного Колодца"
L["Swamp of Sorrows"] = "Болото Печали"
L["Tanaris"] = "Танарис"
L["Teldrassil"] = "Тельдрассил"
L["Tempest Keep"] = "Крепость Бурь"
L["Terokkar Forest"] = "Лес Тероккар"
L["The Arcatraz"] = "Аркатрац"
L["The Barrens"] = "Степи"
L["The Black Morass"] = "Черные топи"
L["The Blood Furnace"] = "Кузня Крови"
L["The Botanica"] = "Ботаника"
L["The Culling of Stratholme"] = "Очищение Стратхольма"
L["The Dark Portal"] = "Темный Портал"
L["The Deadmines"] = "Мертвые копи"
L["The Exodar"] = "Экзодар"
L["The Eye"] = "Око"
L["The Eye of Eternity"] = "Око Вечности"
L["The Forge of Souls"] = "Кузня Душ"
L["The Frozen Sea"] = "Ледяное море"
L["The Hinterlands"] = "Внутренние земли"
L["The Mechanar"] = "Механар"
L["The Nexus"] = "Нексус"
L["The Obsidian Sanctum"] = "Обсидиановое святилище"
L["The Oculus"] = "Окулус"
L["The Ruby Sanctum"] = "Рубиновое святилище"
L["The Shattered Halls"] = "Разрушенные залы"
L["The Slave Pens"] = "Узилище"
L["The Steamvault"] = "Паровое подземелье"
L["The Stockade"] = "Тюрьма"
L["The Storm Peaks"] = "Грозовая Гряда"
L["The Temple of Atal'Hakkar"] = "Храм Атал'Хаккара"
L["The Underbog"] = "Нижетопь"
L["The Violet Hold"] = "Аметистовая крепость"
L["Thousand Needles"] = "Тысяча Игл"
L["Thunder Bluff"] = "Громовой Утес"
L["Tirisfal Glades"] = "Тирисфальские леса"
L["Trial of the Champion"] = "Испытание чемпиона"
L["Trial of the Crusader"] = "Испытание крестоносца"
L["Uldaman"] = "Ульдаман"
L["Ulduar"] = "Ульдуар"
L["Un'Goro Crater"] = "Кратер Ун'Горо"
L["Undercity"] = "Подгород"
L["Utgarde Keep"] = "Крепость Утгард"
L["Utgarde Pinnacle"] = "Вершина Утгард"
L["Vault of Archavon"] = "Склеп Аркавона"
L["Wailing Caverns"] = "Пещеры Стенаний"
L["Warsong Gulch"] = "Ущелье Песни Войны"
L["Western Plaguelands"] = "Западные Чумные земли"
L["Westfall"] = "Западный Край"
L["Wetlands"] = "Болотина"
L["Wintergrasp"] = "Озеро Ледяных Оков"
L["Winterspring"] = "Зимние Ключи"
L["Zangarmarsh"] = "Зангартопь"
L["Zul'Aman"] = "Зул'Аман"
L["Zul'Drak"] = "Зул'Драк"
L["Zul'Farrak"] = "Зул'Фаррак"
L["Zul'Gurub"] = "Зул'Гуруб"

---------------------------------------------------------------------------
-- Item types & sub-types
---------------------------------------------------------------------------
local ITEM_TYPES_RU = {
    -- Armor slots + type
    ["Feet, Cloth"] = "Ступни, Ткань",
    ["Feet, Leather"] = "Ступни, Кожа",
    ["Feet, Mail"] = "Ступни, Кольчуга",
    ["Feet, Plate"] = "Ступни, Латы",
    ["Head, Cloth"] = "Голова, Ткань",
    ["Head, Leather"] = "Голова, Кожа",
    ["Head, Mail"] = "Голова, Кольчуга",
    ["Head, Plate"] = "Голова, Латы",
    ["Shoulder, Cloth"] = "Плечи, Ткань",
    ["Shoulder, Leather"] = "Плечи, Кожа",
    ["Shoulder, Mail"] = "Плечи, Кольчуга",
    ["Shoulder, Plate"] = "Плечи, Латы",
    ["Chest, Cloth"] = "Грудь, Ткань",
    ["Chest, Leather"] = "Грудь, Кожа",
    ["Chest, Mail"] = "Грудь, Кольчуга",
    ["Chest, Plate"] = "Грудь, Латы",
    ["Wrist, Cloth"] = "Запястья, Ткань",
    ["Wrist, Leather"] = "Запястья, Кожа",
    ["Wrist, Mail"] = "Запястья, Кольчуга",
    ["Wrist, Plate"] = "Запястья, Латы",
    ["Hands, Cloth"] = "Кисти рук, Ткань",
    ["Hands, Leather"] = "Кисти рук, Кожа",
    ["Hands, Mail"] = "Кисти рук, Кольчуга",
    ["Hands, Plate"] = "Кисти рук, Латы",
    ["Waist, Cloth"] = "Пояс, Ткань",
    ["Waist, Leather"] = "Пояс, Кожа",
    ["Waist, Mail"] = "Пояс, Кольчуга",
    ["Waist, Plate"] = "Пояс, Латы",
    ["Legs, Cloth"] = "Ноги, Ткань",
    ["Legs, Leather"] = "Ноги, Кожа",
    ["Legs, Mail"] = "Ноги, Кольчуга",
    ["Legs, Plate"] = "Ноги, Латы",

    -- Slots
    ["Neck"] = "Шея",
    ["Finger"] = "Палец",
    ["Trinket"] = "Аксессуар",
    ["Back"] = "Спина",
    ["Shirt"] = "Рубашка",
    ["Tabard"] = "Гербовая накидка",
    ["Held In Off-hand"] = "Левая рука",
    ["Shield"] = "Щит",
    ["Off Hand"] = "Левая рука",
    ["Main Hand"] = "Правая рука",
    ["One-Hand"] = "Одноручное",
    ["Two-Hand"] = "Двуручное",

    -- Weapons
    ["One-Hand Axe"] = "Одноручный топор",
    ["One-Hand Mace"] = "Одноручное дробящее",
    ["One-Hand Sword"] = "Одноручный меч",
    ["One-Hand Dagger"] = "Кинжал",
    ["Two-Hand Axe"] = "Двуручный топор",
    ["Two-Hand Mace"] = "Двуручное дробящее",
    ["Two-Hand Sword"] = "Двуручный меч",
    ["Main Hand Dagger"] = "Кинжал (правая рука)",
    ["Main Hand Axe"] = "Топор (правая рука)",
    ["Main Hand Mace"] = "Дробящее (правая рука)",
    ["Main Hand Sword"] = "Меч (правая рука)",
    ["Main Hand Fist"] = "Кистевое (правая рука)",
    ["Off Hand Dagger"] = "Кинжал (левая рука)",
    ["Off Hand Axe"] = "Топор (левая рука)",
    ["Off Hand Mace"] = "Дробящее (левая рука)",
    ["Off Hand Sword"] = "Меч (левая рука)",
    ["Off Hand Fist"] = "Кистевое (левая рука)",
    ["Dagger"] = "Кинжал",
    ["Fist Weapon"] = "Кистевое",
    ["Polearm"] = "Древковое",
    ["Staff"] = "Посох",
    ["Bow"] = "Лук",
    ["Crossbow"] = "Арбалет",
    ["Gun"] = "Огнестрельное",
    ["Wand"] = "Жезл",
    ["Thrown"] = "Метательное",
    ["Relic"] = "Реликвия",
    ["Idol"] = "Идол",
    ["Libram"] = "Манускрипт",
    ["Totem"] = "Тотем",
    ["Sigil"] = "Печать",

    -- Professions / Recipes
    ["Pattern - Blacksmithing"] = "Кузнечное дело (рецепт)",
    ["Pattern - Leatherworking"] = "Кожевничество (выкройка)",
    ["Pattern - Tailoring"] = "Портняжное дело (выкройка)",
    ["Pattern - Engineering"] = "Инженерное дело (схема)",
    ["Pattern - Alchemy"] = "Алхимия (рецепт)",
    ["Pattern - Enchanting"] = "Наложение чар (формула)",
    ["Pattern - Jewelcrafting"] = "Ювелирное дело (эскиз)",
    ["Pattern - Inscription"] = "Начертание (эскиз)",
    ["Pattern - Cooking"] = "Кулинария (рецепт)",
    ["Pattern - First Aid"] = "Первая помощь (учебник)",
    ["Pattern - Recipe"] = "Рецепт",
    ["Recipe"] = "Рецепт",
}

for k, v in pairs(ITEM_TYPES_RU) do
    L[k] = v
end

function AP.FormatItemType(typ)
    if not typ or typ == "" then return "" end
    if L[typ] and L[typ] ~= typ then return L[typ] end
    local slot, armor = typ:match("^(.-),%s*(.-)$")
    if slot and armor then
        local s = L[slot] or slot
        local a = L[armor] or armor
        return s .. ", " .. a
    end
    local prof = typ:match("^Pattern %-%s*(.-)$")
    if prof then
        local p = L[prof] or prof
        return (L["Pattern"] or "Рецепт") .. ": " .. p
    end
    return typ
end

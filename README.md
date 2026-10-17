# Atlas Plus [Circle Edition]

[![WoW Version](https://img.shields.io/badge/WoW-3.3.5a%20(12340)-blue.svg)](https://wowroad.info/)
[![Database](https://img.shields.io/badge/Database-wowroad.info-orange.svg)](https://wowroad.info/)
[![Version](https://img.shields.io/badge/Release-1.10.1--circle-brightgreen.svg)](https://github.com/dadec666/Atlas-Plus/releases)
[![Localization](https://img.shields.io/badge/Language-ruRU%20%7C%20enUS-green.svg)](https://github.com/dadec666/Atlas-Plus)
[![License](https://img.shields.io/badge/License-GPL%20v2-lightgrey.svg)](LICENSE.txt)
[![WDM Patch](https://img.shields.io/badge/WDM--patch-Compatible-brightgreen.svg)](https://github.com/Trimitor/WDM-patch)

**Карта мира и подземелий в одном окне: боссы и добыча, поиск предметов, метки на карте, открытие тумана войны.**  
Форк аддона Atlas Plus для World of Warcraft 3.3.5a (Wrath of the Lich King), оптимизированный для серверов **WoW Circle** и согласованный с базой данных [wowroad.info](https://wowroad.info/).

---

### Особенности издания Circle Edition:
- **Полная русская локализация (`ruRU`):** интерфейс, карта мира, панель настроек, маркеры и подсказки переведены в соответствии с официальным клиентом 3.3.5a и базой [wowroad.info](https://wowroad.info/).
- **Умный поиск на русском:** поиск подземелий по общепринятым сокращениям (ЦЛК, ИК, ИВК, РС, Ульда, Накс, ОС, Око, СА/Склеп, Кузня, Яма, Залы, ИЧ, АК, Гундрак, ДТК, ЧМ, ЧК, АН, АСК) и названиям предметов/боссов.
- **Корректные склонения:** грамматически правильный вывод счетчиков («1 подземелье», «2 подземелья», «5 подземелий», «боссов», «предметов»).
- **Универсальность 3.3.5a:** удалены искусственные ограничения сторонних ядер и фаз прогрессии — отображается стандартная добыча и эмблемы актуала WotLK 3.3.5a.
- **Интеграция с [WDM-patch](https://github.com/Trimitor/WDM-patch) (Dungeon Maps for WotLK):**
  - Автоматическое отображение розничных карт для 56 подземелий и рейдов Classic и The Burning Crusade прямо на карте мира со стрелкой персонажа, метками группы и этажами.
  - Кнопка **«Карта игры»** в окне информации о подземелье для быстрого переключения между картой Atlas (с боссами и добычей) и интерактивной картой подземелья из игры.
  - Корректный пошаговый выход (`Zoom Out` / правый клик) из подземелий WDM-patch в родительскую зону континента.
  - Удобный список подземелий и рейдов континента в выпадающем меню выбора зон на карте мира.
- **Очищенный код:** проверен на отсутствие утечек памяти, защиту от ошибок в бою (`ADDON_ACTION_BLOCKED`) и строгую совместимость с Lua 5.1.

---

### Установка

1. Скачайте архив со страницы [Releases](https://github.com/dadec666/Atlas-Plus/releases).
2. Распакуйте папку `AtlasPlus` в директорию `World of Warcraft\Interface\AddOns\`.
3. Убедитесь, что папка называется именно `AtlasPlus`.
4. Перезапустите игру или введите `/console reloadui`.

---

### Команды

| Команда | Описание |
| :--- | :--- |
| `/ap` | Открыть / закрыть окно аддона |
| `/ap here` | Открыть карту текущей локации или подземелья |
| `/ap world` | Открыть карту мира |
| `/ap search <текст>` | Поиск по подземельям, боссам и добыче |
| `/ap settings` | Окно настроек |
| `/ap reset` | Сброс положения, размера и прозрачности окна |

---

### Авторы и благодарности

- **Оригинальный разработчик:** [Saranwrap](https://github.com/saranwrap04) (Atlas Plus).
- **Разработчик форка Circle Edition и локализация:** [dadec666](https://github.com/dadec666).
- **Карты и легенды:** проект [Atlas](http://www.atlasmod.com) (Dan Gilbert и контрибьюторы, лицензия GNU GPL v2).
- **База данных:** [wowroad.info](https://wowroad.info/) (WoW Circle).
- **Уровни зон:** LibTourist-3.0 (MIT, ckknight и Arrowmaster).

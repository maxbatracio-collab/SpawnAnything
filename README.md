# SpawnAnything

A Cyber Engine Tweaks mod for Cyberpunk 2077 that combines a spawner and a set of single-player cheats in one in-game menu.

Un mod de Cyber Engine Tweaks para Cyberpunk 2077 que reúne un spawner y varios cheats para un jugador en un único menú dentro del juego.

[English](#english) | [Español](#espanol)

---

<a name="english"></a>
## English

### Overview

SpawnAnything lets you add almost anything in the game to your world through a searchable menu, and adds a small set of cheats. It was created as a single, self-contained mod so that you do not need to install and maintain several separate tools.

### Features

**Spawning**
- Weapons: every weapon in the game, with a filter for iconic (unique) weapons and a rarity selector.
- Enemies and NPCs: any character in the game, with a level from 1 to 60 and a group size of up to 30.
- Vehicles: any vehicle in the game, placed in front of the player.
- Items: any inventory item, in any quantity.

**Cheats**
- God Mode: invulnerability, infinite stamina (you can sprint without limit) and no encumbrance, whatever you carry.
- Infinite ammo: ammunition reserve and magazine never run out, and no reloading is needed.
- Infinite RAM: RAM for quickhacks is refilled continuously.
- Noclip: fly through the world with keys you assign.
- Level up: raise your level and street cred by a chosen amount, or set them to the maximum.

**Other**
- Automatic language: the menu follows the game's text language. English and Spanish are included, and other languages can be added easily.
- Delete everything spawned: one button removes all enemies and vehicles created by the mod.

### Requirements

- Cyberpunk 2077 for PC, patch 2.x (developed and tested on 2.3x).
- [Cyber Engine Tweaks](https://www.nexusmods.com/cyberpunk2077/mods/107) (CET).

### Installation

1. Install Cyber Engine Tweaks following its own instructions.
2. Copy the `SpawnAnything` folder into:
   `Cyberpunk 2077/bin/x64/plugins/cyber_engine_tweaks/mods/`
3. The result must be `.../mods/SpawnAnything/init.lua`.
4. Start the game.

### How to use

1. Open the CET overlay with its overlay key (the key shown in the CET window on first launch; it can be changed in CET's Bindings tab).
2. A window named **SpawnAnything** appears. Use its tabs: Cheats, Levels, Weapons, Enemies/NPCs, Vehicles and Items.
3. In the spawn tabs, type in the **Search** box to filter the list, then click an entry to add it. Weapons and items go to your inventory. Enemies and vehicles appear in front of you.
4. In the Cheats tab, tick a checkbox to enable a cheat.

**Noclip controls.** Noclip does not ship with default keys. Open CET > Bindings, find SpawnAnything, and assign keys to: forward, backward, up, down and boost. Then enable Noclip in the Cheats tab and hold the keys to move. Enabling God Mode as well avoids fall damage.

**Hotkeys.** God Mode, infinite ammo, infinite RAM and noclip can each be toggled with a key assigned in CET > Bindings.

### How it works

The mod is a single Lua script (`init.lua`) loaded by Cyber Engine Tweaks. It reads the game's internal database (TweakDB) at runtime, so the lists of weapons, characters, vehicles and items always match the game version and any other mods you have installed.

- Items are added to the inventory with the game's transaction system.
- Enemies and vehicles are created with the game's dynamic entity system, tagged by the mod, and are not saved into your save file.
- God Mode uses the game's own god mode system, plus a stamina refill and a very large carry-capacity bonus.
- Infinite ammo applies the game's built-in infinite-ammo effect and tops up the ammunition reserve.
- Noclip moves the player each frame in the direction they are facing.
- Levels are changed through the game's player development system.

### Notes and limitations

- For single-player use only. Do not use it online.
- Back up your saves before using any cheat mod.
- Spawned entities are removed when you close the game. Use **Delete everything spawned** before saving if you spawned many, and avoid spawning dozens at once.
- The rarity selector for weapons is experimental and may not apply to every weapon.
- Level 60 requires the Phantom Liberty expansion; without it the cap is 50.
- Game updates can break mods that depend on CET. If something stops working after a patch, check that CET is up to date.

### Adding a language

Open `init.lua`, copy the `en` block inside the `STRINGS` table, translate the values and give the block its two-letter language code (for example `fr`). Missing entries fall back to English. To force a language, set `FORCE_LANG` at the top of the file.

### Author and license

Created by the repository owner. Released under the MIT License (see `LICENSE`).
This is an unofficial fan-made mod and is not affiliated with or endorsed by CD PROJEKT RED.

---

<a name="espanol"></a>
## Español

### Descripción

SpawnAnything permite añadir a tu partida casi cualquier cosa del juego mediante un menú con buscador, e incluye un pequeño conjunto de cheats. Se creó como un único mod independiente para que no sea necesario instalar y mantener varias herramientas distintas.

### Funcionalidades

**Spawn**
- Armas: todas las armas del juego, con un filtro de armas icónicas (únicas) y un selector de rareza.
- Enemigos y NPCs: cualquier personaje del juego, con nivel de 1 a 60 y grupos de hasta 30.
- Vehículos: cualquier vehículo del juego, colocado delante del jugador.
- Objetos: cualquier objeto del inventario, en la cantidad que quieras.

**Cheats**
- God Mode: invulnerabilidad, aguante infinito (puedes correr sin límite) y sin sobrecarga, sin importar lo que lleves encima.
- Balas infinitas: la reserva y el cargador nunca se agotan y no hace falta recargar.
- RAM infinita: la RAM para hackeos se rellena continuamente.
- Noclip: vuela a través del mapa con las teclas que asignes.
- Subir de nivel: sube tu nivel y tu reputación la cantidad que elijas, o llévalos al máximo.

**Otros**
- Idioma automático: el menú sigue el idioma de texto del juego. Se incluyen inglés y español, y es fácil añadir más.
- Borrar todo lo spawneado: un botón elimina todos los enemigos y vehículos creados por el mod.

### Requisitos

- Cyberpunk 2077 para PC, parche 2.x (desarrollado y probado en la 2.3x).
- [Cyber Engine Tweaks](https://www.nexusmods.com/cyberpunk2077/mods/107) (CET).

### Instalación

1. Instala Cyber Engine Tweaks siguiendo sus propias instrucciones.
2. Copia la carpeta `SpawnAnything` en:
   `Cyberpunk 2077/bin/x64/plugins/cyber_engine_tweaks/mods/`
3. El resultado debe ser `.../mods/SpawnAnything/init.lua`.
4. Inicia el juego.

### Cómo usarlo

1. Abre el overlay de CET con su tecla (la que se muestra en la ventana de CET la primera vez; se puede cambiar en la pestaña Bindings de CET).
2. Aparece una ventana llamada **SpawnAnything**. Usa sus pestañas: Cheats, Niveles, Armas, Enemigos/NPCs, Vehículos y Objetos.
3. En las pestañas de spawn, escribe en el cuadro **Buscar** para filtrar la lista y haz clic en una entrada para añadirla. Las armas y los objetos van a tu inventario. Los enemigos y los vehículos aparecen delante de ti.
4. En la pestaña Cheats, marca una casilla para activar un cheat.

**Controles del noclip.** El noclip no trae teclas por defecto. Abre CET > Bindings, busca SpawnAnything y asigna teclas a: adelante, atrás, subir, bajar y turbo. Después activa Noclip en la pestaña Cheats y mantén pulsadas las teclas para moverte. Activar también el God Mode evita el daño por caída.

**Atajos.** God Mode, balas infinitas, RAM infinita y noclip se pueden activar o desactivar con una tecla asignada en CET > Bindings.

### Cómo funciona

El mod es un único script de Lua (`init.lua`) que carga Cyber Engine Tweaks. Lee la base de datos interna del juego (TweakDB) mientras se ejecuta, por lo que las listas de armas, personajes, vehículos y objetos siempre coinciden con la versión del juego y con cualquier otro mod que tengas instalado.

- Los objetos se añaden al inventario mediante el sistema de transacciones del juego.
- Los enemigos y los vehículos se crean con el sistema de entidades dinámicas del juego, se marcan con una etiqueta propia del mod y no se guardan en tu partida.
- El God Mode usa el sistema de invulnerabilidad del propio juego, además de rellenar el aguante y dar un bonus muy grande de capacidad de carga.
- Las balas infinitas aplican el efecto de munición infinita integrado en el juego y rellenan la reserva de munición.
- El noclip mueve al jugador en cada fotograma en la dirección en la que mira.
- Los niveles se cambian mediante el sistema de desarrollo del jugador del juego.

### Notas y limitaciones

- Solo para un jugador. No lo uses online.
- Haz una copia de seguridad de tus partidas antes de usar cualquier mod de cheats.
- Las entidades spawneadas se eliminan al cerrar el juego. Usa **Borrar todo lo spawneado** antes de guardar si has creado muchas, y evita crear decenas a la vez.
- El selector de rareza de las armas es experimental y puede no aplicarse a todas.
- El nivel 60 requiere la expansión Phantom Liberty; sin ella el tope es 50.
- Las actualizaciones del juego pueden romper los mods que dependen de CET. Si algo deja de funcionar tras un parche, comprueba que CET esté actualizado.

### Añadir un idioma

Abre `init.lua`, copia el bloque `en` dentro de la tabla `STRINGS`, traduce los valores y ponle al bloque su código de idioma de dos letras (por ejemplo `fr`). Lo que falte se muestra en inglés. Para forzar un idioma, define `FORCE_LANG` al principio del archivo.

### Autor y licencia

Creado por el propietario del repositorio. Publicado bajo la licencia MIT (consulta `LICENSE`).
Es un mod no oficial hecho por un aficionado y no está afiliado ni respaldado por CD PROJEKT RED.

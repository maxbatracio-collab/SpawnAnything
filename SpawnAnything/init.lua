-- SpawnAnything: spawner + cheats for Cyberpunk 2077 (2.x) using Cyber Engine Tweaks
-- Install to: <game>/bin/x64/plugins/cyber_engine_tweaks/mods/SpawnAnything/init.lua
-- Spawns weapons (all/iconic, with rarity), enemies (any level), vehicles and items.
-- Cheats: God Mode, Noclip, infinite ammo, infinite RAM, level up.
--
-- Language: detected automatically from the game's text language (Settings > Language).
-- To add a language, copy the "en" block in STRINGS, translate the values and add its
-- two-letter code. Missing keys fall back to English. To force a language, set FORCE_LANG.

local FORCE_LANG = nil -- e.g. "es" or "en"; nil = follow the game language

local STRINGS = {
    en = {
        rarity_unchanged = "Unchanged", rarity_1 = "Common", rarity_2 = "Uncommon",
        rarity_3 = "Rare", rarity_4 = "Epic", rarity_5 = "Legendary",
        gave = "Gave: %s x%d", gave_norarity = "Gave %s (could not change rarity)",
        spawned = "Spawned: %s",
        lvl_fail = "Could not change %s (see the CET console)",
        search = "Search", narrow = "... (narrow your search)",
        tab_cheats = "Cheats", tab_levels = "Levels", tab_weapons = "Weapons",
        tab_npcs = "Enemies/NPCs", tab_vehicles = "Vehicles", tab_items = "Items",
        god = "God Mode (invulnerable + infinite stamina + no encumbrance)",
        ammo = "Infinite ammo (magazine and reserve, no reloading)",
        ram = "Infinite RAM (quickhacks)",
        noclip = "Noclip (fly; set keys in CET > Bindings)",
        noclip_speed = "Noclip speed",
        cur_level = "Current level: %d / %d", cur_cred = "Current street cred: %d / %d",
        lvl_add_n = "Levels to add", btn_add_lvl = "Add level(s)", btn_max_lvl = "Max level",
        cred_add_n = "Street cred to add", btn_add_cred = "Add street cred", btn_max_cred = "Max street cred",
        lvl_note = "Note: level 60 requires Phantom Liberty; without it the cap is 50.",
        rarity = "Rarity", iconic = "Iconic only",
        level = "Level", count = "Count", distance = "Distance", quantity = "Quantity",
        delete_all = "Delete everything spawned",
        hk_god = "Toggle God Mode", hk_ammo = "Toggle infinite ammo", hk_ram = "Toggle infinite RAM",
        hk_noclip = "Toggle noclip", in_fwd = "Noclip forward", in_back = "Noclip backward",
        in_up = "Noclip up", in_down = "Noclip down", in_fast = "Noclip boost (hold)",
    },
    es = {
        rarity_unchanged = "Sin cambiar", rarity_1 = "Común", rarity_2 = "Poco común",
        rarity_3 = "Rara", rarity_4 = "Épica", rarity_5 = "Legendaria",
        gave = "Dado: %s x%d", gave_norarity = "Dado %s (no pude cambiar la rareza)",
        spawned = "Spawneado: %s",
        lvl_fail = "No pude cambiar %s (mira la consola de CET)",
        search = "Buscar", narrow = "... (afina la búsqueda)",
        tab_cheats = "Cheats", tab_levels = "Niveles", tab_weapons = "Armas",
        tab_npcs = "Enemigos/NPCs", tab_vehicles = "Vehículos", tab_items = "Objetos",
        god = "God Mode (invulnerable + aguante infinito + sin sobrecarga)",
        ammo = "Balas infinitas (cargador y reserva, sin recargar)",
        ram = "RAM infinita (hackeos)",
        noclip = "Noclip (vuelo; teclas en CET > Bindings)",
        noclip_speed = "Velocidad noclip",
        cur_level = "Nivel actual: %d / %d", cur_cred = "Reputación actual: %d / %d",
        lvl_add_n = "Cuántos niveles subir", btn_add_lvl = "Subir nivel(es)", btn_max_lvl = "Nivel máximo",
        cred_add_n = "Cuánta reputación subir", btn_add_cred = "Subir reputación", btn_max_cred = "Reputación máxima",
        lvl_note = "Nota: el nivel 60 requiere Phantom Liberty; sin él el tope es 50.",
        rarity = "Rareza", iconic = "Solo únicas (icónicas)",
        level = "Nivel", count = "Cantidad", distance = "Distancia", quantity = "Cantidad",
        delete_all = "Borrar todo lo spawneado",
        hk_god = "God Mode on/off", hk_ammo = "Balas infinitas on/off", hk_ram = "RAM infinita on/off",
        hk_noclip = "Noclip on/off", in_fwd = "Noclip adelante", in_back = "Noclip atrás",
        in_up = "Noclip subir", in_down = "Noclip bajar", in_fast = "Noclip turbo (mantener)",
    },
}

-- Detects the game's text language, e.g. "es-es" -> "es". Falls back to English.
local function detectLang()
    if FORCE_LANG and STRINGS[FORCE_LANG] then return FORCE_LANG end
    local ok, v = pcall(function()
        return Game.GetSettingsSystem():GetVar("/language", "OnScreen"):GetValue()
    end)
    if ok and v then
        local code = tostring(v):lower():match("^(%a%a)")
        if code and STRINGS[code] then return code end
    end
    return "en"
end

local LANG = "en"
local function tr(key, ...)
    local s = (STRINGS[LANG] and STRINGS[LANG][key]) or STRINGS.en[key] or key
    if select("#", ...) > 0 then return string.format(s, ...) end
    return s
end

local TAG = "SpawnAnything"
local S = {
    open = false,
    god = false, ammo = false, ram = false, noclip = false,
    noclipSpeed = 6.0, noclipFast = false,
    move = { fwd = false, back = false, up = false, down = false },
    timer = 0.0,
    search = { weapon = "", npc = "", vehicle = "", item = "" },
    cache = {},
    qty = 1, rarity = 0, iconicOnly = false, npcLevel = 20, npcCount = 1, dist = 6.0,
    pending = {}, status = "",
}
local AMMO = { "Ammo.HandgunAmmo", "Ammo.RifleAmmo", "Ammo.ShotgunAmmo", "Ammo.SniperRifleAmmo", "Ammo.Special" }

local function say(msg) S.status = msg; print("[" .. TAG .. "] " .. msg) end
local function player() local ok, p = pcall(Game.GetPlayer); if ok then return p end end

-- Lists TweakDB records of a given type; returns a sorted { {name=, rec=} ... }.
local function records(typeName, prefix, pred)
    local key = typeName .. (prefix or "")
    if S.cache[key] then return S.cache[key] end
    local out = {}
    local ok, recs = pcall(function() return TweakDB:GetRecords(typeName) end)
    if ok and recs then
        for _, rec in ipairs(recs) do
            local n = TDBID.ToStringDEBUG(rec:GetID())
            if n and n:match("^%a[%w_]*%.") and (not prefix or n:sub(1, #prefix) == prefix)
                and (not pred or pred(rec, n)) then
                out[#out + 1] = { name = n, rec = rec }
            end
        end
    end
    table.sort(out, function(a, b) return a.name < b.name end)
    S.cache[key] = out
    return out
end

local function spawnPos()
    local p = player()
    local pos = p:GetWorldPosition()
    local fwd = p:GetWorldForward()
    return Vector4.new(pos.x + fwd.x * S.dist, pos.y + fwd.y * S.dist, pos.z + 0.3, 1), p:GetWorldOrientation()
end

local function setQuality(itemID, tier)
    -- Experimental: raises/lowers the Quality stat of the item that was just given.
    local p = player()
    local ts = Game.GetTransactionSystem()
    local data = ts:GetItemData(p, itemID)
    if not data then return end
    local statsID = data:GetStatsObjectID()
    local mod = RPGManager.CreateStatModifier(gamedataStatType.Quality, gamedataStatModifierType.Additive, tier - 1)
    Game.GetStatsSystem():AddSavedModifier(statsID, mod)
end

local function giveItem(name, qty, tier)
    local p = player(); if not p then return end
    local id = ItemID.FromTDBID(TweakDB:GetRecord(name):GetID())
    Game.GetTransactionSystem():GiveItem(p, id, qty)
    if tier and tier > 0 then
        local ok = pcall(setQuality, id, tier)
        if not ok then say(tr("gave_norarity", name)); return end
    end
    say(tr("gave", name, qty))
end

local function spawnEntity(recordName, level)
    local p = player(); if not p then return end
    local pos, rot = spawnPos()
    local spec = DynamicEntitySpec.new()
    spec.recordID = TweakDB:GetRecord(recordName):GetID()
    spec.appearanceName = "random"
    spec.position = pos
    spec.orientation = rot
    -- Do not persist in saves: too many saved entities make the save crash on load.
    spec.persistState = false
    spec.persistSpawn = false
    spec.alwaysSpawned = false
    spec.tags = { TAG }
    local id = Game.GetDynamicEntitySystem():CreateEntity(spec)
    if level then S.pending[#S.pending + 1] = { id = id, level = level, t = 1.0 } end
    say(tr("spawned", recordName))
end

local function applyLevel(entry)
    local ent = Game.FindEntityByID(entry.id)
    if not ent then return false end
    local cur = Game.GetStatsSystem():GetStatValue(ent:GetEntityID(), gamedataStatType.PowerLevel)
    local mod = RPGManager.CreateStatModifier(gamedataStatType.PowerLevel, gamedataStatModifierType.Additive, entry.level - cur)
    Game.GetStatsSystem():AddModifier(ent:GetEntityID(), mod)
    return true
end

-- ---- God / ammo / RAM / noclip --------------------------------------------
local carryMod
local function setGod(on)
    local p = player(); if not p then return end
    local gs = Game.GetGodModeSystem()
    local stats = Game.GetStatsSystem()
    if on then
        gs:AddGodMode(p:GetEntityID(), gameGodModeType.Invulnerable, TAG)
        if not carryMod then
            -- Huge carry capacity: never encumbered.
            carryMod = RPGManager.CreateStatModifier(gamedataStatType.CarryCapacity, gamedataStatModifierType.Additive, 999999)
            stats:AddModifier(p:GetEntityID(), carryMod)
        end
    else
        gs:ClearGodMode(p:GetEntityID(), TAG)
        if carryMod then stats:RemoveModifier(p:GetEntityID(), carryMod); carryMod = nil end
    end
end

-- God Mode extras: infinite stamina and no encumbered state (runs every frame).
local function godExtras(p)
    Game.GetStatPoolsSystem():RequestSettingStatPoolValue(p:GetEntityID(), gamedataStatPoolType.Stamina, 100, p, true)
    pcall(function() StatusEffectHelper.RemoveStatusEffect(p, TweakDBID.new("BaseStatusEffect.Encumbered")) end)
end

local INF_AMMO = "GameplayRestriction.InfiniteAmmo"

-- Infinite magazine: the game's built-in effect stops ammo from being spent and removes the need to reload.
local function setInfiniteMag(on)
    local p = player(); if not p then return end
    local id = TweakDBID.new(INF_AMMO)
    local has = StatusEffectHelper.HasStatusEffect(p, id)
    if on and not has then StatusEffectHelper.ApplyStatusEffect(p, id, p:GetEntityID())
    elseif not on and has then StatusEffectHelper.RemoveStatusEffect(p, id) end
end

local function topUpAmmo(p)
    pcall(setInfiniteMag, true)
    local ts = Game.GetTransactionSystem()
    for _, a in ipairs(AMMO) do
        local id = ItemID.FromTDBID(TweakDB:GetRecord(a):GetID())
        if ts:GetItemQuantity(p, id) < 5000 then ts:GiveItem(p, id, 9999) end
    end
end

local function refillRam(p)
    Game.GetStatPoolsSystem():RequestSettingStatPoolValue(p:GetEntityID(), gamedataStatPoolType.Memory, 100, p, true)
end

local function noclipStep(p, dt)
    local m = S.move
    if not (m.fwd or m.back or m.up or m.down) then return end
    local f = p:GetWorldForward()
    local speed = S.noclipSpeed * (S.noclipFast and 4 or 1) * dt
    local dx, dy, dz = 0, 0, 0
    if m.fwd then dx, dy = dx + f.x, dy + f.y end
    if m.back then dx, dy = dx - f.x, dy - f.y end
    if m.up then dz = dz + 1 end
    if m.down then dz = dz - 1 end
    local pos = p:GetWorldPosition()
    local np = Vector4.new(pos.x + dx * speed, pos.y + dy * speed, pos.z + dz * speed, 1)
    Game.GetTeleportationFacility():Teleport(p, np, p:GetWorldOrientation():ToEulerAngles())
end

-- ---- Levels ---------------------------------------------------------------
local MAX_LEVEL, MAX_CRED = 60, 50

local function curLevel(stat)
    local p = player()
    return math.floor(Game.GetStatsSystem():GetStatValue(p:GetEntityID(), stat) + 0.5)
end

local function setLevelTo(prof, name, target)
    local p = player(); if not p then return end
    local ok = pcall(function()
        local pds = Game.GetScriptableSystemsContainer():Get("PlayerDevelopmentSystem")
        local data = pds:GetDevelopmentData(p)
        data:SetLevel(prof, target, telemetryLevelGainReason.Ignore)
    end)
    if not ok then ok = pcall(Game.SetLevel, name, target) end
    say(ok and (name .. " -> " .. target) or tr("lvl_fail", name))
end

local function addLevels(n)
    local cur = curLevel(gamedataStatType.Level)
    setLevelTo(gamedataProficiencyType.Level, "Level", math.min(cur + n, MAX_LEVEL))
end

local function addCred(n)
    local cur = curLevel(gamedataStatType.StreetCred)
    setLevelTo(gamedataProficiencyType.StreetCred, "StreetCred", math.min(cur + n, MAX_CRED))
end

-- ---- UI -------------------------------------------------------------------
local function drawList(key, typeName, prefix, pred, onClick)
    S.search[key] = ImGui.InputText(tr("search") .. "##" .. key, S.search[key], 100)
    local q = S.search[key]:lower()
    local shown = 0
    ImGui.BeginChild("list" .. key, 0, 260, true)
    for _, e in ipairs(records(typeName, prefix, pred)) do
        if q == "" or e.name:lower():find(q, 1, true) then
            if ImGui.Selectable(e.name) then onClick(e.name) end
            shown = shown + 1
            if shown >= 200 then ImGui.Text(tr("narrow")); break end
        end
    end
    ImGui.EndChild()
end

local function isIconic(rec)
    local ok, r = pcall(function() return rec:TagsContains("IconicWeapon") end)
    return ok and r
end

-- Tab labels carry a fixed "###id" so ImGui keeps their state whatever the language.
local function tab(key, id) return ImGui.BeginTabItem(tr(key) .. "###" .. id) end

local function draw()
    if not S.open then return end
    if not ImGui.Begin("SpawnAnything") then ImGui.End(); return end
    if ImGui.BeginTabBar("tabs") then
        if tab("tab_cheats", "t_cheats") then
            local c
            S.god, c = ImGui.Checkbox(tr("god"), S.god); if c then pcall(setGod, S.god) end
            S.ammo = ImGui.Checkbox(tr("ammo"), S.ammo)
            S.ram = ImGui.Checkbox(tr("ram"), S.ram)
            S.noclip = ImGui.Checkbox(tr("noclip"), S.noclip)
            S.noclipSpeed = ImGui.SliderFloat(tr("noclip_speed"), S.noclipSpeed, 1, 30)
            ImGui.EndTabItem()
        end
        if tab("tab_levels", "t_levels") then
            if player() then
                ImGui.Text(tr("cur_level", curLevel(gamedataStatType.Level), MAX_LEVEL))
                ImGui.Text(tr("cur_cred", curLevel(gamedataStatType.StreetCred), MAX_CRED))
            end
            S.lvlAmount = ImGui.SliderInt(tr("lvl_add_n"), S.lvlAmount or 1, 1, 59)
            if ImGui.Button(tr("btn_add_lvl")) then pcall(addLevels, S.lvlAmount) end
            ImGui.SameLine()
            if ImGui.Button(tr("btn_max_lvl")) then pcall(addLevels, MAX_LEVEL) end
            ImGui.Separator()
            S.credAmount = ImGui.SliderInt(tr("cred_add_n"), S.credAmount or 1, 1, 49)
            if ImGui.Button(tr("btn_add_cred")) then pcall(addCred, S.credAmount) end
            ImGui.SameLine()
            if ImGui.Button(tr("btn_max_cred")) then pcall(addCred, MAX_CRED) end
            ImGui.TextWrapped(tr("lvl_note"))
            ImGui.EndTabItem()
        end
        if tab("tab_weapons", "t_weapons") then
            local names = { tr("rarity_unchanged"), tr("rarity_1"), tr("rarity_2"), tr("rarity_3"), tr("rarity_4"), tr("rarity_5") }
            S.rarity = ImGui.Combo(tr("rarity"), S.rarity, names, 6)
            S.iconicOnly = ImGui.Checkbox(tr("iconic"), S.iconicOnly)
            drawList("weapon", "gamedataWeaponItem_Record", "Items.",
                function(rec, n) return not n:find("Test") and (not S.iconicOnly or isIconic(rec)) end,
                function(name) pcall(giveItem, name, 1, S.rarity) end)
            ImGui.EndTabItem()
        end
        if tab("tab_npcs", "t_npcs") then
            S.npcLevel = ImGui.SliderInt(tr("level"), S.npcLevel, 1, 60)
            S.npcCount = ImGui.SliderInt(tr("count"), S.npcCount, 1, 30)
            S.dist = ImGui.SliderFloat(tr("distance"), S.dist, 2, 30)
            drawList("npc", "gamedataCharacter_Record", "Character.", nil,
                function(name)
                    for _ = 1, S.npcCount do pcall(spawnEntity, name, S.npcLevel) end
                end)
            ImGui.EndTabItem()
        end
        if tab("tab_vehicles", "t_vehicles") then
            drawList("vehicle", "gamedataVehicle_Record", "Vehicle.", nil,
                function(name) pcall(spawnEntity, name) end)
            ImGui.EndTabItem()
        end
        if tab("tab_items", "t_items") then
            S.qty = ImGui.InputInt(tr("quantity"), S.qty)
            drawList("item", "gamedataItem_Record", "Items.", nil,
                function(name) pcall(giveItem, name, math.max(S.qty, 1)) end)
            ImGui.EndTabItem()
        end
        ImGui.EndTabBar()
    end
    if ImGui.Button(tr("delete_all")) then
        pcall(function() Game.GetDynamicEntitySystem():DeleteTagged(TAG) end)
    end
    ImGui.Text(S.status)
    ImGui.End()
end

-- ---- Registration ---------------------------------------------------------
registerForEvent("onInit", function()
    LANG = detectLang()
    print("[" .. TAG .. "] language: " .. LANG)
    -- Binding labels are translated; the ids (sa_*) never change so saved keys are kept.
    registerHotkey("sa_god", TAG .. ": " .. tr("hk_god"), function() S.god = not S.god; pcall(setGod, S.god) end)
    registerHotkey("sa_ammo", TAG .. ": " .. tr("hk_ammo"), function() S.ammo = not S.ammo end)
    registerHotkey("sa_ram", TAG .. ": " .. tr("hk_ram"), function() S.ram = not S.ram end)
    registerHotkey("sa_noclip", TAG .. ": " .. tr("hk_noclip"), function() S.noclip = not S.noclip end)
    registerInput("sa_fwd", TAG .. ": " .. tr("in_fwd"), function(d) S.move.fwd = d end)
    registerInput("sa_back", TAG .. ": " .. tr("in_back"), function(d) S.move.back = d end)
    registerInput("sa_up", TAG .. ": " .. tr("in_up"), function(d) S.move.up = d end)
    registerInput("sa_down", TAG .. ": " .. tr("in_down"), function(d) S.move.down = d end)
    registerInput("sa_fast", TAG .. ": " .. tr("in_fast"), function(d) S.noclipFast = d end)
end)

registerForEvent("onOverlayOpen", function() S.open = true end)
registerForEvent("onOverlayClose", function() S.open = false end)
registerForEvent("onDraw", draw)

registerForEvent("onUpdate", function(dt)
    local p = player(); if not p then return end
    for i = #S.pending, 1, -1 do
        local e = S.pending[i]
        e.t = e.t - dt
        if e.t <= 0 then
            local ok, done = pcall(applyLevel, e)
            if (ok and done) or e.t < -5 then table.remove(S.pending, i) end
        end
    end
    if S.noclip then pcall(noclipStep, p, dt) end
    if S.god then pcall(godExtras, p) end
    if S.prevAmmo and not S.ammo then pcall(setInfiniteMag, false) end
    S.prevAmmo = S.ammo
    S.timer = S.timer + dt
    if S.timer >= 1.0 then
        S.timer = 0
        if S.ammo then pcall(topUpAmmo, p) end
        if S.ram then pcall(refillRam, p) end
    end
end)

registerForEvent("onShutdown", function()
    pcall(setGod, false)
    pcall(function() Game.GetDynamicEntitySystem():DeleteTagged(TAG) end)
end)

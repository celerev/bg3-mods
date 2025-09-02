local enemyTemplates = Require("CombatMod/Server/Templates/Enemies.lua")
local soloModeEnemyTemplates = Require("CombatMod/Server/Templates/LoneWolfEnemies.lua")
local exandriaEnemyTemplates = Require("CombatMod/Server/Templates/SOEEnemies.lua")
local exandriaSoloEnemyTemplates = Require("CombatMod/Server/Templates/SOELoneWolfEnemies.lua")
local mapTemplates = Require("CombatMod/Server/Templates/Maps.lua")
local scenarioTemplates = Require("CombatMod/Server/Templates/Scenarios.lua")
local unlockTemplates = Require("CombatMod/Server/Templates/Unlocks.lua")
local itemBlacklist = Require("CombatMod/Server/Templates/ItemBlacklist.lua")
local originalLootRates = table.deepclone(C.LootRates)
local exandriaCheck = Ext.Mod.IsModLoaded("a27fdbe3-4d1a-641d-d05f-1ba4ee529da8")

if exandriaCheck then
	External.File.ExportIfNeeded("Enemies", exandriaEnemyTemplates)
else
	External.File.ExportIfNeeded("Enemies", enemyTemplates)
end
External.File.ExportIfNeeded("Maps", mapTemplates)
External.File.ExportIfNeeded("Scenarios", scenarioTemplates)
External.File.ExportIfNeeded("LootRates", originalLootRates)
External.File.ExportIfNeeded("ItemFilters", { Names = {}, Mods = {} })

function Templates.ExportEnemies()
    External.File.Export("Enemies", enemyTemplates)
end

function Templates.ExportSoloModeEnemies()
    External.File.Export("Enemies", soloModeEnemyTemplates)
end

function Templates.ExportExandriaModeEnemies()
    External.File.Export("Enemies", exandriaEnemyTemplates)
end

function Templates.ExportExandriaSoloModeEnemies()
    External.File.Export("Enemies", exandriaSoloEnemyTemplates)
end

function Templates.ExportMaps()
    External.File.Export("Maps", mapTemplates)
end

function Templates.ExportScenarios()
    External.File.Export("Scenarios", scenarioTemplates)
end

function Templates.ExportLootRates()
    External.File.Export("LootRates", originalLootRates)
end

function Templates.GetEnemies()
    if exandriaCheck then
		return table.deepclone(exandriaEnemyTemplates)
	else
		return table.deepclone(enemyTemplates)
	end
end

function Templates.GetMaps()
    return table.deepclone(mapTemplates)
end

function Templates.GetScenarios()
    return table.deepclone(scenarioTemplates)
end

function Templates.GetUnlocks()
    return table.deepclone(unlockTemplates)
end

function Templates.GetItemFilters()
    return table.deepclone({ Names = itemBlacklist, Mods = {} })
end

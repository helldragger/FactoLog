--control.lua

require 'stdlib/table'
require 'stdlib/log/logger'
require 'serpent'
running = false
--ITEM CACHE MECHANICS
ItemNameCache = {}

function getLocalisedName(name)
   if ItemNameCache[name] == nil then
      if not game.item_prototypes[name] == nil then
         ItemNameCache[name] = game.item_prototypes[name].localised_name
      elseif not game.fluid_prototypes[name] == nil then   
         ItemNameCache[name] = game.fluid_prototypes[name].localised_name 
      elseif not game.entity_prototypes[name] == nil then   
         ItemNameCache[name] = game.entity_prototypes[name].localised_name 
      else
         ItemNameCache[name] = name
      end
   end
   return ItemNameCache[name]
end



--CONFIG MECHANICS
Config = {}
ConfigName = {}
ConfigSettingsList = {}
LastLogfileName = "default"

function addConfigSetting(alias, setting_name)
   Config[setting_name] = nil
   ConfigName[alias] = setting_name
   ConfigSettingsList[#ConfigSettingsList + 1] = setting_name
end

function loadConfigSetting(setting_name)
   local value = settings.global[setting_name].value
   if ConfigName["StatsTimeDelta"] == setting_name then
      local StatsTimeDelta = 60*60
      if (value == "5s") then
         StatsTimeDelta = 5*60
      elseif (value == "10s") then
         StatsTimeDelta = 10*60
      elseif (value == "30s") then
         StatsTimeDelta = 30*60
      elseif (value == "1m") then
         StatsTimeDelta = 60*60
      elseif (value == "5m") then
         StatsTimeDelta = 300*60
      elseif (value == "10m") then
         StatsTimeDelta = 600*60
      elseif (value == "30m") then
         StatsTimeDelta = 1800*60
      elseif (value == "1h") then
         StatsTimeDelta = 3600*60
      end
      value = StatsTimeDelta
   elseif ConfigName["LogfileName"] == setting_name and running then
      --move the last logfile if it was the default one (temporary folder)
      LastLogfileName = value
      table.each(game.forces, modifyLoggers)
   end
   Config[setting_name]=value
end

function getConfigSetting(alias)
   return Config[ConfigName[alias]]
end

addConfigSetting("SolidProductionMode","FactoLog-2-solid-production-statistics")
addConfigSetting("FluidProductionMode","FactoLog-2-fluid-production-statistics")
addConfigSetting("KillCountMode","FactoLog-2-kill-count-statistics")
addConfigSetting("EntityBuildMode","FactoLog-2-entity-build-statistics")
addConfigSetting("LogfileName","FactoLog-1-logfile-name")
addConfigSetting("isLogging","FactoLog-3-logging-activated")
addConfigSetting("StatsTimeDelta","FactoLog-1-statistics-logging-interval")
addConfigSetting("ItemsLaunchedMode", "FactoLog-2-launched-items-statistics")
addConfigSetting("RocketLaunchedMode", "FactoLog-2-launched-rockets-statistics")
addConfigSetting("EvolutionFactorMode", "FactoLog-2-evolution-factor-statistics")

for alias,realsettingname in pairs(ConfigName) do
   loadConfigSetting(realsettingname)
end

function reloadConfig()
   local interval = settings.global["statistics-logging-interval"].value
   StatsTimeDelta = 60*60

   if (interval == "5s") then
      StatsTimeDelta = 5*60
   elseif (interval == "10s") then
      StatsTimeDelta = 10*60
   elseif (interval == "30s") then
      StatsTimeDelta = 30*60
   elseif (interval == "1m") then
      StatsTimeDelta = 60*60
   elseif (interval == "5m") then
      StatsTimeDelta = 300*60
   elseif (interval == "10m") then
      StatsTimeDelta = 600*60
   elseif (interval == "30m") then
      StatsTimeDelta = 1800*60
   elseif (interval == "1h") then
      StatsTimeDelta = 3600*60
   end
end


-- LOGGING MECHANICS
Loggers = {}
function getLogger(name)
   if (Loggers[name] == nil) then
      Loggers[name] = Logger.new('FactoLog', getConfigSetting("LogfileName"), true, {force_append=true, log_ticks=true})
   end
   return Loggers[name]
end

function modifyLoggers(force)
   Loggers[force.name] = Logger.new('FactoLog', getConfigSetting("LogfileName"), true, {force_append=true, log_ticks=true})
end

function prodDataToStr(data)
   local t = { }
   for k,v in pairs(data) do
	    t[#t+1] = dataToStr(k, v)
   end
   return table.concat(t,"")
end

function dataToStr(key, value)
	return table.concat({getLocalisedName(tostring(key)), ":", tostring(value), ";"}, "")
end

function arrayStatsToStr(name, data)
   local str = {name, ";INPUT;"}
   str[#str+1] = prodDataToStr(data)
   return table.concat(str, "")
end

function numericStatsToStr(name, data)
   
   return table.concat({name, ";INPUT;", dataToStr("value",data)}, "")
end

function prodStatsToStr(statName, stats, MODE)
   ---solid
   local statsArray = {statName .. ";"}
   if (MODE == "both" or MODE == "input") then
      --input
      statsArray[#statsArray+1] ="INPUT;" 
      --statsArray[#statsArray+1] =serpent.line(stats.input_counts)
      statsArray[#statsArray+1] =prodDataToStr(stats.input_counts)
   end
   if (MODE == "both" or MODE == "output") then
      --output
      statsArray[#statsArray+1] ="OUTPUT;"
      --statsArray[#statsArray+1] =serpent.line(stats.output_counts)
      statsArray[#statsArray+1] =prodDataToStr(stats.output_counts)
   end
   return table.concat(statsArray, "")
end

function dumpForceStats(force)
   --productions and other flow statistics of the game
   local stats = {";STATS;"..force.name..";"}
   if (not (getConfigSetting("SolidProductionMode") == "none")) then
      stats[#stats + 1] = prodStatsToStr("SOLID", force.item_production_statistics, getConfigSetting("SolidProductionMode"))
   end
   if (not (getConfigSetting("FluidProductionMode") == "none")) then
      stats[#stats + 1] = prodStatsToStr("FLUID", force.fluid_production_statistics, getConfigSetting("FluidProductionMode"))
   end
   if (not (getConfigSetting("KillCountMode") == "none")) then
      stats[#stats + 1] = prodStatsToStr("KILLS", force.kill_count_statistics, getConfigSetting("KillCountMode"))
   end
   if (not (getConfigSetting("EntityBuildMode") == "none")) then
      stats[#stats + 1] = prodStatsToStr("BUILD", force.entity_build_count_statistics, getConfigSetting("EntityBuildMode"))
   end
   if (getConfigSetting("ItemsLaunchedMode")) then
      stats[#stats + 1] = arrayStatsToStr("LAUNCHED", force.items_launched)
   end
   if (getConfigSetting("RocketLaunchedMode")) then
      stats[#stats + 1] = numericStatsToStr("ROCKETS", force.rockets_launched)
   end
   if (getConfigSetting("EvolutionFactorMode")) then
      stats[#stats + 1] = numericStatsToStr("EVOLUTION", force.evolution_factor)
   end

   getLogger(force.name).log(table.concat(stats,""))
end

cache_recipes = {}

function getUnlockedProducts(modifiers)
	local prods = {fluid={}, item={}}
	for _, modifier in pairs(modifiers) do
		if modifier.type == "unlock-recipe" then
			recipe = nil
			if cache_recipes[modifier.recipe] == nil then
				recipe = game.recipe_prototypes[modifier.recipe]
				cache_recipes[modifier.recipe] = recipe
			else
				recipe = cache_recipes[modifier.recipe]
			end
			for _,product in pairs(recipe.products) do
				prods[product.type][#prods[product.type] + 1] = product.name
			end

		end
	end
	return prods
end

cache_techDep = {}

function getTechData(tech)
	techDep = nil
	if cache_techDep[tech.name] == nil then
		local prerequisitesStr = {}
		for pretech_name, _ in pairs(tech.prerequisites) do
			prerequisitesStr[#prerequisitesStr + 1] = pretech_name
		end
		if #prerequisitesStr > 0 then
			prerequisitesStr = table.concat({"prerequisites-researches;", table.concat(prerequisitesStr, ";"), ";"}, "")
		else
			prerequisitesStr = ""
		end

		local products = getUnlockedProducts(tech.effects)
		getLogger("DEBUG").log(tostring(#products))
		getLogger("DEBUG").log(tostring(#products.item))
		getLogger("DEBUG").log(tostring(#products.fluid))
		itemsStr = ""
		if #products.item > 0 then
			itemsStr = table.concat({"unlocked-items;", table.concat(products.item, ";") , ";"},"")
		end
		fluidStr = ""
		if #products.fluid > 0 then
			fluidStr = table.concat({"unlocked-fluids;", table.concat(products.fluid, ";") , ";"},"")
		end

		techDep = table.concat({"research-name:" ..tech.name.. ";", itemsStr, fluidStr, prerequisitesStr}, "")
		cache_techDep[tech.name] = techDep
	else
		techDep = cache_techDep[tech.name]
	end
	return techDep
end

function generateTechData()
	lines = {}
	for _, techPrototype in pairs(game.technology_prototypes) do
		lines[#lines + 1] = getTechData(techPrototype)
	end
	game.write_file("logs/FactoLog/"..getConfigSetting("LogfileName")..".techdata", table.concat(lines, "\n"), false)
end

script.on_init(generateTechData)

script.on_nth_tick( getConfigSetting("StatsTimeDelta"), 
	function ()
		if getConfigSetting("isLogging") then
			table.each(game.forces, dumpForceStats)
        end
	end
 )


script.on_event({defines.events.on_research_finished},
   function (e)
      getLogger(e.research.force.name).log(
         ";EVENT;"..
         e.research.force.name..
         ";RESEARCHED;"..
         dataToStr("name",e.research.name)..
         dataToStr("level",e.research.level))
   end
)

script.on_event({defines.events.on_forces_merged},
   function (e)
      Loggers[e.source_name] = nil
   end
)

script.on_event({defines.events.on_runtime_mod_setting_changed},
   function (e)
      for _,v in pairs(ConfigSettingsList) do
         if e.setting == v then
            loadConfigSetting(e.setting)
            break
         end
      end
      
   end
)

running = true
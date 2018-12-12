--control.lua

require 'stdlib/table'
require 'stdlib/log/logger'
require 'serpent'

Loggers = {}

SolidProductionMode = settings.global["solid-production-statistics"].value
FluidProductionMode = settings.global["fluid-production-statistics"].value
KillCountMode = settings.global["kill-count-statistics"].value
EntityBuildMode = settings.global["entity-build-statistics"].value
FolderName = settings.global["logfile-folder-name"].value
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


function getLogger(name)
   if (Loggers[name] == nil) then
      Loggers[name] = Logger.new('FactoLog_'..FolderName, "history", true, {force_append=true, log_ticks=true})
   end
   return Loggers[name]
end

function prodDataToStr(data)
   local t = { }
   for k,v in pairs(data) do
      t[#t+1] = tostring(k)
      t[#t+1] = ":"
      t[#t+1] = tostring(v)
      t[#t+1] = ";"
   end
   return table.concat(t,"")
end

function prodStatsToStr(statName, stats, MODE)
   ---solid
   local statsArray = {statName .. ";"}
   if (MODE == "both" or MODE == "input") then
      --input
      statsArray[#statsArray+1] ="INPUT;" 
      --statsArray[#statsArray+1] =serpent.line(stats.input_counts)
      statsArray[#statsArray+1] =prodDataToStr(stats.input_counts)
      statsArray[#statsArray+1] =";"
   end
   if (MODE == "both" or MODE == "output") then
      --output
      statsArray[#statsArray+1] ="OUTPUT;"
      --statsArray[#statsArray+1] =serpent.line(stats.output_counts)
      statsArray[#statsArray+1] =prodDataToStr(stats.output_counts)
      statsArray[#statsArray+1] =";"
   end
   return table.concat(statsArray, "")
end

function dumpForceStats(force)
   --productions and other flow statistics of the game
   local stats = {force.name..";"}
   if (not (SolidProductionMode == "none")) then
      stats[#stats + 1] = prodStatsToStr("SOLID", force.item_production_statistics, SolidProductionMode)
   end
   if (not (FluidProductionMode == "none")) then
      stats[#stats + 1] = prodStatsToStr("FLUID", force.fluid_production_statistics, FluidProductionMode)
   end
   if (not (KillCountMode == "none")) then
      stats[#stats + 1] = prodStatsToStr("KILLS", force.kill_count_statistics, KillCountMode)
   end
   if (not (EntityBuildMode == "none")) then
      stats[#stats + 1] = prodStatsToStr("BUILD", force.entity_build_count_statistics, EntityBuildMode)
   end
   getLogger(force.name).log(table.concat(stats,""))
end


script.on_event({defines.events.on_tick},
   function (e)
      if e.tick % StatsTimeDelta == 0 then --common trick to reduce how often this runs, we don't want it running every tick, just 1/second
         print("data time!")
         table.each(game.forces, dumpForceStats)

      end
   end
)

script.on_event({defines.events.on_research_finished},
   function (e)
      getLogger(e.research.force.name).log("RESEARCHED;"..e.research.name)
   end
)

script.on_event({defines.events.on_forces_merged},
   function (e)
      Loggers[e.source_name] = nil
   end
)



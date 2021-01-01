--[[
  _____  _         __          __        _   _
 |  __ \(_)        \ \        / /       | | | |
 | |  | |_ _ __   __\ \  /\  / /__  __ _| |_| |__   ___ _ __
 | |  | | | '_ \ / _ \ \/  \/ / _ \/ _` | __| '_ \ / _ \ '__|
 | |__| | | | | | (_) \  /\  /  __/ (_| | |_| | | |  __/ |
 |_____/|_|_| |_|\___/ \/  \/ \___|\__,_|\__|_| |_|\___|_|

FiveM-DinoWeather
A Weather System that enhances realism by using GTA Natives relating to Zones.
Copyright (C) 2019  Jarrett Boice

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

]]

Citizen.CreateThread(function()
  while true do
    randomizeSystems()
    Citizen.Wait(WeatherConfig.randomizeTime)
  end
end)

RegisterServerEvent("dinoweather:syncWeather")
AddEventHandler("dinoweather:syncWeather", function()
  local _source = source
  TriggerClientEvent("dinoweather:syncWeather", _source, activeWeatherSystems)
end)

RegisterServerEvent("dinoweather:setWeatherInZone")
AddEventHandler("dinoweather:setWeatherInZone", function(zoneName, weatherType)
  local _source = source
  if IsPlayerAceAllowed(_source, "dinoweather.cmds") then
    local zoneArea = findZoneBySubZone(zoneName)
    for _, weatherZone in ipairs(WeatherConfig.weatherSystems[zoneArea][1]) do
      local foundInterval = nil
      for i, activeZone in ipairs(activeWeatherSystems) do
        if activeZone[1] == weatherZone then
          foundInterval = i 
        end
      end
      if foundInterval ~= nil then
        activeWeatherSystems[foundInterval] = {zoneName, weatherType}
      else
        table.insert(activeWeatherSystems, {zoneName, weatherType})
      end
    end
    TriggerClientEvent("dinoweather:syncWeather", -1, activeWeatherSystems)
    TriggerClientEvent("chatMessage", _source, "^2Weather set to ^3" .. weatherType .. "^2.")
  else
    TriggerClientEvent("chatMessage", _source, "^3No Permission.")
  end
end)

function getCurrentSeason()
  for i, timeOfYear in ipairs(WeatherConfig.timesOfYear) do
    for k, month in ipairs(WeatherConfig.timesOfYear[i]) do
      if month == os.date("*t").month then
        return i
      end
    end
  end
end

function isSnowDay()
  for i, decemberSnowDay in ipairs(WeatherConfig.decemberSnowDays) do
    if decemberSnowDay == os.date("*t").day then
      return true
    end
  end
  return false
end

function findZoneBySubZone(zoneName)
  for i, weatherSystem in ipairs(WeatherConfig.weatherSystems) do
    for _, weatherZone in ipairs(weatherSystem[1]) do
      if weatherZone == zoneName then
        return i
      end
    end
  end
end

function randomizeSystems()
  math.randomseed(os.time())

  activeWeatherSystems = {}
  for i, weatherSystem in ipairs(WeatherConfig.weatherSystems) do
    local currentSeason = getCurrentSeason()
    local availableWeathers = weatherSystem[currentSeason + 1]
    local pickedWeather = availableWeathers[math.random(1, #availableWeathers)]
    for _, weatherZone in ipairs(weatherSystem[1]) do
      if os.date("*t").month == 12 and isSnowDay() and WeatherConfig.snowEnabled then
        table.insert(activeWeatherSystems, {weatherZone, "XMAS"})
      else
        table.insert(activeWeatherSystems, {weatherZone, pickedWeather})
      end
    end
  end
  
  TriggerClientEvent("dinoweather:syncWeather", -1, activeWeatherSystems)
end

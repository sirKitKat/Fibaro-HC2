--[[
%% properties
90 sceneActivation

%% events
%% globals
--]]

-- Load MasterTable
local M = json.decode(fibaro:getGlobalValue("MasterTable"))
local device = M.inkom.licht

-- Druk sequentie
local scene = fibaro:getValue(device, "sceneActivation")

-- Lichtstanden ophalen
local licht = fibaro:getValue(device, "value")

-- kantelwaarden ophalen
local dim = M.dimmer

-- Input verwerken
local newValue
if scene == '14' then -- Double click S1
  newValue = ( tonumber(licht) > dim.center ) and dim.min or dim.max
  fibaro:call( device, "setValue", newValue )
end

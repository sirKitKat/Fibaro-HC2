--[[
%% properties
94 sceneActivation
%% events
%% globals
--]]

-- This scene will use the scene activation from a Fibaro Dimmer 2
-- to detect a double click and will set the value of the light to
-- 100% if the current value is below 50% or to 10% if the current
-- value is above 50%.
--
-- Dimmer 2 will need the following configuration to make this work:
--  * Parameter 23: value 0 (Disable default double click)
--  * Parameter 28: value 1 (Enable scene activation)

-- Code --

-- Trigger type
local trigger = fibaro:getSourceTrigger()

-- Only process property triggers
if trigger.type ~= 'property' then fibaro:abort() end

-- Extract dimmer ID from trigger (should be the same as in %% properties)
local device = trigger.deviceID

-- scene code
local scene = fibaro:getValue(device, "sceneActivation")

-- current light value
local value = tonumber( fibaro:getValue(device, "value") )

 -- Double click S1
if scene == '14' then
  
  -- new value based on current dimmer value.
  local newValue = ( value > 50 ) and 10 or 100
  
  -- send the new value to the dimmer
  fibaro:call( device, "setValue", newValue )
  
end -- if

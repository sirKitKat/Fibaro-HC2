--[[
%% properties
94 sceneActivation
%% events
%% globals
--]]

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

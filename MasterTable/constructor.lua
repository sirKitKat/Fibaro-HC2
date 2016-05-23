--[[
%% autostart
%% properties
%% globals
--]]

-- Initialize table
local M = {}
M.conf = {}
M.dev = {}
M.user = {}
M.app = {}

-- General --
-- ******* --

-- Levels for dimmer when double clicking
M.dimmer = {}
M.dimmer.min = 10            -- minimum dim level
M.dimmer.max = 100           -- maximum dim level
M.dimmer.center = 50         -- tipping dim level

-- time in seconds between motion and switch to abort automode
M.autolicht = {}
M.autolicht.timeToSwitch = 3

-- Kidsmonitor --
-- *********** --
M.kidsmonitor = {}
M.kidsmonitor.iconOn = 4
M.kidsmonitor.iconOff = 6
M.kidsmonitor.timeout = 5 * 60 -- Tijd tussen 2 push berichten in seconden
M.kidsmonitor.global = "Kidsmonitor"
M.kidsmonitor.pushfe = "Kidsmonitor_PushFE"


-- Users --
-- ***** --
M.user.admin = 2
M.user.klaas = 42
M.user.fietje = 44
M.user.plank = 76

M.app.klaas = 82
M.app.fietje = 75
M.app.plank = 74


-- DEVICES ( AUTOFILL ) --
-- ******************** --

-- debug
local debug = true

-- Feedback
fibaro:debug( "<span style=\"color:aqua;\">Adding devices to the table:</span>" )

-- fetch all devices in HC
local inHC = fibaro:getDevicesId()

-- For each device in HC
for i, id in pairs(inHC) do
  
  -- Get some info about the device and store it in a list
  local dev = { room={} }
  dev.id = id
  dev.name = fibaro:getName(dev.id)
  --dev.type = fibaro:getType(dev.id)
  --dev.room.id = fibaro:getRoomID(dev.id)
  --dev.room.name = fibaro:getRoomNameByDeviceID(dev.id)
  
  -- Track if there are error's:
  local refused = false
  
  -- Define pattern for legal names:
  -- From the beginning (^) to the end ($) there
  -- must be 1 or more (+) letter (%a), spaces (%s),
  -- dots (%.), digits (%d), underscores (_), or open and close brackets ()
  local patternName = '^[%a%s%.%d_%(%)]+$'
  
  -- Check if the device name has no foreign cahracters that could mess up the
  -- extraction of the fields.
  if string.find( dev.name , patternName ) then
  
    -- Define pattern for delimiters in the name:
    -- delimiters could be a space (%s), a dot (%.) or brackets (%(%))
    local patternDelimiter = '[%s%.%(%)]'
    
    -- Define a pattern for legal field names
    -- Must be 1 or more (+) letters (%a) or digits (%d)
    local patternField = '[%a%d]+'
    
    -- keep track of the field in the name
    local fields = {}
    
    -- keep track where we are in looking through the name
    local startPos = 1
    
    -- repeat until we reached the end of the name
    repeat
      
      -- find the next delimiter
      local endPos = string.find( dev.name..'.', patternDelimiter, startPos )
      
      -- extract the field name
      local fieldName = string.sub( dev.name..'.', startPos , endPos - 1 )
      
      -- all fieldnames are lowercase
      fieldName = string.lower( fieldName )
      
      -- test the fieldName against the pattern
      if string.find( fieldName , patternField ) then
        
        -- store the field in the table
        table.insert( fields, fieldName )
                
      end -- if fieldname matches pattern
      
      -- increment to the next start position
      startPos = endPos + 1
      
      -- repeat
    until startPos > string.len( dev.name..'.' ) or refused
    
    -- Only continue if all fields are accepted
    if not refused then
    
      -- temporary reference where we are in the table
      local subM = M
      local subAddress = "M"
      
      -- for all the fields except the last
      for i = 1 , #fields - 1 do
        
        -- set the field name for easy reference
        local field = fields[i]
        
        -- Create the field tabel if it does not exist
        if not subM[field] then subM[field] = {} end
        
        -- check if the field is a table
        if type( subM[field] ) == 'table' then
          
          -- Go one level deeper in the table
          subM = subM[field]
          subAddress = subAddress.."."..field
          
        else -- field is not a table
          
          -- feedback
          fibaro:debug( string.format(
              "%s '%s' <span style=\"color:red;\">REFUSED</span>: " ..
              "No table can be created at %s.%s = %s" , 
              dev.id, dev.name, subAddress, field, subM[field] ) )
            
          --refuse the device
          refused = true
          
          -- break the loop
          break
          
        end -- if field is a table
        
      end -- for each field in fields except the last
      
      -- sub field names are clear
      if not refused then
      
        -- Reference to the last field
        local field = fields[#fields]
        
        -- when the last field does not exist
        if not subM[field] then
          
          -- add the id of the device to the table
          subM[field] = dev.id
          
          -- feedback
          if debug then
            fibaro:debug( string.format(
              "%s '%s' <span style=\"color:green;\">ADDED:</span>: " ..
              "%s.%s = %s" , 
              dev.id, dev.name, subAddress, field, dev.id ) )
          end
          
        else -- field is already populated with a value:
          
          -- Is it the same value?
          if subM[field] == dev.id then
            
            -- Feedback tot the user
            fibaro:debug( string.format(
              "%s '%s' <span style=\"color:yellow;\">WARNING</span>: " ..
              "%s.%s is already populated with %s.",
              dev.id, dev.name, subAddress, field, dev.id ) )
            
          else -- if value is not the same
            
            -- what is in the way?
            local value = ( type(subM[field]) == 'table' and '{}' or subM[field] )
            
            -- Feedback tot the user
            fibaro:debug( string.format(
              "%s '%s' <span style=\"color:red;\">REFUSED</span>: " ..
              "%s.%s already exist with different value %s",
              dev.id, dev.name, subAddress, field, value ) )
                        
            -- refuse the device
            refuse = true
            
          end -- if value the same
          
        end -- last field is taken
      
      end -- some field is taken
      
    end -- not a valid field name
    
  else -- not a valid name to extract fields
    
    fibaro:debug( string.format(
        "%s '%s' <span style=\"color:red;\">REFUSED</span>: " ..
        "Strange characters in the name.",
        dev.id, dev.name ) )
    
  end -- if match patternName
  
end -- for each Device in HC

-- Empty line for next chapter
fibaro:debug('')

-- WRITE THE TABEL TO GLOBAL VALUE --
-- ******************************* --

-- encode the table in a string
jM = json.encode(M)

-- store the table in global variables
fibaro:setGlobal("MasterTable", jM)

-- Feedback
fibaro:debug("<span style=\"color:aqua;\">Storing the table to 'MasterTable'.</span>")
fibaro:debug('')


-- Plot the table --
-- ************** --
-- Feedback
fibaro:debug( "<span style=\"color:aqua;\">" ..
  "Plotting the content of the master table:</span>" )

local list = {}
local exportTable
exportTable = function (field,address)
  if type(field) == 'table' then
    for key,value in pairs( field ) do
      exportTable( value, address.."."..key )
    end
  else
    table.insert( list, address.." = "..field )
  end
end

exportTable( M, 'M' )
table.sort(list)
for i,n in ipairs(list) do
  fibaro:debug(n)
end

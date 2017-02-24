local url = "https://github.com/sirKitKat/Fibaro-HC2/raw/master/Test/content.lua"


local http = net.HTTPClient();
http:request(
  url,
  {
    options = {
      method = "GET",
      headers = {}
    },
    success = function(response) fibaro:debug(response.data) end,
    error = function(err) fibaro:debug("Error: " .. err) end
  }
)

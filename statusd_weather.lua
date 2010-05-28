-- statusd_weather.lua : Mark Tran <mark@nirv.net>

-- display weather information from a METAR station

if not statusd_weather then
   statusd_weather = {
      -- update every 30 minutes
      interval = 30*(60*1000),

      -- METAR station - http://adds.aviationweather.noaa.gov/metars/stations.txt
      station = 'KMSP',

      -- template variables:
      -- %city, %conditions, %celsius, %fahrenheit, %humidity, %precipitation, 
      -- %weather
      template = '%fahrenheit, %celsius'
   }
end

local function fetch_metar()
   local info = {}
   local url = 'http://weather.noaa.gov/pub/data/observations/metar/decoded/'

   local f =
      io.popen('curl '..url..statusd_weather.station..'.TXT 2> /dev/null', 'r')
   local data = f:read('*all')
   f:close()

   _, _, info.city =
      string.find(data, '^([%a%s?]+),.*%c')
   _, _, info.conditions =
      string.find(data, 'Sky%sconditions:%s([%a%s?]+)%c')
   _, _, info.fahrenheit, info.celsius =
      string.find(data, 'Temperature:%s([%-?%d%.]+)%sF%s%(([%-?%d%.]+)%sC%)%c')
   _, _, info.humidity =
      string.find(data, 'Relative%sHumidity:%s([%d]+%%)%c')
   _, _, info.precipitation =
      string.find(data, 'Precipitation%slast%shour:%s([%w%s?]+)%c')
   _, _, info.weather =
      string.find(data, 'Weather:%s([%a%s?]+)%c')

   return string.gsub(statusd_weather.template, '%%([%l]+)',
		      function(x) return(info[x] or "") end)
end

local weather_timer

local function update_weather()
   statusd.inform('weather', fetch_metar())
   weather_timer:set(statusd_weather.interval, update_weather)
end

weather_timer = statusd.create_timer()
update_weather()

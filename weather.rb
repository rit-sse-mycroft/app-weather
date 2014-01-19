require 'mycroft'
require 'weather_module'

class Weather < Mycroft::Client
  include WeatherModule
  attr_accessor :verified

  def initialize
    @key = ''
    @cert = ''
    @manifest = './app.json'
    @verified = false
    Barometer.config = { 1 => [:yahoo, :wunderground] }
  end

  def connect
    # Your code here
  end

  def on_data(data)
    parsed = parse_message(data)
    if parsed[:type] == 'APP_MANIFEST_OK' || parsed[:type] == 'APP_MANIFEST_FAIL'
      check_manifest(parsed)
      @verified = true
    elsif parsed[:type] == 'MSG_BROADCAST'
      barometer = Barometer.new('14623')
      weather = barometer.weather
      grammar = parsed[:data]['content']['grammar']
      unless grammar.nil?
        if grammar['name'] == 'weather'
          tags = grammar['tags']
          unless tags['rise_or_set'].nil?
            sunrise_sunset(weather, tags['day'], tags['rise_or_set'])
          elsif tags['day'] == 'current'
            current(weather)
          else
            today_tomorrow(weather, tags['day'])
          end
        end
      end
    elsif parsed[:type] == 'APP_DEPENDENCY'
      # do some stuff
    end
  end

  def on_end
    # Your code here
  end
end

Mycroft.start(Weather)

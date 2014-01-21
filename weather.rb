require 'mycroft'
require './weather_module'

class Weather < Mycroft::Client
  include WeatherModule
  attr_accessor :verified

  def initialize
    @key = ''
    @cert = ''
    @manifest = './app.json'
    @verified = false
    Barometer.config = { 1 => [:yahoo], 2 => :wunderground }
  end

  def connect
    # Your code here
  end

  def on_data(parsed)
    if parsed[:type] == 'MSG_BROADCAST'
      barometer = Barometer.new('14623')
      weather = barometer.measure
      grammar = parsed[:data]['content']
      unless grammar.nil?
        if grammar['grammar'] == 'weather'
          tags = grammar['tags']
          if not tags['rise_or_set'].nil?
            sunrise_sunset(weather, tags['day'], tags['rise_or_set'])
          elsif tags['day'] == 'currently'
            current(weather)
          else
            today_tomorrow(weather, tags['day'])
          end
        end
      end
    elsif parsed[:type] == 'APP_DEPENDENCY'
      up
      data = {grammar: { name: 'weather', xml: File.read('./grammar.xml')}}
      query('stt', 'load_grammar', data)
    end
  end

  def on_end
    # Your code here
  end
end

Mycroft.start(Weather)

require 'mycroft'
require './weather_module'

class Weather < Mycroft::Client
  include WeatherModule
  attr_accessor :verified

  def initialize(host, port)
    @key = ''
    @cert = ''
    @manifest = './app.json'
    @verified = false
    @sent_grammar = false
    Barometer.config = { 1 => [:yahoo], 2 => :wunderground }
    super
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
      if parsed[:data]['stt']['stt1'] == 'up' and not @sent_grammar
        up
        data = {grammar: { name: 'weather', xml: File.read('./grammar.xml')}}
        query('stt', 'load_grammar', data)
        @sent_grammar = true
      elsif parsed[:data]['stt']['stt1'] == 'down' and @sent_grammar
        @sent_grammar = false
        down
      end
    end
  end

  def on_end
    broadcast({unloadGrammar: 'weather'})
  end
end

Mycroft.start(Weather)

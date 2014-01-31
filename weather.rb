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
    @dependencies = {}
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
          if tags['day'] == 'currently'
            current(weather)
          elsif not tags['prefix'].nil?
            if tags['prefix'] == 'when is'
              sunrise_sunset(weather, tags['day'], tags['rise_or_set'])
            else
              until_sunrise_sunset(weather, tags['day'], tags['rise_or_set'])
            end
          else
            today_tomorrow(weather, tags['day'])
          end
        end
      end
    elsif parsed[:type] == 'APP_DEPENDENCY'
      if not parsed[:data]['stt'].nil?
        update_dependencies(parsed[:data])
        puts "Current status of dependencies"
        puts @dependencies
        if not @dependencies['stt'].nil?
          if @dependencies['stt']['stt1'] == 'up' and not @sent_grammar
            up
            data = {grammar: { name: 'weather', xml: File.read('./grammar.xml')}}
            query('stt', 'load_grammar', data)
            @sent_grammar = true
          elsif @dependencies['stt']['stt1'] == 'down' and @sent_grammar
            @sent_grammar = false
            down
          end
        end
      end
    end
  end

  def on_end
    query('stt', 'unload_grammar', {grammar: 'weather'})
  end
end

Mycroft.start(Weather)

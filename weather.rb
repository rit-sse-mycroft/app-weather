require 'mycroft'
require 'barometer'

class Weather < Mycroft::Client

  attr_accessor :verified

  def initialize
    @key = ''
    @cert = ''
    @manifest = './app.json'
    @verified = false
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
      current = barometer.measure.current
      if parsed[:data]['content']['text'].include? 'weather'
        condition = current.condition
        temperature = current.temperature.f
        send_weather("It is #{temperature} degrees and #{condition}")
      elsif parsed[:data]['content']['text'].include? 'sunrise'
        sunrise = current.sun.rise.localtime
        link = Time.now > sunrise ? 'was' : 'is'
        send_weather("Sunrise #{link} at #{sunrise.strftime('%I:%M %p')}.")
      elsif parsed[:data]['content']['text'].include? 'sunset'
        sunset = current.sun.set.localtime
        link = Time.now > sunset ? 'was' : 'is'
        send_weather("Sunset #{link} at #{sunset.strftime('%I:%M %p')}.")
      end
    elsif parsed[:type] == 'APP_DEPENDENCY'
      # do some stuff
    end
  end

  def on_end
    # Your code here
  end

  def send_weather(text)
    content = {text: text, targetSpeaker: "speakers"}
    query('tts', 'stream', content, ['text2speech'])
  end
end

Mycroft.start(Weather)

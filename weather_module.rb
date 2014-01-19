require 'barometer'

module WeatherModule

  def current(weather)
    current = weather.current
    temperature = current.temperature.f
    condition = current.condition
    send_weather("It is #{temperature} degrees and #{condition}")
  end

  def today_tomorrow(weather, day)
    condition = weather.condition
    high = weather.high.f
    low = weather.low.f
    send_weather("#{day}, it will be #{condition} with a high of #{high} and a low of #{low}")
  end

  def sunrise_sunset(weather, day, rise_or_set)
    time = weather.send(day.to_sym).sun.send(rise_or_set.to_sym).localtime
    link = Time.now > sunrise ? 'was' : 'is'
    send_weather("#{day}, sun#{rise_or_set} #{link} at #{time.strftime('%I:%M %p')}")
  end

  def send_weather(text)
    content = {text: text, targetSpeaker: "speakers"}
    query('tts', 'stream', content, ['text2speech'])
  end
end
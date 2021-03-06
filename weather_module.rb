require 'barometer'
require 'action_view'

module WeatherModule

  include ActionView::Helpers::DateHelper

  def current(weather)
    current = weather.current
    temperature = current.temperature.f
    condition = current.condition
    send_weather("It is #{temperature} degrees and #{condition}")
  end

  def today_tomorrow(weather, day)
    weather = weather.send(day.to_sym)
    condition = weather.condition
    high = weather.high.f
    low = weather.low.f
    send_weather("#{day}, it will be #{condition} with a high of #{high} and a low of #{low}")
  end

  def sunrise_sunset(weather, day, rise_or_set)
    time = weather.send(day.to_sym).sun.send(rise_or_set.to_sym).localtime
    link = Time.now > time ? 'was' : 'is'
    send_weather("#{day}, sun#{rise_or_set} #{link} at #{time.strftime('%I:%M %p')}")
  end

  def until_sunrise_sunset(weather, day, rise_or_set)
    time = weather.send(day.to_sym).sun.send(rise_or_set.to_sym).localtime
    link = Time.now > time ? ['was', 'ago'] : ['is in', '']
    time = distance_of_time_in_words_to_now(time)
    send_weather("#{day}, sun#{rise_or_set} #{link[0]} #{time} #{link[1]}")
  end

  def send_weather(text)
    array = [{phrase: text, delay: 0}]
    content = {text: array, targetSpeaker: "speakers"}
    query('tts', 'stream', content)
  end
end
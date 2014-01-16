require 'mycroft'

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
    # Your code here
  end

  def on_end
    # Your code here
  end
end

Mycroft.start(Weather)

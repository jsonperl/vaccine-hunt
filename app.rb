require 'json'
require 'logger'
require 'dotenv/load'
require 'twilio-ruby'

require_relative 'cvs'
require_relative 'sms'

LOGGER = Logger.new(STDOUT)
LOGGER.level = Logger::INFO

class App
  def hunt
    locations = Cvs.new.locations

    if locations.empty?
      LOGGER.info('No locations available')
      return
    end

    Sms.new.dispatch(ENV['MY_NUMBER'], locations)
  end
end

App.new.hunt

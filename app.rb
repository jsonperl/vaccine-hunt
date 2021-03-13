require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'])

LOGGER = Logger.new(STDOUT)
LOGGER.level = Logger::INFO

ENVIRONMENT = ENV['RACK_ENV']

require 'dotenv/load' if ENVIRONMENT == 'development'
require_relative 'cvs'
require_relative 'sms'

class App
  attr_accessor :scheduler

  def initialize
    @scheduler = Rufus::Scheduler.new
  end

  def run
    hunt

    scheduler.in '1m' do
      LOGGER.info('Hunting...')
      hunt
    end

    scheduler.join
  end

  def hunt
    locations = Cvs.new.locations

    if locations.empty?
      LOGGER.info('No locations available')
      return
    end

    Sms.new.dispatch(ENV['MY_NUMBER'], locations)
  end
end

app = App.new
app.run

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'])

LOGGER = Logger.new(STDOUT)
LOGGER.level = Logger::INFO

ENVIRONMENT = ENV['RACK_ENV']

REDIS = if ENV['REDISLAB_ENDPOINT']
          Redis.new(
            host: ENV['REDISLAB_ENDPOINT'].split(':')[0],
            port: ENV['REDISLAB_ENDPOINT'].split(':')[1],
            password: ENV['REDISLAB_PW']
          )
        else
          Redis.new
        end

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

    scheduler.every '5m' do
      LOGGER.info('Hunting...')
      hunt
    end
  end

  def hunt
    locations = Cvs.new.locations
    Sms.new.dispatch(ENV['MY_NUMBER'], locations)
  end
end

app = App.new
app.run

set :port, ENV['PORT'] || '8080'
set :bind, '0.0.0.0'

get '/healthcheck' do
  "OK\n"
end

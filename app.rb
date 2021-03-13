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
require_relative 'people'

class App
  attr_accessor :scheduler, :people, :states

  def initialize
    @scheduler = Rufus::Scheduler.new
    @people = People.all
    @states = @people.map(&:state).uniq
  end

  def run
    frequency = ENV['RACK_ENV'] == 'development' ? '5s' : '5m'

    scheduler.every frequency do
      @states.each do |state|
        hunt(state)
      end
    end
  end

  def hunt(state)
    LOGGER.info("Hunting in #{state}...")

    locations = Cvs.new(state).locations
    @people.each do |person|
      Sms.new.dispatch(person.number, locations) if person.state == state
    end
  end
end

app = App.new
app.run

set :port, ENV['PORT'] || '8080'
set :bind, '0.0.0.0'

get '/healthcheck' do
  "OK\n"
end

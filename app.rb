ENVIRONMENT = Class.new do
  def self.prod?
    !dev?
  end

  def self.dev?
    env == 'development'
  end

  def self.env
    ENV['RACK_ENV']
  end
end

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, ENVIRONMENT.env)

require 'dotenv/load' if ENVIRONMENT.dev?

LOGGER = Logger.new($stdout)
LOGGER.level = Logger::INFO

REDIS = if ENV['REDISLAB_ENDPOINT']
          Redis.new(
            host: ENV['REDISLAB_ENDPOINT'].split(':')[0].strip,
            port: ENV['REDISLAB_ENDPOINT'].split(':')[1].strip,
            password: ENV['REDISLAB_PW'].strip
          )
        else
          Redis.new
        end

require_relative 'cvs'
require_relative 'sms'
require_relative 'location'
require_relative 'people'

class App
  attr_accessor :scheduler, :people, :states

  def initialize
    @scheduler = Rufus::Scheduler.new
    @people = People.all
    @states = @people.map(&:state).uniq
  end

  def frequency
    @frequency ||= ENV['RACK_ENV'] == 'development' ? 5 : 300
  end

  def run
    if ENVIRONMENT.dev?
      hunt
    else
      scheduler.in('1s') { hunt }
      scheduler.every("#{frequency}s") { hunt }
    end
  end

  def hunt
    if Cvs.unavailable?
      LOGGER.warn 'CVS Unavailable for hunting'
      return
    end

    @states.each do |state|
      LOGGER.info("Hunting in #{state}...")

      locations = filter(Cvs.new(state).locations)
      if locations.empty?
        LOGGER.info('Nothing found...')
      else
        LOGGER.info("Found #{locations.map { |loc| loc.name }.join(', ')}")
      end

      @people.each do |person|
        sms_locations = locations & (person.locations.length > 0 ? person.locations : locations)
        Sms.new.dispatch(person, sms_locations) if person.state == state
      end
    end
  end

  def filter(locations)
    # Reset the TTL and filter to locations unseen for 3x the frequency
    locations.select do |loc|
      prev = REDIS.getset(loc.key, true)
      REDIS.expire(loc.key, frequency * 3)

      prev.nil?
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

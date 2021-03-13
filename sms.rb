class Sms
  attr_reader :client

  def initialize
    @client = Twilio::REST::Client.new(
      ENV['TWILIO_SID'],
      ENV['TWILIO_AUTH_TOKEN']
    )
  end

  def dispatch(number, locations)
    locations = unbounce(number, locations)
    return if locations.empty?

    body = "Appointment available at #{locations.join(', ')}"

    LOGGER.info("SMS #{number} - #{body}")
    return if ENVIRONMENT == 'development'

    client.messages.create(
      from: ENV['TWILIO_FROM_NUMBER'],
      to: number,
      body: body
    )
  end

  def unbounce(number, locations)
    locations.select do |loc|
      REDIS.set("#{number}:#{loc}", true, ex: 86_400, nx: true) # 24 hours
    end
  end
end

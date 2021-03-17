class Sms
  HEADER = "💉Vaccine Hunter💉\n"

  attr_reader :client

  def initialize
    @client = Twilio::REST::Client.new(
      ENV['TWILIO_SID'],
      ENV['TWILIO_AUTH_TOKEN']
    )
  end

  def dispatch(person, locations)
    return if locations.empty?

    body = HEADER + 'CVS Locations: ' + locations.map { |l| l.name }.join(', ')
    LOGGER.info("SMS #{person.number} - #{body}")

    return if ENVIRONMENT.dev?

    client.messages.create(
      from: ENV['TWILIO_FROM_NUMBER'],
      to: person.number,
      body: body
    )
  end
end

class Sms
  attr_reader :client

  def initialize
    @client = Twilio::REST::Client.new(
      ENV['TWILIO_SID'],
      ENV['TWILIO_AUTH_TOKEN']
    )
  end

  def dispatch(number, locations)
    client.messages.create(
      from: ENV['TWILIO_FROM_NUMBER'],
      to: number,
      body: "Appointment available at #{locations.join(', ')}"
    )
  end
end

class Cvs
  attr_reader :state

  LOCATIONS = JSON.parse(File.read('data/cvs_location.json'))

  def initialize(state)
    @state = state.upcase
  end

  def locations
    available = data['responsePayloadData']['data'][state].select do |loc|
      loc['status'] == 'Available'
    end

    available.map do |avail|
      Location.new(:cvs, avail['city'])
    end
  end

  def data
    JSON.parse(`curl -s '#{url}' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:87.0) Gecko/20100101 Firefox/87.0' --compressed -H 'Accept: */*' --compressed -H 'Referer: https://www.cvs.com/immunizations/covid-19-vaccine?icid=cvs-home-hero1-link2-coronavirus-vaccine'`)
  end

  def url
    "https://www.cvs.com/immunizations/covid-19-vaccine.vaccine-status.#{state.downcase}.json?vaccineinfo"
  end

  def self.unavailable?
    uri = URI('https://www.cvs.com/vaccine/intake/store/cvd-schedule?icid=coronavirus-lp-vaccine-sd-statetool')
    res = Net::HTTP.get_response(uri)

    res.code == '503' && !!res.body.match('<title>Vaccine Waiting Room page</title>')
  end
end

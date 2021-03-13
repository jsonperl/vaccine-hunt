class Cvs
  attr_reader :state

  def initialize(state)
    @state = state.upcase
  end

  def locations
    data['responsePayloadData']['data'][state].select do |loc|
      loc['status'] == 'Available'
    end.map { |s| s['city'] }.sort
  end

  def data
    JSON.parse(`curl -s '#{url}' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:87.0) Gecko/20100101 Firefox/87.0' -H 'Accept: */*' --compressed -H 'Referer: https://www.cvs.com/immunizations/covid-19-vaccine?icid=cvs-home-hero1-link2-coronavirus-vaccine'`)
  end

  def url
    "https://www.cvs.com/immunizations/covid-19-vaccine.vaccine-status.#{state.downcase}.json?vaccineinfo"
  end
end

class Cvs
  def locations
    data = JSON.parse(`curl -s 'https://www.cvs.com/immunizations/covid-19-vaccine.vaccine-status.oh.json?vaccineinfo' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:87.0) Gecko/20100101 Firefox/87.0' -H 'Accept: */*' --compressed -H 'Referer: https://www.cvs.com/immunizations/covid-19-vaccine?icid=cvs-home-hero1-link2-coronavirus-vaccine'`)

    state = data['responsePayloadData']['data']['OH']
    state.select { |loc| loc['status'] == 'Available' }.map { |s| s['city'] }.sort
  end
end

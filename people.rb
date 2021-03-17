class Person
  attr_accessor :name, :number, :state, :zip, :locations

  def initialize(name, number, state, zip, locations)
    @name = name
    @number = number
    @state = state
    @zip = zip
    @locations = locations
  end
end

class People
  KEYS = ENV.keys.select { |k| k.match(/^PEOPLE/) }

  def self.all
    KEYS.map do |key|
      p = ENV[key].split(':')

      Person.new(
        key.split('_')[1],
        p[0],
        p[1],
        p[2],
        (p[3] || '').split(',')
      )
    end
  end
end

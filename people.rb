class Person
  attr_accessor :state, :number

  def initialize(number, state)
    @number = number
    @state = state
  end
end

class People
  def self.all
    ENV['PEOPLE'].split(',').map do |p|
      Person.new(*p.split(':'))
    end
  end
end

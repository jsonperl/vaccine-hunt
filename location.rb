class Location
  attr_accessor :kind, :name

  def initialize(kind, name)
    @kind = kind
    @name = name
  end

  def key
    [@kind.upcase, name].join(':')
  end
end

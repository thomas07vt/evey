class Evey::Reactor
  def self.call(event)
    new(event).call
  end

  attr_accessor :event

  def initialize(event)
    @event = event
  end

  def call
  end
end

class Evey::ReactorJob < ActiveJob::Base
  def perform(event, reactor_class)
    reactor = reactor_class.constantize

    reactor.call(event)
  end
end

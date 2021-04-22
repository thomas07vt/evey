require "spec_helper"

RSpec.describe Evey::Reactor do
  let(:reactor) do
    Class.new(Evey::Reactor) do
      def call
        # Do something with event
        event.type
      end
    end
  end

  describe ".call" do
    it "instantiates and calls the reactor with the event" do
      event = Evey::Event.new
      expect(reactor.call(event)).to eq("Evey::Event")
    end
  end
end


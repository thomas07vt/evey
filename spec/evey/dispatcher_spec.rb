require "spec_helper"

RSpec.describe Evey::Dispatcher do
  class RspecConfigReactor < Evey::Reactor
    class << self
      attr_accessor :was_hit
    end

    def call
      self.class.was_hit = true
    end
  end

  class RspecConfigReactorAsync < Evey::Reactor
    class << self
      attr_accessor :was_hit
    end

    def call
      self.class.was_hit = true
    end
  end

  describe ".enable!" do
    it "enables the dispatcher" do
      described_class.enable!
      expect(described_class.enabled?).to eq(true)
    end
  end

  describe ".disable!" do
    it "disables the dispatcher" do
      described_class.disable!
      expect(described_class.enabled?).to eq(false)
    end
  end

  describe ".configure" do
    let(:dispatcher) {  Class.new(Evey::Dispatcher) }

    it "allows configuration of the dispatcher" do
      dispatcher.configure do |config|
        config.on EveyEvent, sync: RspecConfigReactor, async: RspecConfigReactorAsync
      end

      reactors = dispatcher.rules.for(EveyEvent.new)
      expect(reactors.sync.to_a).to eq([RspecConfigReactor])
      expect(reactors.async.to_a).to eq([RspecConfigReactorAsync])
    end
  end

  describe ".dispatch" do
    let(:dispatcher) {  Class.new(Evey::Dispatcher) }
    let(:event) { EveyEvent.create! }

    before do
      dispatcher.configure do |config|
        config.on EveyEvent, sync: RspecConfigReactor, async: RspecConfigReactorAsync
      end
    end

    it "dispatches the event to sync reactors" do
      dispatcher.dispatch(event)
      expect(RspecConfigReactor.was_hit).to eq(true)
    end

    it "enqueues reactor jobs for async reactors" do
      expect { dispatcher.dispatch(event) }.to have_enqueued_job(Evey::ReactorJob)
    end
  end
end


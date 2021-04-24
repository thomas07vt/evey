require "spec_helper"

RSpec.describe Evey::Dispatcher do
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
        config.on DummyEvent, sync: SyncReactor, async: AsyncReactor
      end

      reactors = dispatcher.rules.for(DummyEvent.new)
      expect(reactors.sync.to_a).to eq([SyncReactor])
      expect(reactors.async.to_a).to eq([AsyncReactor])
    end
  end

  describe ".dispatch" do
    let(:dispatcher) {  Class.new(Evey::Dispatcher) }
    let(:event) { DummyEvent.create! }

    before do
      allow(SyncReactor).to receive(:call)
      allow(AsyncReactor).to receive(:call)
      dispatcher.configure do |config|
        config.on DummyEvent, sync: SyncReactor, async: AsyncReactor
      end
    end

    it "dispatches the event to sync reactors" do
      dispatcher.dispatch(event)
      expect(SyncReactor).to have_received(:call).with(event)
      expect(AsyncReactor).not_to have_received(:call).with(event)
    end

    it "enqueues reactor jobs for async reactors" do
      expect { dispatcher.dispatch(event) }.to have_enqueued_job(Evey::ReactorJob)
    end
  end
end


require "spec_helper"

RSpec.describe Evey::Types::Association do
  describe "#deserialize" do
    it "converts the hash global ids to objects" do
      event = DummyEvent.create!
      hash = { "event" => event.to_global_id.to_s }
      result = Evey::Types::Association.new.deserialize(hash)

      expect(result["event"]).to eq(event)
    end

    context "when an error occurs decoding a value" do
      it "returns nil" do
        result = Evey::Types::Association.new.deserialize("invalid json")
        expect(result).to eq(nil)
      end
    end
  end

  describe "#serialize" do
    it "converts hash to json with global ids" do
      event = DummyEvent.create!
      hash = { "event" => event }
      result = Evey::Types::Association.new.serialize(hash)

      expect(result).to eq({ "event" => event.to_global_id.to_s }.to_json)
    end
  end
end


require "spec_helper"

RSpec.describe Evey::Event, type: :model do
  class SpecEveyEventClass < Evey::Event
    aggregate :org
    association :user
    data_attributes :name
  end

  describe ".aggregates" do
    it "allows a user to set an aggregate" do
      org = Org.new(name: "hi")

      event = SpecEveyEventClass.new
      event.org = org
      expect(event.org).to eq(org)
    end

    it "hydrates the aggregate after a persist and lookup" do
      class SpecHydrateAggregateEvent < Evey::Event
        aggregate :org
      end

      org = Org.create!(name: "hi")
      event = SpecHydrateAggregateEvent.new(org: org)
      event.save!
      event = Evey::Event.find(event.id)
      expect(event.org).to eq(org)
    end
  end

  describe ".associations" do
    it "allows a user to set an association" do
      user = create(:user)

      event = SpecEveyEventClass.new
      event.user = user
      expect(event.user).to eq(user)
    end

    it "hydrates the aggregate after a persist and lookup" do
      class SpecHydrateAccociationEvent < Evey::Event
        association :user
      end

      user = create(:user)
      event = SpecHydrateAccociationEvent.new(user: user)
      event.save!
      event = Evey::Event.find(event.id)
      expect(event.user).to eq(user)
    end
  end

  describe ".as_json" do
    let(:user) { create(:user) }
    let(:org) { create(:org, name: "Name", owner: user) }
    let(:event) { SpecEveyEventClass.new(user: user, org: org) }

    it "serializes with the correct keys" do
      expect(event.as_json.keys)
        .to eq(["type", "data", "metadata", "aggregates", "associations", "created_at", "updated_at"])
    end

    it "serializes the aggregates correctly" do
      expect(event.as_json["aggregates"]).to eq({ "org" => org.as_json })
    end

    it "serializes the associations correctly" do
      expect(event.as_json["associations"]).to eq({ "user" => user.as_json })
    end

    context "when an aggretate is invalid" do
      let(:org) { Org.new(owner: user) }

      it "serializes the errors related to the aggregate" do
        event.save
        expect(event.as_json["errors"]).to be_present
        expect(event.as_json["errors"]["org"]).to eq({ "name" => ["can't be blank"] })
      end
    end
  end

  describe ".data_attributes" do
    it "adds accessors on the event object" do
      event = SpecEveyEventClass.new(name: "event_name")
      expect(event.name).to eq("event_name")
      event.name = "New Name"
      expect(event.name).to eq("New Name")
    end
  end

  describe ".request_hook" do
    class SpecRequestHookEventClass < Evey::Event
      request_hook { |event| puts event.name }
    end

    it "sets the request_hook proc" do
      event = SpecRequestHookEventClass.new
      expect(event.request_hook).to be_a(Proc)
    end
  end

  describe "#data" do
    it "returns the data attributes for the event" do
      event = SpecEveyEventClass.new(name: "event_name")
      expect(event.data).to eq({"name"=>"event_name"})
    end
  end

  describe "#attribute_was_set?" do
    it "returns true when the attribute was set" do
      event = SpecEveyEventClass.new(name: "event_name")
      expect(event.name_was_set?).to eq(true)
    end

    it "return false when the attribute was not set" do
      event = SpecEveyEventClass.new
      expect(event.name_was_set?).to eq(false)
    end
  end
end

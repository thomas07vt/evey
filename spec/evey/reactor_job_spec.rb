require "spec_helper"

RSpec.describe Evey::ReactorJob, type: :job do
  class RspecReactor < Evey::Reactor
    def self.times_hit
      @times_hit ||= 0
    end

    def self.hit
      @times_hit ||= 0
      @times_hit += 1
    end

    def call
      self.class.hit
    end
  end

  describe "#perform" do
    it "invokes a reactor with the passed event" do
      Evey::ReactorJob.perform_now(Evey::Event.new, "RspecReactor")
      expect(RspecReactor.times_hit).to eq(1)
    end
  end
end


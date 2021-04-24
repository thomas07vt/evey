class DummyEvent < Evey::Event
  data_attributes :applied

  def apply
    self.applied = true
  end
end

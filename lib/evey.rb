module Evey
  def self.table_name_prefix
    "evey_"
  end
end

require "kix"
require "active_job"
require "active_record"
require "active_support"
require "active_support/core_ext/object/json.rb"

require "rails/generators"
require "rails/generators/migration"

require "evey/types.rb"
require "evey/types/association.rb"
require "evey/event_serializer.rb"
require "evey/event.rb"
require "evey/version.rb"
require "evey/reactor.rb"
require "evey/dispatcher.rb"
require "evey/reactor_job.rb"

module Evey
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path(__dir__)

    def create_migration
      template "migration.erb", "db/migrate/#{Time.current.strftime("%Y%m%d%H%M%S")}_create_evey_events.rb"
    end
  end
end


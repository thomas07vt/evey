# frozen_string_literal: true

require "pry"
require "simplecov"

SimpleCov.start { add_filter %r{^/spec/} }
SimpleCov.minimum_coverage 100

require File.expand_path('./support/dummy_app/config/environment.rb', __dir__)
ENV['RAILS_ROOT'] ||= "./support/dummy_app"

require 'rspec/rails'

require "evey"

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

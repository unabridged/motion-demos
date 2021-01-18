ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

require "minitest/spec"
require "mocha/minitest"

class BindMockComponent < ViewComponent::Base
  include Motion::Component
end

def run_motion(component, motion_name, event = motion_event)
  component.process_motion(motion_name.to_s, event)
end

def motion_event(attrs = {})
  Motion::Event.new(ActiveSupport::JSON.decode(attrs.to_json))
end

def callback_stub(method_name = :bound)
  Motion::Callback.new(BindMockComponent.new, method_name)
end

def process_broadcast(component, method_name, msg)
  callback = component.bind(method_name)
  component.process_broadcast(callback.broadcast, msg)
end

class ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class MiniTest::Spec
  include ActiveSupport::Testing::TimeHelpers
  include ActiveSupport::Testing::Assertions
end

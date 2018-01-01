require 'rubygems'
require 'bundler/setup'

ENV["RAILS_ENV"] ||= 'test'
APIPIE_ROOT = File.expand_path('../..', __FILE__)
require File.expand_path("../dummy/config/environment", __FILE__)

require 'rspec/rails'

require 'apipie-rails'

module Rails4Compatibility
  module Testing
    def process(*args)
      compatible_request(*args) { |*new_args| super(*new_args) }
    end

    def compatible_request(method, action, hash = {})
      if hash.is_a?(Hash)
        if Gem::Version.new(Rails.version) < Gem::Version.new('5.0.0')
          hash = hash.dup
          hash.merge!(hash.delete(:params) || {})
        elsif hash.key?(:params)
          hash = { :params => hash }
        end
      end
      if hash.empty?
        yield method, action
      else
        yield method, action, hash
      end
    end
  end
end

RSpec::Matchers.define :match_param_structure do |expected|
  @last_message = nil

  match do |actual|
    deep_match?(actual, expected)
  end

  def deep_match?(actual, expected, breadcrumb=[])
    num = 0
    for pdesc in expected do
      if pdesc.is_a? Symbol
        return false unless fields_match?(actual.params_ordered[num], pdesc, breadcrumb)
      elsif pdesc.is_a? Hash
        return false unless fields_match?(actual.params_ordered[num], pdesc.keys[0], breadcrumb)
        return false unless deep_match?(actual.params_ordered[num].validator, pdesc.values[0], breadcrumb + [pdesc.keys[0]])
      end
      num+=1
    end
    @fail_message = "expected property count#{breadcrumb == [] ? '' : ' of ' + (breadcrumb).join('.')} (#{actual.params_ordered.count}) to be #{num}"
    actual.params_ordered.count == num
  end

  def fields_match?(param, expected_name, breadcrumb)
    return false unless have_field?(param, expected_name, breadcrumb)
    @fail_message = "expected #{(breadcrumb + [param.name]).join('.')} to eq #{(breadcrumb + [expected_name]).join('.')}"
    param.name.to_s == expected_name.to_s
  end

  def have_field?(field, expected_name, breadcrumb)
    @fail_message = "expected property #{(breadcrumb+[expected_name]).join('.')}"
    !field.nil?
  end

  failure_message do |actual|
    @fail_message
  end
end



# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f}

RSpec.configure do |config|

  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # rspec-rails 3 will no longer automatically infer an example group's spec type
  # from the file location. You can explicitly opt-in to the feature using this
  # config option.
  # To explicitly tag specs without using automatic inference, set the `:type`
  # metadata manually:
  #
  #     describe ThingsController, :type => :controller do
  #       # Equivalent to being in spec/controllers
  #     end
  config.infer_spec_type_from_file_location!
end

require 'action_controller/test_case.rb'
ActionController::TestCase::Behavior.send(:prepend, Rails4Compatibility::Testing)

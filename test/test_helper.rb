require 'simplecov'

SimpleCov.start do
  if ENV['CI']=='true'
    require 'codecov'
    SimpleCov.formatter = SimpleCov::Formatter::Codecov
  end
end

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../test/dummy/config/environment.rb",  __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../test/dummy/db/migrate", __FILE__)]
require "rails/test_help"
require "rails/all"

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load resource helpers
Dir[File.join(File.dirname(__FILE__), 'dummy','test', 'montage_resources', '*.rb')].each do |file|
  require file
end

require 'minitest/autorun'
require 'shoulda-context'
require 'mocha/setup'
require 'webmock/minitest'

WebMock.disable_net_connect!(:allow => "codecov.io")
WebMock.disable_net_connect!(:allow => "127.0.0.1")

class MiniTest::Test
  @@default_headers = {
    'Accept' => '*/*',
    'Authorization' => 'Token fb761e07-a12b-40bb-a42f-2202ecfd1046',
    'Content-Type' => 'application/json',
    'User-Agent' => "Montage Ruby v#{Montage::VERSION}"
  }

  def setup
    MontageRails.configure do |c|
      c.token = "fb761e07-a12b-40bb-a42f-2202ecfd1046"
      c.domain = "testco"
      c.use_mock_server = true
    end
  end
end

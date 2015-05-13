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
Dir[File.join(File.dirname(__FILE__), 'resources', '**', '*.rb')].each do |file|
  require file
end

require 'minitest/autorun'
require 'shoulda-context'
require 'mocha/setup'
require 'webmock/minitest'

WebMock.disable_net_connect!(:allow => "codecov.io")

class MiniTest::Test
  @@default_headers = {
    'Accept' => '*/*',
    'Authorization' => 'Token fb761e07-a12b-40bb-a42f-2202ecfd1046',
    'Content-Type' => 'application/json',
    'User-Agent' => "Montage Ruby v#{Montage::VERSION}"
  }

  def setup
    # Stub the request for getting the movie schema definition
    #
    stub_request(:get, "http://testco.dev.montagehot.club/api/v1/schemas/movies/")
      .with(headers: @@default_headers).to_return(
        status: 200,
        body: MontageRails::MovieResource.schema_definition.to_json,
        headers: {
          'Content-Type' => 'application/json'
        }
      )

    # Stub the save movie request
    #
    stub_request(:post, "http://testco.dev.montagehot.club/api/v1/schemas/movies/save/").
      with(body: [ MontageRails::MovieResource.to_hash ].to_json, headers: @@default_headers).to_return(
        body: MontageRails::MovieResource.save_response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub the save movie request
    #
    stub_request(:post, "http://testco.dev.montagehot.club/api/v1/schemas/movies/save/").
      with(body: [ MontageRails::MovieResource.save_with_update_hash ].to_json, headers: @@default_headers).to_return(
        body: MontageRails::MovieResource.save_response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub the update movie request
    #
    stub_request(:post, "http://testco.dev.montagehot.club/api/v1/schemas/movies/save/").
      with(body: MontageRails::MovieResource.update_body.to_json, headers: @@default_headers).to_return(
        body: MontageRails::MovieResource.update_response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub the request for getting the actor schema definition
    #
    stub_request(:get, "http://testco.dev.montagehot.club/api/v1/schemas/actors/")
      .with(headers: @@default_headers).to_return(
        status: 200,
        body: MontageRails::ActorResource.schema_definition.to_json,
        headers: {
          'Content-Type' => 'application/json'
        }
      )

    # Stub the creation of Steve Martin
    #
    stub_request(:post, "http://testco.dev.montagehot.club/api/v1/schemas/actors/save/").
      with(body: [ MontageRails::ActorResource.steve_martin ].to_json, headers: @@default_headers).to_return(
        body: MontageRails::ActorResource.save_steve_response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub the creation of Mark Hamill
    #
    stub_request(:post, "http://testco.dev.montagehot.club/api/v1/schemas/actors/save/").
      with(body: [ MontageRails::ActorResource.mark_hamill ].to_json, headers: @@default_headers).to_return(
        body: MontageRails::ActorResource.save_mark_response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub the actor query
    #
    stub_request(:post, "http://testco.dev.montagehot.club/api/v1/schemas/actors/query/").
      with(body: MontageRails::ActorResource.query.to_json, headers: @@default_headers).to_return(
        body: MontageRails::ActorResource.query_result.to_json,
        headers: { 'Content-Type' => 'application/json'}
      )

    # Stub the movie query
    #
    stub_request(:post, "http://testco.dev.montagehot.club/api/v1/schemas/movies/query/").
      with(body: MontageRails::MovieResource.movie_query.to_json, headers: @@default_headers).to_return(
        body: MontageRails::MovieResource.query_result.to_json,
        headers: { 'Content-Type' => 'application/json'}
      )

    # Stub the movie relation query for actors
    #
    stub_request(:post, "http://testco.dev.montagehot.club/api/v1/schemas/actors/query/").
      with(body: MontageRails::ActorResource.relation_query.to_json, headers: @@default_headers).to_return(
        body: MontageRails::ActorResource.relation_response.to_json,
        headers: { 'Content-Type' => 'application/json'}
      )

    # Stub the movie relation query for getting the first actor
    #
    stub_request(:post, "http://testco.dev.montagehot.club/api/v1/schemas/actors/query/").
      with(body: MontageRails::ActorResource.relation_first_query.to_json, headers: @@default_headers).to_return(
        body: MontageRails::ActorResource.relation_response.to_json,
        headers: { 'Content-Type' => 'application/json'}
      )

    # Stub the schema definition request for studios
    #
    stub_request(:get, "http://testco.dev.montagehot.club/api/v1/schemas/studios/").
      with(headers: @@default_headers).to_return(
        body: MontageRails::StudioResource.schema_definition.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub the save studio action
    #
    stub_request(:post, "http://testco.dev.montagehot.club/api/v1/schemas/studios/save/").
      with(body: [ MontageRails::StudioResource.to_hash ].to_json, headers: @@default_headers).to_return(
        body: MontageRails::StudioResource.save_response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub the get studio response
    #
    stub_request(:get, "http://testco.dev.montagehot.club/api/v1/schemas/studios/19442e09-5c2d-4e5d-8f34-675570e81414/").
      with(headers: @@default_headers).to_return(
        body: MontageRails::StudioResource.get_studio_response.to_json,
        headers: { 'Content-Type' => 'applicaiton/json' }
      )

    # Stub the find by query for movies
    #
    stub_request(:post, "http://testco.dev.montagehot.club/api/v1/schemas/movies/query/").
      with(body: MontageRails::MovieResource.find_movie_query.to_json, headers: @@default_headers).to_return(
        body: MontageRails::MovieResource.query_result.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub the find by query for movies that returns no results
    #
    stub_request(:post, "http://testco.dev.montagehot.club/api/v1/schemas/movies/query/").
      with(body: MontageRails::MovieResource.movie_not_found_query.to_json, headers: @@default_headers).to_return(
        body: { data: [] }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub the all query for movies
    #
    stub_request(:post, "http://testco.dev.montagehot.club/api/v1/schemas/movies/query/").
      with(body: MontageRails::MovieResource.all_movies_query.to_json, headers: @@default_headers).to_return(
        body: MontageRails::MovieResource.query_result.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub the greater than relation
    #
    stub_request(:post, "http://testco.dev.montagehot.club/api/v1/schemas/movies/query/").
      with(body: MontageRails::MovieResource.gt_query.to_json, headers: @@default_headers).to_return(
        body: MontageRails::MovieResource.query_result.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end

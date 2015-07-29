require 'montage/version'
require 'montage/client'
require 'montage/resources'
require 'montage/query'

require 'montage_rails/version'
require 'montage_rails/errors'
require 'montage_rails/base'
require 'montage_rails/query_cache'
require 'montage_rails/mock_server'
require 'montage_rails/application_resource'

require 'montage_rails/railtie' if defined?(Rails)

module MontageRails
  class << self
    attr_accessor :username, :password, :token, :domain, :no_caching, :use_mock_server, :server_url

    def configure
      yield self
      validate
      get_token unless token
    end

    def set_url_prefix(url)
      @url_prefix=url
    end

    def url_prefix=(value)
      @url_prefix=value
    end

    def url_prefix
      if Rails.env.test? && !@server_url && @use_mock_server
        @server_url = 'localhost:3000'
        # Capybara::Discoball.spin(MockServer) do |server|
        #   @server_url = server.url('/')
        # end
      end
      @server_url
    end

    def connection
      @connection ||= begin
        Montage::Client.new do |c|
          c.token = token
          c.domain = domain
          c.url_prefix = url_prefix
        end
      end
    end

    def notify(caller, &block)
      ActiveSupport::Notifications.instrument("reql.montage_rails", caller.payload) do
        yield
      end
    end

  private

    def validate
      raise AttributeMissingError, "You must include a domain" unless domain
      raise AttributeMissingError, "You must include a username and password if no token is given" unless token || (username && password)
    end

    def get_token
      c = Montage::Client.new do |c|
        c.domain = domain
        c.username = username
        c.password = password
      end

      response = c.auth

      raise MontageAPIError, "There was a problem authenticating with your username and password for domain #{domain}" unless response.success?

      @token = response.token.value
    end
  end
end

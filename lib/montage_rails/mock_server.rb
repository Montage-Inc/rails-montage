require 'sinatra/base'

module MontageRails
  class MockServer < Sinatra::Base
    include ActiveSupport::Inflector
    before do
      content_type :json
      puts params
      puts request.path_info
    end

    get '/api/v1/schemas/:schema/query' do
      require rail
      klass = ("#{params[:schema].classify}"+'Resource').constantize
      klass.schema_definition.to_json
    end

    get '/' do
      value = 'This is the rooooot!'
      value += relative_path
      value
    end

    get 'api/v1/files' do
      {data:{}}.to_json
    end
  end
end
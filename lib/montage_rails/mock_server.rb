require 'sinatra/base'

module MontageRails
  class MockServer < Sinatra::Base
    before do
      content_type :json
    end

    get "/api/v1/schemas/:schema" do
      klass = "#{params[:schema].classify}Resource".constantize
      klass.schema_definition.to_json
    end

    get 'api/v1/files' do
      {data:{}}.to_json
    end
  end
end
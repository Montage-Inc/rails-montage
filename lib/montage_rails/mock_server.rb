require 'sinatra/base'

module MontageRails
  class MockServer < Sinatra::Base
    include ActiveSupport::Inflector

    def fetch_schema_resource(schema)
      require Rails.root.join('test','montage_resources',(schema.singularize+'_resource.rb')).to_s
      "#{schema.singularize.classify}Resource".constantize.new
    end

    def load_schema(schema)
      require Rails.root.join('test','montage_resources',(schema.singularize+'_resource.rb')).to_s
      "#{schema.singularize.classify}Resource".constantize.new
    end

    def post_payload
      return unless request.body.length > 0
      request.body.rewind
      JSON.parse request.body.read
    end

    before do
      content_type :json
    end

    post '/api/v1/query' do
      resource = fetch_schema_resource(post_payload["query"]["$schema"])
      data = resource.query(post_payload["query"])
      { data: { query: data } }.to_json
    end

    get '/api/v1/schemas/:schema' do
      fetch_schema_resource(params[:schema]).class.schema_definition.to_json
    end

    get '/api/v1/schemas/:schema/:uuid' do
      fetch_schema_resource(params[:schema]).find(params[:uuid]).to_json
    end

    post '/api/v1/schemas/:schema/save' do
      { data: post_payload }.to_json
    end
  end
end

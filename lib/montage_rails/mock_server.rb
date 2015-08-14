require 'sinatra/base'

module MontageRails
  class MockServer < Sinatra::Base
    include ActiveSupport::Inflector

    def fetch_schema_resource
      require Rails.root.join('test','montage_resources',(params[:schema].singularize+'_resource.rb')).to_s
      "#{params[:schema].singularize.classify}Resource".constantize.new
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
      # puts 'request full path for method ' + request.request_method + ' is: ' + request.fullpath
    end

    get '/api/v1/schemas/:schema' do
      fetch_schema_resource.class.schema_definition.to_json
    end

    post '/api/v1/schemas/:schema/query' do
      data = fetch_schema_resource.query(post_payload)
      return { data: data, cursors:{next:nil, previous:nil}}.to_json
    end

    get '/api/v1/schemas/:schema/:uuid' do
      fetch_schema_resource.find(params[:uuid]).to_json
    end

    post '/api/v1/schemas/:schema/save' do
      { data: post_payload }.to_json
    end

#    get '/' do
#      value = 'This is the rooooot!'
#      value
#    end
#
#    get '/api/v1/files' do
#      {data:{}}.to_json
#    end
  end
end

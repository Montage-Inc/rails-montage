require 'sinatra/base'

module MontageRails
  class MockServer < Sinatra::Base
    include ActiveSupport::Inflector

    before do
      content_type :json
      if request.request_method == "POST" && request.body.length > 0
        request.body.rewind if request.body
        @request_payload = JSON.parse request.body.read
      end
    end

    get '/api/v1/schemas/:schema' do
      require Rails.root.join('test','montage_resources',(params[:schema].singularize+'_resource.rb')).to_s
      klass = "#{params[:schema].singularize.classify}Resource".constantize
      klass.schema_definition.to_json
    end

    def get_query(schema)
      require Rails.root.join('test','montage_resources',(schema.singularize+'_resource.rb')).to_s
      klass = "#{schema.singularize.classify}Resource".constantize
      data = klass.read_yaml
      @request_payload['filter'].each do |key, value|
        if key =~ /__gt/
          new_key = key.chomp('__gt')
          data = data.select {|x| x.has_key?(new_key) && x[new_key] > value }
        else
          data = data.select {|x| x.has_key?(key) && x[key] == value }
        end
      end
      { data: data, cursors:{next:nil, previous:nil}}.to_json
    end

    get '/api/v1/schemas/:schema/query' do
      get_query(params[:schema])
    end

    post '/api/v1/schemas/:schema/query' do
      get_query(params[:schema])
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

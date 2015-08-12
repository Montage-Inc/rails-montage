require 'sinatra/base'

module MontageRails
  class MockServer < Sinatra::Base
    include ActiveSupport::Inflector

    def load_schema(schema)
      require Rails.root.join('test','montage_resources',(schema.singularize+'_resource.rb')).to_s
      klass = "#{schema.singularize.classify}Resource".constantize
    end

    before do
      content_type :json
      puts 'request full path for method ' + request.request_method + ' is: ' + request.fullpath
      if request.request_method == "POST" && request.body.length > 0
        request.body.rewind if request.body
        @request_payload = JSON.parse request.body.read
      end
    end

    get '/api/v1/schemas/:schema' do
      klass = load_schema(params[:schema])
      klass.schema_definition.to_json
    end

    post '/api/v1/schemas/:schema/query' do
      data = load_schema(params[:schema]).read_yaml
      #note: only handles POST queries properly
      puts "Params: " + (@request_payload.to_json)
      filters = @request_payload['filter'].select { |key, value| !value.nil? && !value.empty?}
      filters.each do |key, value|
        if key =~ /__gt/
          new_key = key.chomp('__gt')
          data = data.select {|x| x.has_key?(new_key) && x[new_key] > value }
        elsif key =~ /__lt/
          new_key = key.chomp('__lt')
          data = data.select {|x| x.has_key?(new_key) && x[new_key] < value }
        else
          data = data.select {|x| x.has_key?(key) && x[key] == value }
        end
      end
      { data: data, cursors:{next:nil, previous:nil}}.to_json
    end

    post '/api/v1/schemas/:schema/save' do
      # puts 'save route called'
      # puts @request_payload.to_json
      data = @request_payload
      if data.is_a? Array
      else
      end
      { data: @request_payload }.to_json
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

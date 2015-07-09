require 'sinatra/base'
require 'json'

# Load resource helpers
Dir[File.join(Rails.root, 'test/resources', '**', '*.rb')].each do |file|
  require file
end

module MontageRails
  class Mock < Sinatra::Base
    before do
      content_type :json
    end

    get "/api/v1/schemas/:schema" do
      klass = "#{params[:schema].classify}Resource".constantize
      klass.schema_definition.to_json
    end
  end
end

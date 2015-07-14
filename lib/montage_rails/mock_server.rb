require 'sinatra/base'

class MockServer < Sinatra::Base
  
  get '/root' do
    "Successful test!"
  end

end
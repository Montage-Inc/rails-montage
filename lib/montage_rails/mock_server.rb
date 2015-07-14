require 'sinatra/base'

class MockServer < Sinatra::Base
  
  get '/' do
    "Successful test!"
  end

end
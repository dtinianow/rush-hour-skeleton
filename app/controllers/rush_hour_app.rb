require './app/models/data_processor'

class RushHourApp < Sinatra::Base
  include DataProcessor

  get '/sources' do
    status 200
    body "Ok"
  end

  post '/sources' do
    data = clean_client_data(params)
    client = Client.new(data)
    #rootUrl vs root_url
    if Client.find_by(identifier: params[:identifier])
      #identifier already exists
      status 403
    elsif client.save
      #also need to check that identifier does not already exist
      status 200
      body "{'identifier':'#{params[:identifier]}'}"
    else
      #missing parameters
      status 400
    end
  end

  error 403 do
    "Identifier Already Exists"
  end

  error 400 do
    "Missing Parameters"
  end

end

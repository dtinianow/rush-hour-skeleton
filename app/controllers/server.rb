require './app/models/data_processor'

module RushHour
  class Server < Sinatra::Base
    include DataProcessor

    not_found do
      erb :error
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
end

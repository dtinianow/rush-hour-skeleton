require './app/models/data_processor'
require 'pry'

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

    post '/sources/:identifier/data' do |identifier|
      client = Client.find_by(identifier: identifier)
      payload_data = assign_data(parse_it(params[:payload]))
      if client.nil?
        status 403
      elsif PayloadRequest.find_by(process_foreign_tables(params[:payload]))
        status 403
      elsif payload_data.nil?
        status 400
      else
        payload = process_payload(params[:payload])
        PayloadRequest.find(payload.id).update_attribute(:client_id, client.id)
        status 200
        body 'Ok'
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

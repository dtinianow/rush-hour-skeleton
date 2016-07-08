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
      if Client.find_by(identifier: params[:identifier])
        status 403
      elsif client.save
        status 200
        body "{'identifier':'#{params[:identifier]}'}"
      else
        status 400
      end
    end

    post '/sources/:identifier/data' do |identifier|
      client = Client.find_by(identifier: identifier)
      payload_data = params[:payload]
      binding.pry
      if client.nil?
        status 403
      elsif payload_data.nil?
        status 400
      elsif PayloadRequest.find_by(foreign_table_ids(payload_data))
        status 403
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

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
      id = params[:identifier]
      process_client(client, id)
    end

    post '/sources/:identifier/data' do |identifier|
      client = Client.find_by(identifier: identifier)
      payload_data = params[:payload]
      process_client_payload(client, identifier, payload_data)
    end

    def status_code_and_message(code, message)
      status code
      body message
    end

    def process_client(client, id)
      if Client.find_by(identifier: id)
        status_code_and_message(403, "Identifier '#{id}' already exists")
      elsif client.save
        status_code_and_message(200, "{'identifier':'#{id}'}")
      else
        status_code_and_message(400, "#{client.errors.full_messages.join(', ')}")
      end
    end

    def process_client_payload(client, identifier, payload_data)
      if client.nil?
        status_code_and_message(403, "Client with identifier '#{identifier}' is not yet registered.")
      elsif payload_data.nil?
        status_code_and_message(400, "Payload missing - a payload is required")
      elsif PayloadRequest.find_by(foreign_table_ids(payload_data))
        status_code_and_message(403, "Record with the supplied payload already exists")
      else
        payload = process_payload(params[:payload])
        PayloadRequest.find(payload.id).update_attribute(:client_id, client.id)
        status_code_and_message(200, "Payload entered into database")
      end
    end

  end
end

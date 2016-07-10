require './app/models/data_processor'

class Response
  include DataProcessor

  def self.process_client(client, id)
    if Client.find_by(identifier: id)
      [403, "Identifier '#{id}' already exists"]
    elsif client.save
      [200, "{'identifier':'#{id}'}"]
    else
      [400, "#{client.errors.full_messages.join(', ')}"]
    end
  end

  def self.process_client_payload(client, identifier, payload_data)
    if client.nil?
      [403, "Client with identifier '#{identifier}' is not yet registered."]
    elsif payload_data.nil?
      [400, "Payload missing - a payload is required"]
    elsif PayloadRequest.find_by(foreign_table_ids(payload_data))
      [403, "Record with the supplied payload already exists"]
    else
      payload = process_payload(params[:payload])
      PayloadRequest.find(payload.id).update_attribute(:client_id, client.id)
      [200, "Payload entered into database"]
    end
  end
end

require './app/models/data_processor'

module Response
  extend DataProcessor

  def process_client(client, id)
    if Client.find_by(identifier: id)
      {status: 403, body: "Identifier '#{id}' already exists"}
    elsif client.save
      {status: 200, body: "{'identifier':'#{id}'}"}
    else
      {status: 400, body: "#{client.errors.full_messages.join(', ')}"}
    end
  end

  def process_client_payload(client, identifier, payload_data)
    if client.nil?
      {status: 403, body: "Client with identifier '#{identifier}' is not yet registered."}
    elsif payload_data.nil?
      {status: 400, body: "Payload missing - a payload is required"}
    elsif PayloadRequest.find_by(foreign_table_ids(payload_data))
      {status: 403, body: "Record with the supplied payload already exists"}
    else
      payload = process_payload(payload_data)
      PayloadRequest.find(payload.id).update_attribute(:client_id, client.id)
      {status: 200, body: "Payload entered into database"}
    end
  end

  def set_identifier_view(client, payload, identifier)
    @identifier = identifier
    if client.nil?
      @message = "#{identifier} does not exist"
      erb :error
    elsif payload.empty?
      @message = "No payload registered for #{identifier}"
      erb :error
    else
      erb :'identifier/index', locals: {payload: payload}
    end
  end

  def set_relative_path_view(client, client_paths, identifier, relative_path)
    @identifier = identifier
    if client_paths.none? { |path| "/#{relative_path}" == path }
      @message = "The path '#{relative_path}' for '#{identifier}' has not been requested."
      erb :error
    else
      url_id = client.urls.find_by(path: "/#{relative_path}").id
      @id_and_path = "#{client.root_url}/#{relative_path}"
      erb :'identifier/relative_path', locals: {client: client, url_id: url_id}
    end
  end

end

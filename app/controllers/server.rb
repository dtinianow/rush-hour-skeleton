require './app/models/data_processor'
require './app/models/response'

module RushHour
  class Server < Sinatra::Base
    include Response, DataProcessor

    helpers do
      def create_link(path, text)
        "<a href=#{path}>#{text}</a>"
      end
    end

    not_found do
      erb :error
    end

    post '/sources' do
      data = clean_client_data(params)
      client = Client.new(data)
      id = params[:identifier]
      response = process_client(client, id)
      status response[0]
      body response[1]
    end

    post '/sources/:identifier/data' do |identifier|
      client = Client.find_by(identifier: identifier)
      payload_data = params[:payload]
      response = process_client_payload(client, identifier, payload_data)
      status response[0]
      body response[1]
    end

    get "/sources/:identifier" do |identifier|
      @identifier = identifier
      client = Client.find_by(identifier: identifier)
      payload = PayloadRequest.where(client_id: client.id) unless client.nil?
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

    get '/sources/:identifier/urls/:relative_path' do |identifier, relative_path|
      @identifier = identifier
      client = Client.find_by(identifier: identifier)
      paths = client.urls.pluck(:path).uniq
      if paths.none? { |path| "/#{relative_path}" == path }
        @message = "The path '#{relative_path}' for '#{identifier}' has not been requested."
        erb :error
      else
        url_id = client.urls.find_by(path: "/#{relative_path}").id
        @id_and_path = "#{client.root_url}/#{relative_path}"
        erb :'identifier/relative_path', locals: {client: client, url_id: url_id}
      end
    end
  end
end

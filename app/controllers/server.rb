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
      response = process_client(Client.new(data), params[:identifier])
      status response[:status]
      body response[:body]
    end

    post '/sources/:identifier/data' do |identifier|
      client = Client.find_by(identifier: identifier)
      response = process_client_payload(client, identifier, params[:payload])
      status response[:status]
      body response[:body]
    end

    get "/sources/:identifier" do |identifier|
      client = Client.find_by(identifier: identifier)
      payload = PayloadRequest.where(client_id: client.id) unless client.nil?
      set_identifier_view(client, payload, identifier)
    end

    get '/sources/:identifier/urls/:relative_path' do |identifier, relative_path|
      client = Client.find_by(identifier: identifier)
      client_paths = client.urls.pluck(:path).uniq
      set_relative_path_view(client, client_paths, identifier, relative_path)
    end
  end
end

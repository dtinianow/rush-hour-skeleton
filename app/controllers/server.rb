require './app/models/data_processor'

module RushHour
  class Server < Sinatra::Base
    include DataProcessor

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
      process_client(client, id)
    end

    post '/sources/:identifier/data' do |identifier|
      client = Client.find_by(identifier: identifier)
      payload_data = params[:payload]
      process_client_payload(client, identifier, payload_data)
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
        @average = client.payload_requests.average(:responded_in)
        @max = client.payload_requests.maximum(:responded_in)
        @min = client.payload_requests.minimum(:responded_in)
        @most_frequent = payload.most_frequent_request_type
        @verbs = payload.all_request_types
        @requested_urls = payload.most_to_least
        @user_agent_browsers = payload.browsers
        @user_agent_op_systems = payload.operating_systems
        @resolutions = payload.all_resolutions
        @paths = payload.all_client_paths
        erb :'identifier/index'
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
        @max_url_response_time = client.urls.find(url_id).payload_requests.maximum(:responded_in)
        @min_url_response_time = client.urls.find(url_id).payload_requests.minimum(:responded_in)
        @avg_url_response_time = client.urls.find(url_id).payload_requests.average(:responded_in)
        @all_url_response_times = client.urls.response_times(url_id)
        @url_verbs = client.urls.verbs_used(url_id)
        @url_top_three_refers = client.urls.top_referrers(url_id)[0..2]
        @url_top_three_agents = client.urls.top_user_agents(url_id)[0..2]
        # require "pry" ; binding.pry
        erb :'identifier/relative_path'
      end
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

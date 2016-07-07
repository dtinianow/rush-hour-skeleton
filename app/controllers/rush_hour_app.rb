class RushHourApp < Sinatra::Base

  post '/sources' do
    client = Client.new(params)
    #rootUrl vs root_url
    if client.save
      #also need to check that identifier does not already exist
      status 200
      body "{'identifier':'#{params[:identifier]}'}"
    elsif
      #identifier already exists
      status 403
    elsif
      #missing parameters
      status 400
    end
  end

end

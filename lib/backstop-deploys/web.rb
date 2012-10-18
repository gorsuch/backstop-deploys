module Backstop
  module Deploys
    class Web < Sinatra::Base
      helpers do
        def api_user
          CGI.escape(Config.librato_email)
        end

        def api_pass
          Config.librato_key
        end

        def api_endpoint
          "https://#{api_user}:#{api_pass}@metrics-api.librato.com/v1"
        end

        def parse_id(id)
          id.split('.')    
        end
      end

      put '/deploys/:id' do |id|
        app, version, start_time = parse_id(id)
        halt [400, {:message => ':id should be in the format of app.version.epoch'}.to_json] if app.nil? or version.nil? or start_time.nil?
        end_time = params[:end_time]
        halt [400, {:message => ':source is a required param'}.to_json] unless source = params[:source]
        stream_exists = true
        data = nil

        begin
          json = RestClient.get "#{api_endpoint}/annotations/deploys?sources[]=#{source}&start_time=#{start_time}"
          data = JSON.parse(json)
        rescue RestClient::ResourceNotFound
          stream_exists = false
        end

        if stream_exists and events = data['events'][source]
          # events already exists, we just need to update
          event = events.first
          event_id = event['id']
          payload = { :title => "#{source}.#{app}.#{version}" }
          payload[:end_time] = params[:end_time] if params[:end_time]
          RestClient.put "#{api_endpoint}/annotations/deploys/#{event_id}", payload
        else
          # new event needs to be created
          payload = { :start_time => start_time, :title => "#{source}.#{app}.#{version}", :source => source }
          payload[:end_time] = end_time if end_time
          q = payload.map { |k,v| "#{k}=#{v}" }.sort.join("&")
          RestClient.post "#{api_endpoint}/annotations/deploys", q
        end
      end
    end
  end
end

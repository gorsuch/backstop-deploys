module Backstop
  module Deploys
    class Web < Sinatra::Base
      post '/deploys' do
        halt(400, { :message => "app and version are required params" }.to_json) unless params.has_key?('app') and params.has_key?('version')
        id = SecureRandom.hex
        title = "#{params[:app]}.#{params[:version]}.#{id}"

        RestClient.post("https://#{CGI.escape(Config.librato_email)}:#{Config.librato_key}@metrics-api.librato.com/v1/annotations/deploys", 'title' => title)
        { :id => id }.to_json
      end

      put '/deploys/:id' do |id|
        { :message => 'ok' }.to_json
      end
    end
  end
end

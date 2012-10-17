module Backstop
  module Deploys
    class Web < Sinatra::Base
      post '/deploys' do
        id = SecureRandom.hex
        title = "#{params[:app]}.#{params[:version]}.#{id}"

        RestClient.post("https://#{CGI.escape(Config.librato_email)}:#{Config.librato_key}@metrics-api.librato.com/v1/annotations/deploys", 'title' => title)
        { :id => id }.to_json
      end
    end
  end
end

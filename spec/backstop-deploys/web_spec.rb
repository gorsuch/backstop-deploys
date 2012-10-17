require 'spec_helper'
require 'rack/test'

describe Backstop::Deploys::Web do
  include Rack::Test::Methods

  def app
    Backstop::Deploys::Web
  end

  describe 'POST /deploys' do
    let(:librato_email) { "foo@foo.com" }
    let(:librato_key) { '12345' }
    let(:random_key) { 'abcd' }
    let(:params) { {:app => 'foo', :version => 'v75'} }
    let(:mock_request) { stub_request(:post, "https://#{CGI.escape(librato_email)}:#{librato_key}@metrics-api.librato.com/v1/annotations/deploys").with(:body => {'title' => "#{params[:app]}.#{params[:version]}.#{random_key}"}) }

    before(:each) do
      SecureRandom.stub(:hex) { random_key }
      Backstop::Deploys::Config.stub(:librato_email) { librato_email }
      Backstop::Deploys::Config.stub(:librato_key) { librato_key }
      mock_request 
    end

    context 'with proper params' do
      before(:each) { post '/deploys', params }
      it('should return a 200') { last_response.status.should eq(200) }
      it('should return an id') { JSON.parse(last_response.body).has_key?('id') }
      it('should call the Librato API properly') do
        mock_request.should have_been_made.once
      end
     end

    context 'missing app' do
      before(:each) { post '/deploys', { :version => 'v75' } }
      it('should return a 400') { last_response.status.should eq(400) }
      it('should state the error') { JSON.parse(last_response.body).has_key?('message') }
    end

    context 'missing version' do
      before(:each) { post '/deploys', { :app => 'foo' } }
      it('should return a 400') { last_response.status.should eq(400) }
      it('should state the error') { JSON.parse(last_response.body).has_key?('message') }
    end
  end

  describe 'PUT /deploys/:id' do
    it 'returns a 200'
    it 'returns ok'
    it 'should call RestClient properly'
  end
end

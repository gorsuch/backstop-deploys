require 'spec_helper'
require 'rack/test'

describe Backstop::Deploys::Web do
  include Rack::Test::Methods

  def app
    Backstop::Deploys::Web
  end

  let(:librato_email) { 'foo@foo.com' }
  let(:librato_key) { '12345' }
  let(:api_endpoint) { "https://#{CGI.escape(librato_email)}:#{librato_key}@metrics-api.librato.com/v1" }
  let(:app_name) { 'foo' }
  let(:version) { 'v75' }
  let(:t) { Time.now }
  let(:id) { "#{app_name}.#{version}.#{t.to_i}" }
  let(:title) { "#{app_name}.#{version}" }
  let(:source) { 'test' }
  let(:params) { {:source => source} }

  before(:each) do
    Backstop::Deploys::Config.stub(:librato_email) { librato_email }
    Backstop::Deploys::Config.stub(:librato_key) { librato_key }
  end

  describe 'PUT /deploys/:id' do
    context 'with proper id' do
      context 'with source' do

        context 'existing annotation' do
          let(:event_id) { 12345 }
          let(:stub_events) { [{:title => title, :source => source, :start_time => t.to_i, :id => event_id}] }
          let(:stub_get_existing_body) { {:name => 'deploys', :events => {source => stub_events}} } 
          let(:stub_get_existing_request) { stub_request(:get, "#{api_endpoint}/annotations/deploys").with(:query => { :sources => [source], :start_time => t.to_i }).to_return(:body => stub_get_existing_body.to_json)}
          let(:stub_update_request) { stub_request(:put, "#{api_endpoint}/annotations/deploys/#{event_id}").with(:body => {:title => title}) }
          before(:each) do
            stub_get_existing_request
            stub_update_request
            put "/deploys/#{id}", params
          end
          it('should ask Librato for the proper annotation') { stub_get_existing_request.should have_been_made.once }
          it('should update the existing annotation') { stub_update_request.should have_been_made.once }
          it('should return a 200') { last_response.status.should eq(200) }
        end

        context 'non-existent annotation stream' do
          let(:stub_missing_stream) { stub_request(:get, "#{api_endpoint}/annotations/deploys").with(:query => { :sources => [source], :start_time => t.to_i }).to_return(:status => 404) }
          let(:stub_new_request) { stub_request(:post, "#{api_endpoint}/annotations/deploys").with(:body => "source=#{source}&start_time=#{t.to_i}&title=#{title}") }
          before(:each) do
            stub_missing_stream
            stub_new_request
            put "/deploys/#{id}", params
          end
          it('should ask Librato for the proper annotation') { stub_missing_stream.should have_been_made.once }
          it('should create a new annotation') { stub_new_request.should have_been_made.once }
          it('should be 200') { last_response.status.should eq(200) }
        end

        context 'non-existent annotation' do
          let(:stub_get_missing_body) { {:name => 'deploys', :events => {}} } 
          let(:stub_get_missing_request) { stub_request(:get, "#{api_endpoint}/annotations/deploys").with(:query => { :sources => [source], :start_time => t.to_i }).to_return(:body => stub_get_missing_body.to_json)}
          let(:stub_new_request) { stub_request(:post, "#{api_endpoint}/annotations/deploys").with(:body => "source=#{source}&start_time=#{t.to_i}&title=#{title}") }
          before(:each) do
            stub_get_missing_request
            stub_new_request
            put "/deploys/#{id}", params
          end
          it('should ask Librato for the proper annotation') { stub_get_missing_request.should have_been_made.once }
          it('should create a new annotation') { stub_new_request.should have_been_made.once }
          it('should be 200') { last_response.status.should eq(200) }
        end
      end

      context 'without source' do
        before(:each) { put "/deploys/#{id}", { :foo => :bar } }
        it('should return a 400') { last_response.status.should eq(400) }
        it('should return a proper error message') { JSON.parse(last_response.body).has_key?('message') }
      end
    end

    context 'with improperly formatted id' do
      before(:each) { put "/deploys/foo.bar", params }
      it('should return a 400') { last_response.status.should eq(400) }
      it('should return a proper error message') { JSON.parse(last_response.body).has_key?('message') }
    end
  end
end

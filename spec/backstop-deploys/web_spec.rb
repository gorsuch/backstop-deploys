require 'spec_helper'
require 'rack/test'

describe Backstop::Deploys::Web do
  include Rack::Test::Methods

  def app
    Backstop::Deploys::Web
  end

  let(:librato_email) { "foo@foo.com" }
  let(:librato_key) { '12345' }
  let(:app) { 'foo' }
  let(:version) { 'v75' }
  let(:t) { Time.now }
  let(:id) { "#{app}.#{version}.#{t.to_i}" }
  let(:params) { {:source => 'test'} }

  before(:each) do
    Backstop::Deploys::Config.stub(:librato_email) { librato_email }
    Backstop::Deploys::Config.stub(:librato_key) { librato_key }
  end

  describe 'PUT /deploys/:id' do
    context 'with proper id' do
      context 'with source' do
        it 'should ask Librato for the proper annotation'

        context 'non-existent annotation' do
          it 'should create a new annotation'
        end

        context 'existing annotation' do
          it 'should update the existing annotation'
        end
      end

      context 'without source' do
        it 'should return a 400'
        it 'should return a proper error message'
      end
    end

    context 'with improperly formatted id' do
      it 'should return a 400'
      it 'should return a proper error message'
    end
  end
end

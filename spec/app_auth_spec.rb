# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Auth API endpoints' do
  before do
    DB[:users].delete
  end

  describe 'POST /signup' do
    it 'creates a user and returns 201 with a token' do
      payload = { user: { username: 'ellen', password: 's3cret' } }.to_json

      post '/signup', payload, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(201)
      json = JSON.parse(last_response.body)
      expect(json['user']['token']).to be_a(String)
    end

    it 'returns 409 when the username already exists' do
      Signup.call('frank', 'one')
      payload = { user: { username: 'frank', password: 'two' } }.to_json

      post '/signup', payload, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(409)
    end

    it 'returns 400 for blank username or password' do
      payload = { user: { username: '   ', password: '' } }.to_json

      post '/signup', payload, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(400)
    end
  end

  describe 'POST /login' do
    it 'authenticates valid credentials and returns a token' do
      Signup.call('gina', 'pw')
      payload = { user: { username: 'gina', password: 'pw' } }.to_json

      post '/login', payload, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json['user']['token']).to be_a(String)
    end

    it 'returns 401 for invalid credentials' do
      payload = { user: { username: 'harry', password: 'nope' } }.to_json

      post '/login', payload, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(401)
    end
  end
end

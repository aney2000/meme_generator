# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Meme Generator API' do
  before do
    DB[:users].delete
  end

  describe 'POST /memes' do
    let(:user) { UserStore.create_user('andrei', 'pw') }
    let(:token) { user[:token] }

    context 'when the request is authenticated and valid' do
      let(:payload) do
        {
          meme: {
            image_url: 'https://images.unsplash.com/photo-1647549831144-09d4c521c1f1',
            text: 'Mornings are best'
          }
        }.to_json
      end

      before do
        fake_remote_file = double('remote_file', read: 'fake_image_bytes')
        allow(URI).to receive(:open).and_yield(fake_remote_file)

        mock_image = double('mini_magick_image', combine_options: true, write: true)
        allow(MiniMagick::Image).to receive(:read).and_return(mock_image)
      end

      it 'returns 307 and redirects to the generated meme' do
        env = { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{token}" }
        post '/memes', payload, env

        expect(last_response.status).to eq(307)
        expect(last_response.headers['Location']).to include('/memes/andrei/')
      end
    end

    context 'when the request is missing auth' do
      it 'returns 401' do
        payload = { meme: { image_url: 'https://example.com/cat.jpg', text: 'Hello' } }.to_json

        post '/memes', payload, { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(401)
      end
    end

    context 'when required parameters are missing from the request' do
      it 'returns 400 Bad Request' do
        incomplete_payload = { meme: { text: 'No URL' } }.to_json

        env = { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{token}" }
        post '/memes', incomplete_payload, env

        expect(last_response.status).to eq(400)

        json_response = JSON.parse(last_response.body)
        expect(json_response['error']).to include('Missing required parameters')
      end
    end

    context 'when the image is larger than the allowed size' do
      let(:payload) do
        {
          meme: {
            image_url: 'https://example.com/large-image.jpg',
            text: 'Too big'
          }
        }.to_json
      end

      before do
        allow(URI).to receive(:open).and_yield(double('remote_file',
                                                      read: 'a' * (MemeGenerator::MAX_IMAGE_SIZE_BYTES + 1)))
      end

      it 'returns 413 and an error message' do
        env = { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{token}" }
        post '/memes', payload, env

        expect(last_response.status).to eq(413)
        expect(JSON.parse(last_response.body)['error']).to eq('Image is too large')
      end
    end
  end
end

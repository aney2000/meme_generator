require 'spec_helper'

RSpec.describe 'Meme Generator API' do
  describe 'POST /memes' do
    context 'when the parameters are valid' do
      let(:payload) do
        {
          meme: {
            image_url: "https://images.unsplash.com/photo-1647549831144-09d4c521c1f1",
            text: "Mornings are best"
          }
        }.to_json
      end

      it 'return 303 and redirect to the meme folder' do
        post '/memes', payload, { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(303)
        
        expect(last_response.headers['Location']).to include('/memes/')
      end
    end

    context 'when required parameters are missing from the request' do
      it 'returns status 400 Bad Request' do
        incomplete_payload = { meme: { text: "No URL" } }.to_json

        post '/memes', incomplete_payload, { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(400)
        
        json_response = JSON.parse(last_response.body)
        expect(json_response['error']).to include('Missing required parameters')
      end
    end
  end
end
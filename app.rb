require 'sinatra'
require 'json'
require_relative 'services/meme_generator'

set :public_folder, __dir__ + '/public'

post '/memes' do
  content_type :json

  body_content = request.body.read
  request_body = JSON.parse(body_content) rescue nil

  meme_params = request_body ? request_body['meme'] : nil

  if meme_params.nil? || meme_params['image_url'].nil? || meme_params['text'].nil?
    halt 400, { error: "Missing required parameters: meme[image_url] and meme[text]" }.to_json
  end

  image_url = meme_params['image_url']
  text = meme_params['text']

  filename = MemeGenerator.call(image_url, text)

  if filename
    meme_url = "#{request.base_url}/memes/#{filename}"

    redirect meme_url, 303
  else
    halt 422, { error: "Failed to process the image from the provided URL" }.to_json
  end
end
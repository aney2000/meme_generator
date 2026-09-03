# frozen_string_literal: true

require 'json'
require 'sinatra'
require 'uri'
require_relative 'services/meme_generator'
require_relative 'services/signup'
require_relative 'services/login'
require_relative 'services/user_store'

enable :sessions
set :session_secret, ENV.fetch('SESSION_SECRET', '0' * 64)
set :public_folder, "#{__dir__}/public"

helpers do
  def parsed_json_body
    body_content = request.body.read
    JSON.parse(body_content)
  rescue StandardError
    nil
  end

  def authorization_token
    header_value = request.get_header('HTTP_AUTHORIZATION').to_s
    match = header_value.match(/\ABearer\s+(.+)\z/i)
    match ? match[1].strip : nil
  end

  def authenticated_user
    token = authorization_token
    return nil if token.nil? || token.empty?

    UserStore.find_user_by_token(token)
  end
end

post '/memes' do
  content_type :json

  user = authenticated_user
  halt 401, { error: 'User is not logged in' }.to_json unless user

  request_body = parsed_json_body
  meme_params = request_body ? request_body['meme'] : nil

  unless meme_params && meme_params['image_url'].to_s.strip != '' && meme_params['text'].to_s.strip != ''
    halt 400, { error: 'Missing required parameters: meme[image_url] and meme[text]' }.to_json
  end

  image_url = meme_params['image_url'].to_s.strip
  text = meme_params['text'].to_s.strip

  unless image_url.match?(URI::DEFAULT_PARSER.make_regexp(%w[http https]))
    halt 400, { error: 'image_url must be a valid http or https URL' }.to_json
  end

  begin
    filename = MemeGenerator.call(image_url, text, username: user[:username])
  rescue ArgumentError => e
    halt 413, { error: e.message }.to_json
  end

  if filename
    meme_url = "#{request.base_url}/memes/#{user[:username]}/#{filename}"
    redirect meme_url, 307
  else
    halt 422, { error: 'Failed to process the image from the provided URL' }.to_json
  end
end

post '/signup' do
  content_type :json

  request_body = parsed_json_body
  user_params = request_body ? request_body['user'] : nil

  username = user_params ? user_params['username'].to_s.strip : ''
  password = user_params ? user_params['password'].to_s : ''

  result = Signup.call(username, password)

  if result[:success]
    status 201
    { user: { token: result[:token] } }.to_json
  else
    if result[:errors].include?('User already exists')
      halt 409, { errors: [{ message: 'User already exists' }] }.to_json
    end

    errors = result[:errors].map { |message| { message: message } }
    halt 400, { errors: errors }.to_json
  end
end

post '/login' do
  content_type :json

  request_body = parsed_json_body
  user_params = request_body ? request_body['user'] : nil

  username = user_params ? user_params['username'].to_s.strip : ''
  password = user_params ? user_params['password'].to_s : ''

  result = Login.call(username, password)

  if result[:success]
    { user: { token: result[:token] } }.to_json
  else
    errors = result[:errors].map { |message| { message: message } }
    halt 401, { errors: errors }.to_json
  end
end

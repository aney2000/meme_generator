# frozen_string_literal: true

require 'bcrypt'
require 'securerandom'
require_relative 'db'

class UserStore
  class << self
    def create_user(username, password)
      username_value = username.to_s.strip
      password_value = password.to_s

      return invalid_result('Username is blank') if username_value.empty?
      return invalid_result('Password is blank') if password_value.strip.empty?
      return invalid_result('User already exists') if find_user_by_username(username_value)

      password_hash = BCrypt::Password.create(password_value)
      token = SecureRandom.hex(16)

      DB[:users].insert(username: username_value, password_hash: password_hash, token: token)
      { success: true, user: find_user_by_username(username_value), token: token }
    rescue Sequel::UniqueConstraintViolation, Sequel::DatabaseError
      { success: false, errors: ['User already exists'] }
    end

    def authenticate_user(username, password)
      username_value = username.to_s.strip
      password_value = password.to_s

      return nil if username_value.empty? || password_value.strip.empty?

      row = DB[:users].where(username: username_value).first
      return nil unless row
      return row if BCrypt::Password.new(row[:password_hash]) == password_value

      nil
    rescue StandardError
      nil
    end

    def find_user_by_username(username)
      return nil if username.nil? || username.to_s.strip.empty?

      DB[:users].where(username: username.to_s.strip).first
    end

    def find_user_by_id(id)
      return nil if id.nil?

      DB[:users].where(id: id).first
    end

    def find_user_by_token(token)
      return nil if token.nil? || token.to_s.strip.empty?

      DB[:users].where(token: token.to_s.strip).first
    end

    private

    def invalid_result(message)
      { success: false, errors: [message] }
    end
  end
end

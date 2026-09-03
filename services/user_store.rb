# frozen_string_literal: true

require 'bcrypt'
require 'securerandom'
require_relative 'db'

class UserStore
  class << self
    def create_user(username, password)
      password_hash = BCrypt::Password.create(password)
      token = SecureRandom.hex(16)

      DB[:users].insert(username: username, password_hash: password_hash, token: token)
      { success: true, user: find_user_by_username(username), token: token }
    rescue Sequel::UniqueConstraintViolation, Sequel::DatabaseError
      { success: false, errors: ['User already exists'] }
    end

    def authenticate_user(username)
      username_value = username.to_s.strip
      return nil if username_value.empty?

      DB[:users].where(username: username_value).first
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
  end
end

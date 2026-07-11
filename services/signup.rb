# frozen_string_literal: true

require_relative 'user_store'

class Signup
  class << self
    def call(username, password)
      username_value = username.to_s.strip
      password_value = password.to_s

      return invalid_result('Username is blank') if username_value.empty?
      return invalid_result('Password is blank') if password_value.strip.empty?
      return invalid_result('User already exists') if UserStore.find_user_by_username(username_value)

      UserStore.create_user(username_value, password_value)
    end

    private

    def invalid_result(message)
      { success: false, errors: [message] }
    end
  end
end

# frozen_string_literal: true

require_relative 'user_store'

class Login
  def self.call(username, password)
    username_value = username.to_s.strip
    password_value = password.to_s

    return invalid_result('Username is blank') if username_value.empty?
    return invalid_result('Password is blank') if password_value.strip.empty?

    user = UserStore.authenticate_user(username_value, password_value)
    return invalid_result('Invalid username or password') unless user

    { success: true, user: user, token: user[:token] }
  end

  def self.invalid_result(message)
    { success: false, errors: [message] }
  end
end

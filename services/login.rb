# frozen_string_literal: true

require_relative 'user_store'
require_relative 'valid_user'

class Login
  class << self
    def call(username, password)
      result = ValidUser.call(username, password)
      return result unless result[:success]

      user = UserStore.authenticate_user(username)
      return invalid_result('Invalid username or password') unless user
      return invalid_result('Invalid username or password') unless BCrypt::Password.new(user[:password_hash]) == password

      { success: true, user: user, token: user[:token] }
    end

    private

    def invalid_result(message)
      { success: false, errors: [message] }
    end
  end
end

# frozen_string_literal: true

require_relative 'user_store'
require_relative 'valid_user'

class Signup
  class << self
    def call(username, password)
      result = ValidUser.call(username, password)
      return result unless result[:success]

      return invalid_result('User already exists') if UserStore.find_user_by_username(username)

      UserStore.create_user(username, password)
    end

    private

    def invalid_result(message)
      { success: false, errors: [message] }
    end
  end
end

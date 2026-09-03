# frozen_string_literal: true

class ValidUser
  class << self
    def call(username, password)
      username_value = username.to_s.strip
      password_value = password.to_s

      return invalid_result('Username is blank') if username_value.empty?
      return invalid_result('Password is blank') if password_value.strip.empty?

      { success: true }
    end

    private

    def invalid_result(message)
      { success: false, errors: [message] }
    end
  end
end

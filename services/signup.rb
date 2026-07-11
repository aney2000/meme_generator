# frozen_string_literal: true

require_relative 'user_store'

class Signup
  def self.call(username, password)
    UserStore.create_user(username, password)
  end
end

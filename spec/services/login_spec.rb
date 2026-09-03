# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Login do
  before(:each) do
    DB[:users].delete
  end

  describe '.call' do
    it 'returns a successful result with a token for valid credentials' do
      Signup.call('carol', 'pa55word')
      result = Login.call('carol', 'pa55word')

      expect(result[:success]).to be true
      expect(result[:token]).to be_a(String)
    end

    it 'returns an error result for invalid credentials' do
      Signup.call('dave', 'mypassword')
      result = Login.call('dave', 'wrongpass')

      expect(result[:success]).to be false
      expect(result[:errors]).to include('Invalid username or password')
    end

    it 'returns an error for blank input' do
      result = Login.call('   ', '   ')

      expect(result[:success]).to be false
      expect(result[:errors]).to include('Username is blank')
    end
  end
end

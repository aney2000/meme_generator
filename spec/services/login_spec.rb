# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Login do
  before do
    DB[:users].delete
  end

  describe '.call' do
    it 'returns a successful result with a token for valid credentials' do
      Signup.call('carol', 'pa55word')
      result = described_class.call('carol', 'pa55word')

      expect(result[:success]).to be true
      expect(result[:token]).to be_a(String)
    end

    it 'returns an error result for invalid credentials' do
      Signup.call('dave', 'mypassword')
      result = described_class.call('dave', 'wrongpass')

      expect(result[:success]).to be false
      expect(result[:errors]).to include('Invalid username or password')
    end

    it 'returns an error for blank input' do
      result = described_class.call('   ', '   ')

      expect(result[:success]).to be false
      expect(result[:errors]).to include('Username is blank')
    end
  end
end

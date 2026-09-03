# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Signup do
  before do
    DB[:users].delete
  end

  describe '.call' do
    it 'creates a new user and returns a success result' do
      result = described_class.call('bob', 'password123')

      expect(result[:success]).to be true
      expect(result[:token]).to be_a(String)

      row = DB[:users].where(username: 'bob').first
      expect(row).not_to be_nil
      expect(row[:username]).to eq('bob')
    end

    it 'returns an error result when the username already exists' do
      described_class.call('bob', 'password123')
      result = described_class.call('bob', 'otherpass')

      expect(result[:success]).to be false
      expect(result[:errors]).to include('User already exists')
    end

    it 'returns an error result for blank input' do
      result = described_class.call('   ', '')

      expect(result[:success]).to be false
      expect(result[:errors]).to include('Username is blank')
    end
  end
end

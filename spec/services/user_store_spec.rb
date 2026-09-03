# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UserStore do
  before do
    DB[:users].delete
  end

  describe '.create_user' do
    it 'persists the user with a hashed password and a token' do
      result = described_class.create_user('mr_bean', 'test123')

      expect(result[:success]).to be true
      expect(result[:token]).to match(/\A[0-9a-f]{32}\z/)

      row = DB[:users].where(username: 'mr_bean').first
      expect(row[:password_hash]).not_to eq('test123')
      expect(BCrypt::Password.new(row[:password_hash])).to eq('test123')
    end

    it 'returns a failure result when the username already exists' do
      described_class.create_user('mr_bean', 'test123')

      result = described_class.create_user('mr_bean', 'other')

      expect(result).to eq(success: false, errors: ['User already exists'])
    end
  end

  describe '.authenticate_user' do
    it 'returns the stored user for a known username' do
      described_class.create_user('mr_bean', 'test123')

      expect(described_class.authenticate_user('mr_bean')[:username]).to eq('mr_bean')
    end

    it 'returns nil for a blank username' do
      expect(described_class.authenticate_user('   ')).to be_nil
    end

    it 'returns nil when the lookup raises an unexpected error' do
      allow(DB).to receive(:[]).and_raise(StandardError)

      expect(described_class.authenticate_user('mr_bean')).to be_nil
    end
  end

  describe '.find_user_by_username' do
    it 'returns the matching user' do
      described_class.create_user('mr_bean', 'test123')

      expect(described_class.find_user_by_username('mr_bean')[:username]).to eq('mr_bean')
    end

    it 'returns nil for a blank or unknown username' do
      expect(described_class.find_user_by_username('  ')).to be_nil
      expect(described_class.find_user_by_username('ghost')).to be_nil
    end
  end

  describe '.find_user_by_token' do
    it 'returns the user owning the token' do
      token = described_class.create_user('mr_bean', 'test123')[:token]

      expect(described_class.find_user_by_token(token)[:username]).to eq('mr_bean')
    end

    it 'returns nil for a blank or unknown token' do
      expect(described_class.find_user_by_token('  ')).to be_nil
      expect(described_class.find_user_by_token('deadbeef')).to be_nil
    end
  end

  describe '.find_user_by_id' do
    it 'returns the user with the given id' do
      described_class.create_user('mr_bean', 'test123')
      id = DB[:users].where(username: 'mr_bean').first[:id]

      expect(described_class.find_user_by_id(id)[:username]).to eq('mr_bean')
    end

    it 'returns nil when the id is nil' do
      expect(described_class.find_user_by_id(nil)).to be_nil
    end
  end
end

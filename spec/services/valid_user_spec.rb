# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ValidUser do
  describe '.call' do
    it 'returns a success result when username and password are present' do
      result = described_class.call('mr_bean', 'test123')

      expect(result).to eq(success: true)
    end

    it 'strips surrounding whitespace before validating the username' do
      result = described_class.call('  mr_bean  ', 'test123')

      expect(result[:success]).to be true
    end

    it 'reports a blank username' do
      result = described_class.call('   ', 'test123')

      expect(result).to eq(success: false, errors: ['Username is blank'])
    end

    it 'reports a nil username as blank' do
      result = described_class.call(nil, 'test123')

      expect(result[:errors]).to eq(['Username is blank'])
    end

    it 'reports a blank password' do
      result = described_class.call('mr_bean', '   ')

      expect(result).to eq(success: false, errors: ['Password is blank'])
    end

    it 'validates the username before the password' do
      result = described_class.call('', '')

      expect(result[:errors]).to eq(['Username is blank'])
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printer do
  describe '.error' do
    it 'prints the error message to stdout with the correct prefix' do
      expect { described_class.error('Something went wrong') }.to output("[API ERROR] Something went wrong\n").to_stdout
    end
  end

  describe '.info' do
    it 'prints the info message to stdout with the correct prefix' do
      expect { described_class.info('Application started') }.to output("[API INFO] Application started\n").to_stdout
    end
  end
end

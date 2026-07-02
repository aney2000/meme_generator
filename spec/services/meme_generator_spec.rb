# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MemeGenerator do
  let(:valid_url) { 'https://images.unsplash.com/photo-1647549831144-09d4c521c1f1' }
  let(:text) { 'Test text' }

  describe '.call' do
    context 'when the URL is valid' do
      before do
        fake_remote_file = double('remote_file', read: 'fake_image_bytes')
        allow(URI).to receive(:open).with(valid_url).and_yield(fake_remote_file)

        mock_image = double('mini_magick_image', combine_options: true, write: true)
        allow(MiniMagick::Image).to receive(:read).and_return(mock_image)
      end

      it 'returns the generated filename without hitting the internet' do
        filename = MemeGenerator.call(valid_url, text, printer: nil)

        expect(filename).to be_a(String)
        expect(filename).to end_with('.jpg')
      end
    end

    context 'when the URL is invalid' do
      before do
        allow(URI).to receive(:open).with('https://invalid-url.com').and_raise(SocketError.new('Failed to open TCP connection'))
      end

      it 'returns nil without printing to the terminal' do
        filename = MemeGenerator.call('https://invalid-url.com', text, printer: nil)
        expect(filename).to be_nil
      end
    end
  end
end

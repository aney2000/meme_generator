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
        filename = described_class.call(valid_url, text, printer: nil)

        expect(filename).to be_a(String)
        expect(filename).to end_with('.jpg')
      end
    end

    context 'when a username is provided' do
      before do
        fake_remote_file = double('remote_file', read: 'fake_image_bytes')
        allow(URI).to receive(:open).with(valid_url).and_yield(fake_remote_file)
        allow(MiniMagick::Image).to receive(:read)
          .and_return(double('image', combine_options: true, write: true))
      end

      it 'stores the meme under a per-user subdirectory' do
        allow(FileUtils).to receive(:mkdir_p)

        described_class.call(valid_url, text, username: 'mr_bean', printer: nil)

        expect(FileUtils).to have_received(:mkdir_p).with(File.join(MemeGenerator::OUTPUT_DIR, 'mr_bean'))
      end
    end

    context 'when annotating the image' do
      let(:config) { double('convert_options').as_null_object }

      before do
        fake_remote_file = double('remote_file', read: 'fake_image_bytes')
        allow(URI).to receive(:open).with(valid_url).and_yield(fake_remote_file)

        image = double('image', write: true)
        allow(image).to receive(:combine_options).and_yield(config)
        allow(MiniMagick::Image).to receive(:read).and_return(image)
      end

      it 'centers the text with the configured font and colors' do
        described_class.call(valid_url, 'Hello', printer: nil)

        expect(config).to have_received(:gravity).with('center')
        expect(config).to have_received(:font).with('Helvetica')
        expect(config).to have_received(:draw).with("text 0,100 'Hello'")
      end
    end

    context 'when the URL is invalid' do
      before do
        connection_error = SocketError.new('Failed to open TCP connection')
        allow(URI).to receive(:open).with('https://invalid-url.com').and_raise(connection_error)
      end

      it 'returns nil without printing to the terminal' do
        filename = described_class.call('https://invalid-url.com', text, printer: nil)
        expect(filename).to be_nil
      end

      it 'logs the failure through the injected printer' do
        printer = double('printer')
        allow(printer).to receive(:error)

        described_class.call('https://invalid-url.com', text, printer: printer)

        expect(printer).to have_received(:error).with('Failed to open TCP connection')
      end
    end

    context 'when the downloaded image exceeds the size limit' do
      before do
        oversized = 'a' * (MemeGenerator::MAX_IMAGE_SIZE_BYTES + 1)
        allow(URI).to receive(:open).with(valid_url).and_yield(double('remote_file', read: oversized))
      end

      it 'raises an ArgumentError and logs it' do
        printer = double('printer')
        allow(printer).to receive(:error)

        expect { described_class.call(valid_url, text, printer: printer) }
          .to raise_error(ArgumentError, 'Image is too large')
        expect(printer).to have_received(:error).with('Image is too large')
      end
    end
  end
end

# frozen_string_literal: true

require 'fileutils'
require 'open-uri'
require 'mini_magick'
require 'securerandom'
require_relative 'printer'

class MemeGenerator
  OUTPUT_DIR = File.join(__dir__, '..', 'public', 'memes')
  MAX_IMAGE_SIZE_BYTES = 10 * 1024 * 1024

  class << self
    def call(image_url, text, username: nil, printer: Printer)
      filename = "#{SecureRandom.hex(8)}.jpg"
      filepath = File.join(target_dir(username), filename)

      annotate_remote_image(image_url, text, filepath)

      filename
    rescue ArgumentError => e
      printer&.error(e.message)
      raise e
    rescue StandardError => e
      printer&.error(e.message)
      nil
    end

    private

    def target_dir(username)
      dir = username ? File.join(OUTPUT_DIR, username) : OUTPUT_DIR
      FileUtils.mkdir_p(dir)
      dir
    end

    # image_url is validated as http/https at the request boundary before reaching here.
    def annotate_remote_image(image_url, text, filepath)
      URI.open(image_url) do |remote_file| # rubocop:disable Security/Open
        bytes = remote_file.read
        raise ArgumentError, 'Image is too large' if bytes.bytesize > MAX_IMAGE_SIZE_BYTES

        write_meme(bytes, text, filepath)
      end
    end

    def write_meme(bytes, text, filepath)
      image = MiniMagick::Image.read(bytes)
      image.combine_options do |c|
        c.gravity 'center'
        c.font 'Helvetica'
        c.pointsize '40'
        c.fill 'black'
        c.undercolor 'white'
        c.draw "text 0,100 '#{text}'"
      end
      image.write(filepath)
    end
  end
end

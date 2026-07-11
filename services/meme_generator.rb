# frozen_string_literal: true

require 'open-uri'
require 'mini_magick'
require 'securerandom'
require_relative 'printer'

class MemeGenerator
  OUTPUT_DIR = File.join(__dir__, '..', 'public', 'memes')
  MAX_IMAGE_SIZE_BYTES = 10 * 1024 * 1024

  def self.call(image_url, text, username: nil, printer: Printer)
    filename = "#{SecureRandom.hex(8)}.jpg"
    dir = username ? File.join(OUTPUT_DIR, username) : OUTPUT_DIR
    Dir.mkdir(dir) unless Dir.exist?(dir)
    filepath = File.join(dir, filename)

    URI.open(image_url) do |remote_file|
      bytes = remote_file.read

      raise ArgumentError, 'Image is too large' if bytes.bytesize > MAX_IMAGE_SIZE_BYTES

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

    filename
  rescue ArgumentError => e
    printer&.error(e.message)
    raise e
  rescue StandardError => e
    printer&.error(e.message)
    nil
  end
end

# frozen_string_literal: true

require 'open-uri'
require 'mini_magick'
require 'securerandom'
require_relative 'printer'

class MemeGenerator
  OUTPUT_DIR = File.join(__dir__, '..', 'public', 'memes')

  def self.call(image_url, text, printer: Printer)
    filename = "#{SecureRandom.hex(8)}.jpg"
    filepath = File.join(OUTPUT_DIR, filename)

    URI.open(image_url) do |remote_file|
      image = MiniMagick::Image.read(remote_file.read)
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
  rescue StandardError => e
    printer&.error(e.message)
    nil
  end
end

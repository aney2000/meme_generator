# frozen_string_literal: true

class Printer
  def self.error(message)
    puts "[API ERROR] #{message}"
  end

  def self.info(message)
    puts "[API INFO] #{message}"
  end
end

# frozen_string_literal: true

module Ustats
  # Base class with debug helpers
  class Base
    DEFAULT_DEBUG = false

    attr_reader :debug

    def initialize(debug: DEFAULT_DEBUG)
      @debug = debug
    end

    private

    def log(message)
      puts "DEBUG: #{message}" if debug
    end
  end
end

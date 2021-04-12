# frozen_string_literal: true

require_relative 'base'
require_relative 'parser'
require_relative 'report'

module Ustats
  # Main class for UStats application
  class Task < Base
    DEFAULT_INPUT_FILENAME = 'data/data.txt'
    OUTPUT_FILENAME = 'data/result.json'

    attr_reader :filename, :show_progress
    attr_accessor :users, :report, :sessions

    def initialize(filename = DEFAULT_INPUT_FILENAME, show_progress: false, debug: DEFAULT_DEBUG)
      super(debug: debug)
      @filename = filename
      @show_progress = show_progress
    end

    def call
      parser = Parser.new(filename, debug: debug)
      parser.call do |users, sessions, sessions_mapping|
        report = Report.new(users, sessions, sessions_mapping, OUTPUT_FILENAME, debug: debug,
                                                                                show_progress: show_progress)
        report.call
        report.print
      end
    end
  end
end

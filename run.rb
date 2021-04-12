# frozen_string_literal: true

require_relative 'lib/ustats/task'
require_relative 'lib/profile'

DATA_FILENAME = 'data/data_large.txt'
PROGRESS = true
DEBUG = true

Profile.new.call do
  Ustats::Task.new(DATA_FILENAME, show_progress: PROGRESS, debug: DEBUG).call
  puts '---'
end

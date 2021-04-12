# frozen_string_literal: true

require 'minitest/autorun'

require_relative 'lib/ustats/task'

# Tests for UStats application
class TestMe < Minitest::Test
  def setup
    File.write('data/result.json', '')
  end

  def test_result
    Ustats::Task.new.call
    expected_result = File.read('data/expected_result.json')
    assert_equal expected_result, File.read('data/result.json')
  end
end

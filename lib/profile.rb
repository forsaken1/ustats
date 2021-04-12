# frozen_string_literal: true

require 'benchmark'

# Profilier for UStats application
class Profile
  def call(&block)
    profile_memory do
      profile_time do
        block.call
      end
    end
  end

  private

  def profile_memory
    memory_usage_before = `ps -o rss= -p #{Process.pid}`.to_i
    yield
    memory_usage_after = `ps -o rss= -p #{Process.pid}`.to_i

    used_memory = ((memory_usage_after - memory_usage_before) / 1024.0).round(2)
    puts "Memory usage: #{used_memory} MB"
  end

  def profile_time(&block)
    time_elapsed = Benchmark.realtime(&block)

    puts "Time: #{time_elapsed.round(5)} seconds"
  end
end

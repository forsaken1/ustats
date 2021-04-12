# frozen_string_literal: true

require 'date'
require_relative 'base'

module Ustats
  # File Parser for UStats application
  class Parser < Base
    attr_reader :filename

    def initialize(filename, debug: DEBUG)
      super(debug: debug)
      @filename = filename
    end

    # returns:
    # all users collection
    # all sessions collection
    # mapping for user_id => user's sessions
    def call(&block)
      file = File.new(filename)
      users = []
      sessions = []
      sessions_mapping = {}

      file.each do |line|
        type = line.split(',')[0]

        case type
        when 'user'
          users << parse_user(line)
        when 'session'
          session = parse_session(line)
          sessions << session
          user_id = session[:user_id]
          sessions_mapping[user_id] ||= []
          sessions_mapping[user_id] << session
        end
      end
      log 'parsing has been completed'

      block.call(users, sessions, sessions_mapping)
    end

    private

    def parse_user(user)
      fields = user.split(',')
      {
        id: fields[1],
        first_name: fields[2],
        last_name: fields[3],
        age: fields[4]
      }
    end

    def parse_session(session)
      fields = session.split(',')
      {
        user_id: fields[1],
        session_id: fields[2],
        browser: fields[3].upcase,
        time: fields[4].to_i,
        date: Date.parse(fields[5])
      }
    end
  end
end

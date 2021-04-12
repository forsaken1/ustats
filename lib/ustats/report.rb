# frozen_string_literal: true

require 'progressbar'
require 'json'

require_relative 'user'

module Ustats
  # Report and calculation data for UStats application
  class Report < Base
    # keys for result.json
    TOTAL_USERS_KEY = 'totalUsers'
    UNIQUE_BROWSERS_COUNT_KEY = 'uniqueBrowsersCount'
    TOTAL_SESSIONS_KEY = 'totalSessions'
    ALL_BROWSERS_KEY = 'allBrowsers'
    USERS_STATS_KEY = 'usersStats'
    SESSIONS_COUNT_KEY = 'sessionsCount'
    TOTAL_TIME_KEY = 'totalTime'
    LONGEST_SESSION_KEY = 'longestSession'
    BROWSERS_KEY = 'browsers'
    USED_IE_KEY = 'usedIE'
    ALWAYS_USER_CHROME = 'alwaysUsedChrome'
    DATES_KEY = 'dates'

    attr_reader :users, :sessions, :sessions_mapping, :show_progress, :output_filename
    attr_accessor :report

    def initialize(users, sessions, sessions_mapping, output_filename, debug: DEBUG, show_progress: false)
      super(debug: debug)
      @users = users
      @sessions = sessions
      @sessions_mapping = sessions_mapping
      @report = {}
      @show_progress = show_progress
      @output_filename = output_filename
    end

    # returns
    # hash "report" with user's data
    def call
      calc_total_users_count
      calc_unique_browsers_count
      calc_total_sessions
      calc_all_browsers
      calc_stats_for_each_user

      report
    end

    def print
      File.write(output_filename, "#{report.to_json}\n")

      log 'results has been printed to file'
    end

    private

    def calc_total_users_count
      report[TOTAL_USERS_KEY] = users.count
    end

    def calc_unique_browsers_count
      unique_browsers = []
      sessions.each do |session|
        browser = session[:browser]
        unique_browsers << browser if unique_browsers.all? { |b| b != browser }
      end

      report[UNIQUE_BROWSERS_COUNT_KEY] = unique_browsers.count

      log 'uniq browsers has been created'
    end

    def calc_total_sessions
      report[TOTAL_SESSIONS_KEY] = sessions.count
    end

    def calc_all_browsers
      report[ALL_BROWSERS_KEY] =
        sessions
        .map { |s| s[:browser] }
        .uniq
        .sort
        .join(',')

      log 'all browsers has beed created'
    end

    def calc_stats_for_each_user
      collect_stats_from_users do |user|
        times = user.sessions.map { |s| s[:time] }
        browsers = user.sessions.map { |s| s[:browser] }
        dates = user.sessions.map { |s| s[:date] }

        {
          SESSIONS_COUNT_KEY => user.sessions.count,
          TOTAL_TIME_KEY => "#{times.sum} min.",
          LONGEST_SESSION_KEY => "#{times.max} min.",
          BROWSERS_KEY => browsers.sort.join(', '),
          USED_IE_KEY => browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
          ALWAYS_USER_CHROME => browsers.all? { |b| b =~ /CHROME/ },
          DATES_KEY => dates.sort.reverse.map(&:iso8601)
        }
      end

      log 'all user stats has been collected'
    end

    def collect_stats_from_users(&block)
      report[USERS_STATS_KEY] = {}
      progressbar = show_progress ? ProgressBar.create(total: users_objects.count) : nil
      log 'user stats progress:'

      users_objects.each do |user|
        user_key = "#{user.attributes[:first_name]} #{user.attributes[:last_name]}"
        report[USERS_STATS_KEY][user_key] ||= {}
        report[USERS_STATS_KEY][user_key] = report[USERS_STATS_KEY][user_key].merge(block.call(user))
        progressbar&.increment
      end
    end

    def users_objects
      @users_objects ||= begin
        progressbar = show_progress ? ProgressBar.create(total: users.count) : nil
        log 'users objects progress:'

        objects = users.reduce([]) do |acc, attributes|
          user_id = attributes[:id]
          user_sessions = sessions_mapping[user_id]
          user_object = User.new(attributes: attributes, sessions: user_sessions)
          progressbar&.increment
          acc << user_object
        end
        log 'users objects has been created'
        objects
      end

      @users_objects
    end
  end
end

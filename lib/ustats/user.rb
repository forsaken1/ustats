# frozen_string_literal: true

module Ustats
  # Entity for saving data for users and user's sessions
  class User
    attr_reader :attributes, :sessions

    def initialize(attributes:, sessions:)
      @attributes = attributes
      @sessions = sessions
    end
  end
end

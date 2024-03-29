# frozen_string_literal: true

module Chic
  # A configuration object used to define various options.
  #
  # * This is usually not instantiated directly, but rather by way of calling +Chic.configure+.
  #
  # @see Chic.configure
  class Configuration
    FORMATTERS = {
      nil: Formatters::Nil
    }.freeze

    attr_writer :formatters,
                :logger,
                :raise_exceptions

    def formatters
      @formatters ||= FORMATTERS.dup
    end

    def logger
      @logger ||= Logger.new($stdout)
    end

    def raise_exceptions
      @raise_exceptions == true
    end
  end
end

# frozen_string_literal: true

module Chic
  module Formatters
    class Nil < Formatter
      BLANK_VALUE = '(No Value)'

      def blank_value(value)
        @blank_value = value
        self
      end

      def to_s
        value.blank? ? (@blank_value || BLANK_VALUE) : value
      end

      private

      def value
        object&.to_s
      end
    end
  end
end

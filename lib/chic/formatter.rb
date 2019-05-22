# frozen_string_literal: true

module Chic
  class Formatter < SimpleDelegator
    delegate :to_s,
             to: :object

    def object
      __getobj__
    end
  end
end

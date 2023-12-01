# frozen_string_literal: true

module Chic
  class Formatter < SimpleDelegator
    def object
      __getobj__
    end

    def to_s
      object.to_s
    end
  end
end

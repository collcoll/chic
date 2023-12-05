# frozen_string_literal: true

module Chic
  class Formatter < SimpleDelegator
    attr_reader :context

    def initialize(object, context = nil)
      super(object)
      @context = context
    end

    def object
      __getobj__
    end

    def to_s
      object.to_s
    end
  end
end

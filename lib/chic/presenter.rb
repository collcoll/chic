# frozen_string_literal: true

module Chic
  # == Presenting Associations
  #
  # Use `presents` and `formats` declarations to present and format associations and attributes.
  #
  # @example Presenter inferred from type or attribute name
  #   FooPresenter < Chic::Presenter
  #     presents :bar
  #   end
  #
  # @example Presenter declared explicitly
  #   FooPresenter < Chic::Presenter
  #     presents bar: BarPresenter
  #   end
  #
  # @example Association declared using a different value
  #   FooPresenter < Chic::Presenter
  #     presents bar: {
  #                with: BarPresenter,
  #                value: -> { load_bar }
  #              }
  #   end
  #
  # === ActiveRecord::Relation
  #
  # When presenting `ActiveRecord::Relation` associations:
  #
  # @example Don't call relation methods through the presenter
  #   foo.presenter.bars.count
  #
  # @example Do call relation methods directly
  #   foo.bars.count
  #
  # == Formatting Attributes
  #
  # @example Declare presented associations
  #   FooPresenter < Chic::Presenter
  #     presents bar: BarPresenter
  #
  #     formats :title,
  #             with: :nil,
  #             options: {
  #               blank_value: '(No Title)'
  #             }
  #   end
  #
  class Presenter
    include Formats
    include Presents

    attr_reader :object,
                :context

    def initialize(object = nil, context = nil)
      @object = object
      @context = context
    end
  end
end

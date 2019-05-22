# frozen_string_literal: true

module Chic
  module Helpers
    # View helpers to make it easy to instantiate presenters from views:
    #
    #   <% present @foo do |foo_presenter, _foo| %>
    #     <!- ... -->
    #   <% end %>
    #
    # And:
    #
    #   <% present_each @foos do |foo_presenter, _foo| %>
    #     <!- ... -->
    #   <% end %>
    module View
      def present(object, &block)
        Chic::Presentable.presenter_for(object)&.present(object, &block)
      end

      def present_each(objects, &block)
        objects.each { |o| present(o, &block) }
      end
    end
  end
end

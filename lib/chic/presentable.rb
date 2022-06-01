# frozen_string_literal: true

module Chic
  module Presentable
    def presenter(context = nil)
      @presenter ||= presenter_class.new(self, context)
    end

    def presenter_class
      "#{respond_to?(:model_name) ? send(:model_name) : self.class.name}Presenter".constantize
    end

    module_function

    # rubocop: disable Metrics/AbcSize
    # rubocop: disable Metrics/MethodLength
    def presenter_for(object)
      if object.respond_to?(:presenter_class)
        object.presenter_class
      else
        "#{object&.model_name || object.class.name}Presenter".constantize
      end
    rescue NameError, LoadError
      if Chic.configuration.raise_exceptions
        raise PresenterClassNotDefined, "Couldn't find a presenter for '#{object.class.name}'"
      end

      Chic.configuration.logger&.debug "Couldn't find a presenter for '#{object.class.name}'"
      nil
    end
    # rubocop: enable Metrics/AbcSize
    # rubocop: enable Metrics/MethodLength
  end
end

# frozen_string_literal: true

module Chic
  module Presents
    class << self
      def included(parent)
        parent.extend ClassMethods
      end
    end

    module ClassMethods
      def present(object = nil, context = nil, &block)
        presenter = new(object, context || _caller(&block))
        yield(presenter, object) if block_given?
      end

      def present_each(objects, context = nil, &block)
        context ||= _caller(&block)
        objects.map do |object|
          presenter = new(object, context)
          yield(presenter, object) if block_given?
        end
      end

      private

      def _caller(&block)
        block.binding.eval('self') if block_given?
      end

      def presents(*attributes, **with_options)
        attributes.each do |attribute|
          _define_presents_method(attribute)
        end

        with_options.each do |attribute, options|
          _validate_presents_options!(attribute, options)
          _define_presents_with_options_method(attribute, options)
        end
      end

      def _define_presents_method(attribute)
        define_method attribute do
          memoized = "@#{attribute}"
          return instance_variable_get(memoized) if instance_variable_defined?(memoized)

          result = present(object.public_send(attribute))
          instance_variable_set(memoized, result)
        end
      end

      def _define_presents_with_options_method(attribute, options)
        define_method attribute do
          memoized = "@#{attribute}"
          return instance_variable_get(memoized) if instance_variable_defined?(memoized)

          with = _presents_options_presenter_class(options)
          value = _presents_options_value(attribute, options)
          presenter = present(value, with: with)
          instance_variable_set(memoized, presenter)
        end
      end

      # rubocop: disable Metrics/AbcSize
      # rubocop: disable Metrics/CyclomaticComplexity
      # rubocop: disable Metrics/PerceivedComplexity
      def _validate_presents_options!(attribute, options)
        _raise_presents_options_not_valid 'options must be a hash or a class', attribute \
          unless options.is_a?(Hash) || options.is_a?(Class)

        return unless options.is_a?(Hash)

        _raise_presents_options_not_valid '`with` must be a class', attribute \
          if options.key?(:with) && !options[:with].is_a?(Class)

        _raise_presents_options_not_valid '`value` must be a symbol or a lambda', attribute \
          if options.key?(:value) && !options[:value].is_a?(Symbol) && !options[:value].is_a?(Proc)
      end
      # rubocop: enable Metrics/AbcSize
      # rubocop: enable Metrics/CyclomaticComplexity
      # rubocop: enable Metrics/PerceivedComplexity

      def _raise_presents_options_not_valid(message, attribute)
        raise PresentsOptionsNotValid,
              "#{name} `presents` :#{attribute}: #{message}"
      end
    end

    private

    def present(object, with: nil)
      if object.is_a?(Enumerable)
        object.map { |o| present(o, with) }
      elsif with.present?
        with.new(object, context)
      elsif object.nil?
        nil_presenter(object)
      else
        Chic::Presentable.presenter_for(object)&.new(object, context) || nil_presenter(object)
      end
    end

    def present_with(object, with)
      with.is_a?(Class) ? with.new(object, context) : nil_presenter(object)
    end

    def nil_presenter(object)
      Presenters::Nil.new(object, context)
    end

    def _presents_options_presenter_class(options)
      options.is_a?(Class) ? options : options[:with]
    end

    def _presents_options_value(attribute, options)
      return object&.public_send(attribute) unless options.is_a?(Hash) && options.key?(:value)

      if options[:value].is_a?(Symbol)
        send(options[:value])
      elsif options[:value].is_a?(Proc)
        instance_exec(&options[:value])
      end
    end
  end
end

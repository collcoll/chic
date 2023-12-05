# frozen_string_literal: true

module Chic
  module Formats
    class << self
      def included(parent)
        parent.extend ClassMethods
      end
    end

    module ClassMethods
      private

      def format_options(options = {})
        @format_options = options
      end

      def formats(*attributes, **options)
        _validate_formats_options!(attributes, options)
        attributes.each do |attribute|
          _define_formats_method(attribute, options)
        end
      end

      def _define_formats_method(attribute, options)
        define_method attribute do
          value = _formats_options_value(attribute, options)
          format(value, with: options[:with], **(options[:options] || {}))
        end
      end

      def _validate_formats_options!(attributes, options)
        return if options.nil?

        _raise_formats_options_not_valid 'options must be a hash', attributes \
          unless options.is_a?(Hash)

        _validate_formats_options_with!(attributes, options)
        _validate_formats_options_value!(attributes, options)
        _validate_formats_options_options!(attributes, options)
      end

      # rubocop: disable Metrics/AbcSize
      def _validate_formats_options_with!(attributes, options)
        _raise_formats_options_not_valid '`with` must be a symbol or a class', attributes \
          if options.key?(:with) && !options[:with].is_a?(Symbol) && !options[:with].is_a?(Class)

        _raise_formats_options_not_valid "`with` formatter :#{options[:with]} doesn't exist", attributes \
          if options.key?(:with) && options[:with].is_a?(Symbol) && !Chic.configuration.formatters.key?(options[:with])
      end

      # rubocop: enable Metrics/AbcSize
      def _validate_formats_options_value!(attributes, options)
        _raise_formats_options_not_valid '`value` must be a symbol or a lambda', attributes \
          if options.key?(:value) && !options[:value].is_a?(Symbol) && !options[:value].is_a?(Proc)
      end

      def _validate_formats_options_options!(attributes, options)
        _raise_formats_options_not_valid '`options` must be a hash', attributes \
          if options.key?(:options) && !options[:options].is_a?(Hash)
      end

      def _raise_formats_options_not_valid(message, attributes)
        raise FormatsOptionsNotValid,
              "#{name} `formats` [#{attributes.map { |a| ":#{a}" }.join(', ')}]: #{message}"
      end
    end

    private

    # rubocop: disable Metrics/MethodLength
    def _formatters
      @_formatters ||= Chic.configuration.formatters.reduce({}) do |result, (key, klass)|
        formatter = case klass
                    when Class
                      klass
                    when String
                      klass.constantize
                    else
                      raise ConfigFormatterNotValid, "Configured formatter for #{key} must be a class or class-string"
                    end

        result.merge(key => formatter)
      end
    end
    # rubocop: enable Metrics/MethodLength

    def _formats_options_value(attribute, options)
      return object&.public_send(attribute) unless options.is_a?(Hash) && options.key?(:value)

      case options[:value]
      when Symbol
        send(options[:value])
      when Proc
        instance_exec(&options[:value])
      else
        raise FormatsOptionsNotValid, "Options value for #{attribute} must be a symbol or a Proc"
      end
    end

    def _formatter_class(with)
      case with
      when Class
        with
      when Symbol
        _formatters[with] || raise(FormatsOptionsNotValid, "Formatter :#{with} is not supported")
      else
        _formatters[:nil]
      end
    end

    def format(value, with: nil, **options)
      formatter_context = respond_to?(:context) ? context : nil
      _formatter_class(with).new(value, formatter_context).tap do |formatter|
        options.each do |option, argument|
          formatter.public_send(option, argument) if formatter.respond_to?(option)
        end
      end
    end
  end
end

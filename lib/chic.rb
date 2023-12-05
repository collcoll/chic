# frozen_string_literal: true

require 'delegate'

require 'chic/version'
require 'chic/errors'
require 'chic/helpers'

require 'chic/formats'
require 'chic/formatter'
require 'chic/formatters'

require 'chic/presents'
require 'chic/presenter'
require 'chic/presenters'
require 'chic/presentable'

require 'chic/configuration'

# = Chic
#
# Opinionated presentation layer comprised of presenters and formatters.
#
# @see Chic::Presenter
# @see Chic::Presentable
# @see Chic::Helpers::View
module Chic
  module_function

  # Gets the configuration object.
  #
  # If none was set, a new configuration object is instantiated and returned.
  #
  # @return [Configuration] the configuration object
  #
  # @see Configuration
  def configuration
    @configuration ||= Configuration.new
  end

  # Allows for configuring the library using a block.
  #
  # @example Configuration using a block
  #   Chic.configure do |config|
  #     # ...
  #   end
  #
  # @see Configuration
  def configure
    yield configuration if block_given?
  end
end

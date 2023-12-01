# frozen_string_literal: true

require 'test_helper'

class ChicTest < Minitest::Test
  include Chic::Helpers::View

  class Formatter < Chic::Formatter
  end

  class BarPresenter < Chic::Presenter
  end

  class FooPresenter < Chic::Presenter
    formats :attribute

    presents bar: BarPresenter
  end

  class Foo
    include Chic::Presentable

    attr_accessor :attribute, :bar

    def presenter_class
      FooPresenter
    end
  end

  class Bar
  end

  def setup
    @foo = Foo.new
    @foo.attribute = 'value'
    @foo.bar = Bar.new
  end

  def test_that_it_has_a_version_number
    refute_nil ::Chic::VERSION
  end

  def test_formats
    assert_equal Chic::Formatters::Nil, @foo.presenter.attribute.class
  end

  def test_present_context
    present @foo do |foo_presenter|
      assert_equal self, foo_presenter.context
      assert_equal self, foo_presenter.attribute.context
    end
  end

  def test_presenter_association
    assert_equal BarPresenter, @foo.presenter.bar.class
  end
end

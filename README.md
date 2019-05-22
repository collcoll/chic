# Chic

Opinionated presentation layer comprised of presenters and formatters.

## Installation

Add this line to your application's Gemfile:

    gem 'chic'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chic

## Usage

### Being Presentable

Make objects easily presentable by:

```ruby
class Foo
  include Chic::Presentable
end
```

### Creating Presenters

Present presentables with a presenter by inheriting from `Chic::Presenter`:

```ruby
class FooPresenter < Chic::Presenter
  # ...
end
```

You can also include `Chic::Presents` and `Chic::Formats` as needed:

```ruby
class FooPresenter
  include Chic::Formats
  include Chic::Presents
  # ...
end
```

**Note:** You need to make sure that the object being presented and the context in which it is being presented, for example the view, are accessible through `object` and `context` on the presenter instance respectively.

### Using Presenters

Presenters should be instantiated from views using `.present`:

```ruby
<% FooPresenter.present @foo do |foo_presenter, _foo| %>
  <!-- ... -->
<% end %>
```

Collections can be presented using `.present_each`:

```ruby
<% FooPresenter.present_each @foos do |foo_presenter, _foo| %>
  <!-- ... -->
<% end %>
```

If you've made use of the view helpers, you can drop the class name:

```ruby
<% present @foo do |foo_presenter, _foo| %>
  <!-- ... -->
<% end %>
```

And:

```ruby
<% present_each @foo do |foo_presenter, _foo| %>
  <!-- ... -->
<% end %>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/collcoll/chic. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Chic project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/chic/blob/master/CODE_OF_CONDUCT.md).

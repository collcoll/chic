# Chic

An opinionated presentation layer comprising presenters and formatters.

Chic was borne out of a need for a simple PORO-style presentation layer for Rails applications to help DRY up formatting logic in views and view helpers.

## Installation

To get started, add this line to your Gemfile and install it using Bundler:

```ruby
gem 'chic'
```

## Usage

Though it is not a requirement, for ease of reference it is assumed that you will be using this library in a Rails application where you will be creating presenters for your models.

### Creating Presenters

Create a presenter by deriving from `Chic::Presenter`, and then declare which attributes should return formatters or presenters.

```ruby
# app/presenters/foo_presenter.rb

class FooPresenter < Chic::Presenter
  formats :baz
  
  presents bar: 'BarPresenter'
end
```

### Using Presenters

Include `Chic::Presentable` to make your objects presentable:

```ruby
# app/models/foo.rb

class Foo < ApplicationRecord
  include Chic::Presentable
  
  belongs_to :bar
end
```

Instantiate a presenter by calling `.present` on the presenter class, for example in a Rails view:

```erb
<% FooPresenter.present @foo do |foo_presenter| %>
  <!-- ... -->
<% end %>
```

Collections can be presented using `.present_each`:

```erb
<% FooPresenter.present_each @foos do |foo_presenter, foo| %>
  <!-- ... -->
<% end %>
```

You can also include the view helpers:

```ruby
module ApplicationHelper
  include Chic::Helpers::View
end
```

Which will allow you to instantiate presenters without having to use the class name:

```erb
<% present @foo do |foo_presenter| %>
  <!-- ... -->
<% end %>

<% present_each @foos do |foo_presenter, foo| %>
  <!-- ... -->
<% end %>
```

See the [Conventions](#conventions) section below for more on using presenters.

### Creating Formatters

Formatters format values by deriving from `Chic::Formatters::Nil` and overriding the private `value` method:

```ruby
# app/formatters/date_time_formatter.rb

class DateTimeFormatter < Chic::Formatters::Nil
  private

  def value
    return if object.blank?

    object.strftime('%-d %b %Y %H:%M')
  end
end
```

**Note:** You should always return `nil` if the object being formatted is blank so that the `Nil` formatter behaves correctly.

Provide additional formatter options as chainable methods:

```ruby
# app/formatters/date_time_formatter.rb

class DateTimeFormatter < Chic::Formatters::Nil
  def format=(value)
    @format = value
    self
  end
  
  private

  def value
    return if object.blank?

    object.strftime(@format || '%-d %b %Y %H:%M')
  end
end
```

### Using Formatters

Declare formatted values in presenters using `formats`:

```ruby
# app/presenters/foo_presenter.rb

class FooPresenter < Chic::Presenter
  formats :created_at,
          with: 'DateTimeFormatter'
end
```

Render formatted values by calling `#to_s` on the formatter returned, which happens implicitly in Rails views for example:

```erb
<% FooPresenter.present @foo do |foo_presenter, _foo| %>
  <%= foo_presenter.created_at %>
<% end %>
```

#### Configurable options

If the formatter derives from `Chic::Formatters::Nil`, then configure a blank value to be used:

```ruby
# app/presenters/foo_presenter.rb

class FooPresenter < Chic::Presenter
  formats :created_at,
          with: 'DateTimeFormatter',
          options: {
            blank_value: '(Not yet created)'
          }
end
```

If the formatter supports additional options using chainable methods as described above, configure those options in the same way: 

```ruby
# app/presenters/foo_presenter.rb

class FooPresenter < Chic::Presenter
  formats :created_at,
          with: 'DateTimeFormatter',
          options: {
            format: '%-d %B %Y at %H:%M'
          }
end
```

If needed, override those options where the formatted value is being rendered:

```erb
<% FooPresenter.present @foo do |foo_presenter, _foo| %>
  <%= foo_presenter.created_at.format('%c').blank_value('–') %>
<% end %>
```

#### Named formatters

Optionally configure formatters with a name, for example in a Rails initializer:

```ruby
# config/initializers/chic.rb

require 'chic'

Chic.configure do |config|
  config.formatters.merge!(
    date_time: 'DateTimeFormatter'
  )
end
```

Allowing you to refer to those formatters by name instead of by class:

```ruby
# app/presenters/foo_presenter.rb

class FooPresenter < Chic::Presenter
  formats :created_at,
          with: :date_time
end
```

## Logging

If a presenter class for an object you're trying to present can't be found, an entry at debug level will be made to the configured logger.

You can configure the logger to be used:

```ruby
# config/initializers/chic.rb

require 'chic'

Chic.configure do |config|
  config.logger = Logger.new($stdout)
end
```

It may be beneficial to know about missing presenter classes sooner than later, in which case you can enable exceptions when it makes sense to do so – for example, a Rails application in any environment other than production:

```ruby
# config/initializers/chic.rb

require 'chic'

Chic.configure do |config|
  config.raise_exceptions = Rails.env.production? == false
end
```

## Conventions

A few helpful conventions that have gone a long way to keep things maintainable.

### Naming presenter classes

Presenter class names are derived by appending `Presenter` to the `#model_name` or the class name of the object being presented. It is strongly recommended that you stick to this convention, but if you need to change it – for example you might have overridden `#model_name` – you can do so by defining a `#presenter_class` method: 

```ruby
# app/forms/user/sign_up_form.rb

class User::SignUpForm < User
  include Chic::Presentable
  
  def self.model_name
    ActiveModel::Name.new(self, nil, 'User')
  end

  def presenter_class
    User::SignUpFormPresenter
  end
end
```

### Instantiate presenters in views only

Try not instantiate presenters outside of the view layer if possible.

**Don't**

```ruby
# app/controllers/foo_controller.rb

class FoosController < ApplicationController
  def show
    @foo = Foo.find(params[:id])
    @foo_presenter = FooPresenter.new(@foo)
  end
end
```

```erb
<!-- app/views/foos/_show.html.erb -->

<%= link_to @foo_presenter.created_at, foo_path(@foo) %>
```

**Do**

```ruby
# app/controllers/foo_controller.rb

class FoosController < ApplicationController
  def show
    @foo = Foo.find(params[:id])
  end
end
```

```erb
<!-- app/views/foos/_show.html.erb -->

<% present @foo do |foo_presenter| %>
  <%= link_to foo_presenter.created_at, foo_path(@foo) %>
<% end %>
```

### Keep presenter instances scoped to only the view in which they're being used

It can get messy if you pass presenter instances to other views, try avoid that if possible.

**Don't**

```erb
<% present @foo do |foo_presenter| %>
  <!-- ... -->
  <%= render partial: 'path/to/partial', locals: { foo: foo_presenter } %>
<% end %>
```

**Do**

```erb
<% present @foo do |foo_presenter| %>
  <!-- ... -->
  <%= render partial: 'path/to/partial', locals: { foo: @foo } %>
<% end %>
```

### Use presenters and formatters for presentation only

It may be tempting to use presenters for conditional logic, but it's far better to use the original object for anything other than presentation.

**Don't**

```erb
<% present_each @foos do |foo_presenter, foo| %>
  <% if foo_presenter.created_at %>
    <%= link_to foo_presenter.created_at, foo_path(foo_presenter) %>
  <% end
<% end %>
```

**Note:** Passing a presenter instance to a route helper as shown would only work if the presenter declared `id` as a formatted attribute. While this may work, it is not predictable behaviour.

**Do**

```erb
<% present_each @foos do |foo_presenter, foo| %>
  <% if foo.created_at %>
    <%= link_to foo_presenter.created_at, foo_path(foo) %>
  <% end
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

[![Code Climate](https://codeclimate.com/github/EditLLC/rails-montage/badges/gpa.svg)](https://codeclimate.com/github/EditLLC/rails-montage)
[![Circle CI](https://circleci.com/gh/EditLLC/rails-montage.svg?style=svg)](https://circleci.com/gh/EditLLC/rails-montage)
[![codecov.io](http://codecov.io/github/EditLLC/rails-montage/coverage.svg?branch=master)](http://codecov.io/github/EditLLC/rails-montage?branch=master)

# Montage Rails

A Rails wrapper for the [Montage](http://www.yourdatacandobetter.com) API

## Requirements

Ruby 1.9+<br>
Rails 3.1+

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'montage_rails', '~> 0.4', require: 'montage_rails'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install montage_rails

## Setup

Create an initializer in your app's initializer directory `config/initializers/montage_rails.rb`:

```ruby
MontageRails.configure do |config|
  config.domain = "your_montage_domain"
  config.token = "your_montage_token"
end
```

If you do not have your token, you can simply use your username and password:

```ruby
MontageRails.configure do |config|
  config.domain = "your_montage_domain"
  config.username = "your_montage_username"
  config.password = "your_montage_password"
end
```

This will retrieve the token from Montage every time your app is loaded. However,
it is desirable to retrieve your token and use that, so an authorization request
will not be made every time. You can do so from your Rails console:

```ruby
  > client = Montage::Client.new do |c|
  >   c.domain = "your_montage_domain"
  >   c.username = "your_montage_username"
  >   c.password = "your_montage_password"
  > end
  > token = c.auth.token.value
```

## Usage

This wrapper is meant to be a drop in replacement for ActiveRecord

```ruby
class User < MontageRails::Base
  belongs_to :subscription
  has_many :accounts

  before_create :encrypt_password
  after_create :send_email

  private

  def encrypt_password
    ...
  end

  def send_email
    ...
  end
end
```

We do not currently support *all* of the functionality of ActiveRecord, but a
lot of the core functionality is supported. The following is a list of supported features:

### Querying

```ruby
User.first
User.all
User.where(column_name: "value")
User.where(column_name: [1, 2, 3])
User.where("column_name ILIKE 'foo'")
User.where("column_name LIKE 'foo'")
User.where("column_name > 1")
User.where("column_name < 1")
User.where("column_name >= 1")
User.where("column_name <= 1")
User.where("column_name != 1")
User.where("column_name NOT IN (1, 2, 3)")
User.where("column_name IN (1, 2, 3)")
User.order(created_at: :asc)
User.limit(10)
User.find_by_column_name("Foo")
User.find_by_id(1)
User.find_or_initialize_by(column_name1: "Foo", column_name2: "Bar")

user = User.first
user.accounts.where(...).order(...).limit(10)
user.subscription
```

### Document creation

```ruby
user = User.create(name: "Batman")
user.accounts.create(name: "Foo")

user = User.new
user.name = "Batman"
user.save
user.save!
```

### Document updating

```ruby
user = User.first
user.update_attributes(name: "Superman")

user.name = "Superman"
user.save
```

### Document destruction

```ruby
user = User.first
user.destroy
```

### Callbacks

MontageRails supports all ActiveModel callbacks:

```ruby
class User
  before_create :digest_password
end
```
### Validations

MontageRails supports all ActiveModel validations, and will add validation
errors to the `error` object on each model instance:

```ruby
class User
  validates :email, presence: true
end

user = User.new
user.save
puts user.errors.full_messages.first
=> "Email can't be blank"
puts user.persisted?
=> false
```

### Other

```ruby
user = User.first
user.reload
user.new_record?
```

## Contributing

1. Fork it ( https://github.com/EditLLC/montage_rails/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Be sure to include tests for all your new features
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

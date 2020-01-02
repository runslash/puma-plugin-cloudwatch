# Puma::Plugin::Cloudwatch

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aws-sdk-cloudwatch'
gem 'puma'
gem 'puma-plugin-cloudwatch'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install puma-plugin-cloudwatch

## Usage

Add `plugin :cloudwatch` to your PUMA configuration.

Example:
```ruby
require 'bundler/setup'
require 'aws-sdk-cloudwatch'
require 'puma-plugin-cloudwatch'

bind "tcp://127.0.0.1:9292"
workers 1
threads 8, 16
plugin :cloudwatch
```

## Configuration

The following environment variables are available (with their defaults):
```shell
PUMA_CLOUDWATCH_INTERVAL=60
PUMA_CLOUDWATCH_DIMENSIONS="Platform=test;Environment=development"
PUMA_CLOUDWATCH_NAMESPACE=puma
PUMA_CLOUDWATCH_EXCLUDE=Workers,BootedWorkers
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/puma-plugin-cloudwatch. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/puma-plugin-cloudwatch/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Puma::Plugin::Cloudwatch project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/puma-plugin-cloudwatch/blob/master/CODE_OF_CONDUCT.md).

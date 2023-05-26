# RubocopDirector

A command–line utility for refactoring planning. It uses `.rubocop_todo.yml` and git history to prioritize a list of refactorings that can bring the most value.

## Installation

Prerequisites:

- `git` repo;
- generated `.rubocop_todo.yml`.

Install the gem and add to the application's Gemfile by executing:

```bash
$ bundle add rubocop_director
```

## Usage

First of all, create the initial config file based on `.rubocop_todo.yml`:

```bash
bundle exec rubocop-director --generate-config
```

Optionally adjust weights in the config:

1. `update_weight` means how important the fact that file was recently updated;
2. `default_cop_weight` will be used in case when weight for a specific cop is not set;
3. `weights` contains weights for specific cops.

_You can use any numbers you want, but I think it's better to stick with something from 0 to 1._

Build the report:

```bash
bundle exec rubocop-director
```

As a result you'll get something like this:

```bash
💡 Checking git history since 1995-01-01 to find hot files...
💡🎥 Running rubocop to get the list of offences to fix...
💡🎥🎬 Calculating a list of files to refactor...
--------------------
spec/models/user.rb
updated 10 times since -4712-01-01
offences: RSpec/AroundBlock - 8
refactoring value: 110 (55%)
--------------------
spec/models/order.rb
updated 20 times since -4712-01-01
offences: Rspec/BeEql - 4
refactoring value: 90 (45%)
```

> Want a different output format (e.g., CSV)? Let me know, open an issue!

Value is calculated using a formula: `sum of value from each cop (<number of offences> * <cop weight> * <number of file updates> * <update weight>)`.

If you need to count updates from a specific date—use `--since`:

```bash
bundle exec rubocop-director --since=2023-01-01
```

## Development

After checking out the repo, run `bundle install` to install dependencies

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/DmitryTsepelev/rubocop_director.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

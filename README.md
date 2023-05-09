# RubocopDirector

Plan your refactorings using Rubocop TODO file and git history.

## Installation

Prerequisites:

- `sed`;
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
[1/3] Running rubocop to get the list of offences to fix...
[2/3] Checking git history since -4712-01-01 to find hot files...
[3/3] Calculating a list of files to refactor...
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

Value is calculated using a formula: `sum of value from each cop (<number of offences> * <cop weight> * <number of file updates> * <update weight>)`.

If you need to count updates from a specific date—use `--since`:

```bash
bundle exec rubocop-director --since=2023-01-01
```

## Development

After checking out the repo, run `bundle insatll` to install dependencies

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/DmitryTsepelev/rubocop_director.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

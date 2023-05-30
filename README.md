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

Path: app/controllers/user_controller.rb
Updated 99 times since 2023-01-01
Offenses:
  🚓 Rails/SomeCop - 2
Refactoring value: 1.5431217598108933 (54.79575%)

Path: app/models/user.rb
Updated 136 times since 2023-01-01
Offenses:
  🚓 Rails/SomeCop - 1
  🚓 Rails/AnotherCop - 1
Refactoring value: 1.2730122208719792 (45.20425%)
```

> Want a different output format (e.g., CSV)? Let me know, open an issue!

Value is calculated using a formula: `sum of value from each cop (<count of offences> * <cop weight> * (<count of file updates> / <total count of updates>) ** <update weight>)`.

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

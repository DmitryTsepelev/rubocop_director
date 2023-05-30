require "rubocop_director/commands/generate_config"
require "rubocop_director/commands/plan"
require "rubocop_director/version"
require "rubocop_director/runner"

module RubocopDirector
  CONFIG_NAME = ".rubocop_director.yml"
  RUBOCOP_CONFIG_NAME = ".rubocop.yml"
  TODO_CONFIG_NAME = ".rubocop_todo.yml"
end

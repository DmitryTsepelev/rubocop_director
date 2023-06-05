require "optparse"
require "optparse/date"

require_relative "commands/generate_config"
require_relative "commands/plan"

module RubocopDirector
  class Runner
    def initialize(args)
      @options = {}
      arg_parser.parse(args, into: @options)
      verify_options
    end

    def perform
      command.run.either(
        ->(success_message) { puts success_message },
        ->(failure_message) { puts "\nFailure: #{failure_message}" }
      )
    end

    private

    def verify_options
      @options[:todo_config] = verified_path(config_name: TODO_CONFIG_NAME, path: @options[:todo_config])
      @options[:rubocop_config] = verified_path(config_name: RUBOCOP_CONFIG_NAME, path: @options[:rubocop_config])
      @options[:director_config] = verified_path(config_name: CONFIG_NAME, path: @options[:director_config])
    end

    def verified_path(config_name:, path:)
      path = project_root if path.nil?
      path.directory? ? path + config_name : path
    end

    def project_root
      return Rails.root if defined?(Rails)
      return Bundler.root if defined?(Bundler)

      Pathname.new(Dir.pwd)
    end

    def command
      @command ||= if @options.key?(:generate_config)
        Commands::GenerateConfig.new(**@options.slice(:todo_config, :director_config))
      else
        Commands::Plan.new(**@options.slice(:since, :director_config, :rubocop_config))
      end
    end

    def arg_parser
      OptionParser.new do |p|
        p.accept(Pathname) do |s|
          Pathname.new(s)
        rescue ArgumentError, TypeError
          raise OptionParser::InvalidArgument, s
        end

        p.on("--generate_config", "Generate default config based on .rubocop_todo.yml")
        p.on("--since=SINCE", Date, "Specify date to start checking git history")
        p.on("--todo_config=PATH", Pathname, "Specify path where .rubocop_todo.yml config must be read from, default path: {PROJECTROOT}/.rubocop_todo.yml")
        p.on("--director_config=PATH", Pathname, "Specify path where .rubocop_director.yml config must be read from OR written to, default path: {PROJECTROOT}/.rubocop_director.yml")
        p.on("--rubocop_config=PATH", Pathname, "Specify path where .rubocop.yml config must be read from, default path: {PROJECTROOT}/.rubocop.yml")

        p.on("--help", "Prints this help") do
          puts p
          exit
        end
      end
    end
  end
end

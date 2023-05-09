require "optparse"

require_relative "commands/generate_config"
require_relative "commands/plan"

module RubocopDirector
  class Runner
    def initialize(args)
      arg_parser.parse(args)

      @command ||= Commands::Plan.new(@since)
    end

    def perform
      @command.run
    end

    private

    def arg_parser
      OptionParser.new do |p|
        p.on("--generate-config", "Generate default config based on .rubocop_todo.yml") do |since|
          @command = Commands::GenerateConfig.new
        end

        p.on("--since=SINCE", "Specify date to start checking git history") do |since|
          @since = since
        end

        p.on("-h", "--help", "Prints this help") do
          puts p
          exit
        end
      end
    end
  end
end

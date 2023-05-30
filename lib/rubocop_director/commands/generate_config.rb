require "dry/monads"

module RubocopDirector
  module Commands
    class GenerateConfig
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:run)

      RUBOCOP_TODO = ".rubocop_todo.yml"

      def initialize(director_config:, todo_config:)
        @director_config = director_config
        @todo_config = todo_config
      end

      def run
        rubocop_todo = yield load_config
        yield check_config_already_exists

        create_config(rubocop_todo)
      end

      private

      def load_config
        Success(YAML.load_file(@todo_config))
      rescue Errno::ENOENT
        Failure("#{@todo_config} not found, generate it using `rubocop --regenerate-todo`")
      end

      def check_config_already_exists
        return Success() if config_not_exists? || override_config?

        Failure("previous version of #{@director_config} was preserved.")
      end

      def config_not_exists?
        !File.file?(@director_config)
      end

      def override_config?
        puts("#{@director_config} already exists, do you want to override it? (y/n)")
        $stdin.gets.chomp == "y"
      end

      def create_config(rubocop_todo)
        weights = rubocop_todo.keys.to_h { |key| [key, 1] }

        File.write(@director_config, {
          "update_weight" => 1,
          "default_cop_weight" => 1,
          "weights" => weights
        }.to_yaml)

        Success("Config generated")
      end
    end
  end
end

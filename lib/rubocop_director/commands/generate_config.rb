require "dry/monads"

module RubocopDirector
  module Commands
    class GenerateConfig
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:run)

      RUBOCOP_TODO = ".rubocop_todo.yml"

      def run
        rubocop_todo = yield load_config
        yield check_config_already_exists

        create_config(rubocop_todo)
      end

      private

      def load_config
        Success(YAML.load_file(RUBOCOP_TODO))
      rescue Errno::ENOENT
        Failure("#{RUBOCOP_TODO} not found, generate it using `rubocop --regenerate-todo`")
      end

      def check_config_already_exists
        return Success() if config_not_exists? || override_config?

        Failure("previous version of #{CONFIG_NAME} was preserved.")
      end

      def config_not_exists?
        !File.file?(CONFIG_NAME)
      end

      def override_config?
        puts("#{CONFIG_NAME} already exists, do you want to override it? (y/n)")
        gets.chomp == "y"
      end

      def create_config(rubocop_todo)
        weights = rubocop_todo.keys.to_h { |key| [key, 1] }

        File.write(CONFIG_NAME, {
          "update_weight" => 1,
          "default_cop_weight" => 1,
          "weights" => weights
        }.to_yaml)

        Success("Config generated")
      end
    end
  end
end

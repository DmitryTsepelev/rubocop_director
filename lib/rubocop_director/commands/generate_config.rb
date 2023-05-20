require "dry/monads"

module RubocopDirector
  module Commands
    class GenerateConfig
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:run)

      RUBOCOP_TODO = ".rubocop_todo.yml"

      def run
        return Success("previous version of #{CONFIG_NAME} was preserved.") if config_present? && !override_config?

        todo = yield load_config

        weights = todo.keys.each_with_object({}).each do |cop, acc|
          acc.merge!(cop => 1)
        end

        File.write(CONFIG_NAME, {
          "update_weight" => 1,
          "default_cop_weight" => 1,
          "weights" => weights
        }.to_yaml)

        Success("Config generated")
      end

      private

      def load_config
        Success(YAML.load_file(RUBOCOP_TODO))
      rescue Errno::ENOENT
        Failure("#{RUBOCOP_TODO} not found, generate it using `rubocop --regenerate-todo`")
      end

      def config_present?
        return true if File.file?(CONFIG_NAME)
      end

      def override_config?
        puts("#{CONFIG_NAME} already exists, do you want to override it? (y, n)")
        option = $stdin.gets.chomp

        return true if option == "y"
      end
    end
  end
end

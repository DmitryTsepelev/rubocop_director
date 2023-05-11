require "dry/monads"

module RubocopDirector
  module Commands
    class GenerateConfig
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:run)

      RUBOCOP_TODO = ".rubocop_todo.yml"

      def run
        todo = yield load_config

        weights = todo.keys.each_with_object({}).each do |cop, acc|
          acc.merge!(cop => 1)
        end

        # TODO: warn if file exists
        File.write(".rubocop-director.yml", {
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
    end
  end
end

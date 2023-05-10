require "dry/monads"

module RubocopDirector
  module Commands
    class GenerateConfig
      include Dry::Monads[:result]

      def run
        # TODO: check file exists
        todo = YAML.load_file(".rubocop_todo.yml")

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
    end
  end
end

module RubocopDirector
  module Commands
    class GenerateConfig
      def run
        # TODO: check file exists
        todo = YAML.load_file(".rubocop_todo.yml")

        weights = todo.keys.each_with_object({}).each do |cop, acc|
          acc.merge!(cop => 1)
        end

        # TODO: warn if file exists
        File.open('.rubocop-director.yml', 'w') do |f|
          f.write({
            'update_weight' => 1,
            'default_cop_weight' => 1,
            'weights' => weights,
          }.to_yaml)
        end
      end
    end
  end
end

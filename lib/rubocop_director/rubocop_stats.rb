require "open3"
require "json"
require "yaml"

require "dry/monads"

module RubocopDirector
  class RubocopStats
    include Dry::Monads[:result]
    include Dry::Monads::Do.for(:fetch)

    TEMP_CONFIG_PATH = "./.temp_rubocop.yml"

    def fetch
      config = yield load_config
      yield generate_temp_rubocop_config_without_todo(initial_config: config)

      stats = yield generate_stats
      yield remove_temp_config

      Success(stats)
    end

    private

    def load_config
      Success(YAML.load_file("./.rubocop.yml"))
    rescue Errno::ENOENT
      Failure("unable to load rubocop config. Please ensure .rubocop.yml file is present at your project's root directory")
    end

    def generate_temp_rubocop_config_without_todo(initial_config:)
      initial_config.dig("inherit_from")&.delete(".rubocop_todo.yml")

      Success(File.write(TEMP_CONFIG_PATH, initial_config.to_yaml))
    rescue IOError => e
      Failure("Failed to create a temporary config file to generate stats: #{e}")
    end

    def generate_stats
      stdout, stderr = Open3.capture3("bundle exec rubocop -c #{TEMP_CONFIG_PATH} --format json")

      if stderr.length > 0
        Failure("Failed to fetch rubocop stats: #{stderr}")
      else
        Success(JSON.parse(stdout)["files"])
      end
    end

    def remove_temp_config
      Success(File.delete(TEMP_CONFIG_PATH))
    end
  end
end
